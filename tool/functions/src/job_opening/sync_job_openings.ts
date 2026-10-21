import { settleAll } from '../shared/settle_all.js';
import type { JobFeed } from './feed/job_feed.js';
import type {
  JobOpening,
  MatchedJobOpening,
  PortfolioProfile,
  ScoredJobOpening,
} from './job_opening.js';
import { dedupeJobOpenings } from './match/dedupe.js';
import { isLocationInRegions, type Region } from './match/region_filter.js';
import { isPortfolioKindOfRole } from './match/role_filter.js';
import { SkillMatcher, termPattern } from './match/skill_matcher.js';
import type { JobScorer } from './score/job_scorer.js';

/** Openings scoring below this are not stored. */
export const minJobFitScore = 60;

/** Bounds the Gemini calls of one run; the best keyword matches go first. */
export const maxScoredOpenings = 120;

/** Openings posted longer ago than this are dropped before matching. */
export const maxJobAgeDays = 30;

const dayMs = 24 * 60 * 60 * 1000;

// Two at a time keeps Gemini from throttling the run.
const scoringConcurrency = 2;

/**
 * Scoring stops starting new openings after this long, so slow retries cannot
 * run into the function's 15-minute timeout. Skipped openings count as failed.
 */
export const scoringTimeLimitMs = 10 * 60 * 1000;

export interface SyncLogger {
  info(message: string, data?: object): void;
  warn(message: string, data?: object): void;
}

export interface SyncDependencies {
  feeds: JobFeed[];
  listUserIds(): Promise<string[]>;
  loadProfile(): Promise<PortfolioProfile>;
  /** The regions to keep jobs for; empty keeps every region. */
  loadRegions(profile: PortfolioProfile): Promise<Set<Region>>;
  scorer: JobScorer;
  writeJobOpenings(
    userId: string,
    openings: ScoredJobOpening[],
    now: Date,
  ): Promise<void>;
  now(): Date;
  logger: SyncLogger;
}

export interface SyncResult {
  userCount: number;
  fetchedCount: number;
  /** Openings dropped as older than [maxJobAgeDays] or expired. */
  staleCount: number;
  /** Openings dropped as limited to regions other than the preferred ones. */
  otherRegionCount: number;
  /** Openings dropped as a kind of role the portfolio does not hold. */
  otherRoleCount: number;
  matchedCount: number;
  scoredCount: number;
  failedScoreCount: number;
  keptCount: number;
  failedSources: string[];
}

/**
 * Searches every feed for the portfolio's role terms, drops openings older
 * than [maxJobAgeDays], keeps those that match the portfolio's skills or
 * roles, scores them with the [JobScorer] and writes the ones scoring at
 * least [minJobFitScore] for each user with job search on. A feed or score
 * that fails is skipped; the run fails only when every feed or every score
 * fails.
 */
export async function syncJobOpenings(
  dependencies: SyncDependencies,
): Promise<SyncResult> {
  const { feeds, logger } = dependencies;
  const userIds = await dependencies.listUserIds();
  if (userIds.length === 0) {
    logger.info('No users have job search on; skipping the feeds');
    return {
      userCount: 0,
      fetchedCount: 0,
      staleCount: 0,
      otherRegionCount: 0,
      otherRoleCount: 0,
      matchedCount: 0,
      scoredCount: 0,
      failedScoreCount: 0,
      keptCount: 0,
      failedSources: [],
    };
  }

  const profile = await dependencies.loadProfile();
  if (profile.skills.length === 0 && profile.searchTerms.length === 0) {
    logger.warn('The portfolio has no skills or roles; nothing can match');
    return {
      userCount: userIds.length,
      fetchedCount: 0,
      staleCount: 0,
      otherRegionCount: 0,
      otherRoleCount: 0,
      matchedCount: 0,
      scoredCount: 0,
      failedScoreCount: 0,
      keptCount: 0,
      failedSources: [],
    };
  }

  const query = { terms: profile.searchTerms };
  logger.info('Searching the job feeds', { terms: query.terms });
  const feedResults = await Promise.allSettled(
    feeds.map((feed) => feed.fetchJobs(query)),
  );
  const openings: JobOpening[] = [];
  const failedSources: string[] = [];
  feedResults.forEach((result, index) => {
    const source = feeds[index].source;
    if (result.status === 'fulfilled') {
      logger.info('Fetched job openings', {
        source,
        count: result.value.length,
      });
      openings.push(...result.value);
    } else {
      logger.warn('A job feed failed', {
        source,
        error: String(result.reason),
      });
      failedSources.push(source);
    }
  });
  if (feeds.length > 0 && failedSources.length === feeds.length) {
    throw new Error(`Every job feed failed: ${failedSources.join(', ')}`);
  }

  const runStartedAt = dependencies.now();
  const oldestPublishedAt = runStartedAt.getTime() - maxJobAgeDays * dayMs;
  const fresh = openings.filter(
    (opening) =>
      opening.publishedAt.getTime() >= oldestPublishedAt &&
      (opening.expiresAt === undefined || opening.expiresAt > runStartedAt),
  );
  if (fresh.length < openings.length) {
    logger.info('Dropped stale job openings', {
      stale: openings.length - fresh.length,
      maxAgeDays: maxJobAgeDays,
    });
  }

  // Before matching, so no scoring goes to jobs that cannot be taken from
  // the preferred regions or that are another kind of role, such as a
  // product manager for a mobile app.
  const regions = await dependencies.loadRegions(profile);
  const inRegion = fresh.filter((opening) =>
    isLocationInRegions(opening.location, regions),
  );
  const relevant = inRegion.filter((opening) =>
    isPortfolioKindOfRole(opening.title, profile.roles),
  );
  logger.info('Filtered job openings by region and role', {
    regions: [...regions],
    otherRegion: fresh.length - inRegion.length,
    otherRole: inRegion.length - relevant.length,
  });

  // An opening qualifies with enough matching skills, or when its title names
  // one of the portfolio's roles, such as "Senior Flutter Engineer".
  const matcher = new SkillMatcher(profile.skills);
  const rolePatterns = profile.searchTerms.map((term) => termPattern(term));
  const matched = dedupeJobOpenings(relevant).flatMap((opening) => {
    const matchedSkills = matcher.matchedSkills(opening);
    const title = opening.title.toLowerCase();
    const isRoleMatch = rolePatterns.some((pattern) => pattern.test(title));
    return matcher.isMatch(matchedSkills) || isRoleMatch
      ? [{ ...opening, matchedSkills, isRoleMatch }]
      : [];
  });

  const candidates = [...matched]
    .sort(byBestKeywordMatch)
    .slice(0, maxScoredOpenings);
  if (candidates.length < matched.length) {
    logger.info('Scoring only the best keyword matches', {
      matched: matched.length,
      scored: candidates.length,
    });
  }
  const { scored, failedCount } = await scoreOpenings(
    candidates.map(({ isRoleMatch: _, ...opening }) => opening),
    profile,
    dependencies,
  );
  const kept = scored.filter((opening) => opening.score >= minJobFitScore);

  const now = dependencies.now();
  for (const userId of userIds) {
    await dependencies.writeJobOpenings(userId, kept, now);
  }
  logger.info('Wrote job openings', {
    users: userIds.length,
    openings: kept.length,
  });

  return {
    userCount: userIds.length,
    fetchedCount: openings.length,
    staleCount: openings.length - fresh.length,
    otherRegionCount: fresh.length - inRegion.length,
    otherRoleCount: inRegion.length - relevant.length,
    matchedCount: matched.length,
    scoredCount: scored.length,
    failedScoreCount: failedCount,
    keptCount: kept.length,
    failedSources,
  };
}

async function scoreOpenings(
  openings: MatchedJobOpening[],
  profile: PortfolioProfile,
  { scorer, logger, now }: SyncDependencies,
): Promise<{ scored: ScoredJobOpening[]; failedCount: number }> {
  const deadline = now().getTime() + scoringTimeLimitMs;
  const results = await settleAll(openings, scoringConcurrency, (opening) => {
    if (now().getTime() >= deadline) {
      throw new Error('Skipped: the scoring time limit was reached');
    }
    return scorer.score(opening, profile);
  });
  const scored: ScoredJobOpening[] = [];
  results.forEach((result, index) => {
    const opening = openings[index];
    if (result.status === 'rejected') {
      logger.warn('Scoring a job opening failed', {
        dedupeKey: opening.dedupeKey,
        error: String(result.reason),
      });
      return;
    }
    const fit = result.value;
    scored.push({
      ...opening,
      // Gemini also finds skills the job names differently, such as Compose
      // for Jetpack Compose. Both lists hold portfolio spellings only.
      matchedSkills: mergeSkills(opening.matchedSkills, fit.matchedSkills),
      score: fit.score,
      missingSkills: fit.missingSkills,
      reasons: fit.reasons,
    });
  });
  const failedCount = openings.length - scored.length;
  if (openings.length > 0 && failedCount === openings.length) {
    throw new Error(`Every job score failed (${failedCount} openings)`);
  }
  return { scored, failedCount };
}

type CandidateOpening = MatchedJobOpening & { isRoleMatch: boolean };

/** Role matches first, then by matched skills, then newest first. */
function byBestKeywordMatch(a: CandidateOpening, b: CandidateOpening) {
  return (
    Number(b.isRoleMatch) - Number(a.isRoleMatch) ||
    b.matchedSkills.length - a.matchedSkills.length ||
    b.publishedAt.getTime() - a.publishedAt.getTime()
  );
}

function mergeSkills(keyword: string[], gemini: string[]): string[] {
  const seen = new Set(keyword.map((skill) => skill.toLowerCase()));
  return [
    ...keyword,
    ...gemini.filter((skill) => !seen.has(skill.toLowerCase())),
  ];
}
