import { settleAll } from '../shared/settle_all.js';
import { withTimeLimit } from '../shared/time_limit.js';
import type { JobFeed } from './feed/job_feed.js';
import type {
  JobFit,
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

/**
 * Bounds the Gemini calls of one run; the best keyword matches go first.
 * Openings with a stored fit from an earlier run do not count.
 */
export const maxScoredOpenings = 120;

/** Openings posted longer ago than this are dropped before matching. */
export const maxJobAgeDays = 30;

const dayMs = 24 * 60 * 60 * 1000;

// Two at a time keeps Gemini from throttling the run.
const scoringConcurrency = 2;

/** A feed still running after this long counts as failed. */
export const feedTimeLimitMs = 4 * 60 * 1000;

/**
 * Scoring stops starting new openings this long after the run starts. A call
 * already running can take 150 s more, which still leaves time for the writes
 * before the function's 15-minute timeout. Skipped openings count as failed.
 */
export const scoringDeadlineMs = 11 * 60 * 1000;

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
  /** The fits stored by earlier runs for [fitKeys], by key. */
  loadJobFits(fitKeys: string[]): Promise<Map<string, JobFit>>;
  saveJobFits(fits: Map<string, JobFit>, now: Date): Promise<void>;
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
  /** Openings Gemini scored in this run. */
  scoredCount: number;
  /** Openings that reused a fit stored by an earlier run. */
  reusedScoreCount: number;
  failedScoreCount: number;
  keptCount: number;
  failedSources: string[];
}

/**
 * Searches every feed for the portfolio's role terms, drops openings older
 * than [maxJobAgeDays], keeps those that match the portfolio's skills or
 * roles, scores them with the [JobScorer], reusing fits stored by earlier
 * runs, and writes the ones scoring at
 * least [minJobFitScore] for each user with job search on. A feed or score
 * that fails is skipped; the run fails only when every feed or every score
 * fails.
 */
export async function syncJobOpenings(
  dependencies: SyncDependencies,
): Promise<SyncResult> {
  const { feeds, logger } = dependencies;
  const startedAt = dependencies.now();
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
      reusedScoreCount: 0,
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
      reusedScoreCount: 0,
      failedScoreCount: 0,
      keptCount: 0,
      failedSources: [],
    };
  }

  const query = { terms: profile.searchTerms };
  logger.info('Searching the job feeds', { terms: query.terms });
  const feedResults = await Promise.allSettled(
    feeds.map((feed) =>
      withTimeLimit(
        feed.fetchJobs(query),
        feedTimeLimitMs,
        `Timed out after ${feedTimeLimitMs / 1000} s`,
      ),
    ),
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

  const ranked = [...matched]
    .sort(byBestKeywordMatch)
    .map(({ isRoleMatch: _, ...opening }): MatchedJobOpening => opening);
  const fitKeys = ranked.map((opening) =>
    dependencies.scorer.fitKey(opening, profile),
  );
  const storedFits = await loadStoredFits(fitKeys, dependencies);
  const reused: ScoredJobOpening[] = [];
  const unscored: FitCandidate[] = [];
  ranked.forEach((opening, index) => {
    const fitKey = fitKeys[index];
    const fit = storedFits.get(fitKey);
    if (fit === undefined) {
      unscored.push({ opening, fitKey });
    } else {
      reused.push(withFit(opening, fit));
    }
  });

  const candidates = unscored.slice(0, maxScoredOpenings);
  logger.info('Scoring job openings', {
    matched: matched.length,
    reused: reused.length,
    toScore: candidates.length,
    skipped: unscored.length - candidates.length,
  });
  const { scored, fits, failedCount } = await scoreOpenings(
    candidates,
    profile,
    startedAt.getTime() + scoringDeadlineMs,
    dependencies,
  );
  if (reused.length === 0 && candidates.length > 0 && scored.length === 0) {
    throw new Error(`Every job score failed (${failedCount} openings)`);
  }
  await saveNewFits(fits, dependencies);
  const kept = [...reused, ...scored].filter(
    (opening) => opening.score >= minJobFitScore,
  );

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
    reusedScoreCount: reused.length,
    failedScoreCount: failedCount,
    keptCount: kept.length,
    failedSources,
  };
}

interface FitCandidate {
  opening: MatchedJobOpening;
  fitKey: string;
}

async function scoreOpenings(
  candidates: FitCandidate[],
  profile: PortfolioProfile,
  deadline: number,
  { scorer, logger, now }: SyncDependencies,
): Promise<{
  scored: ScoredJobOpening[];
  fits: Map<string, JobFit>;
  failedCount: number;
}> {
  const results = await settleAll(
    candidates,
    scoringConcurrency,
    ({ opening }) => {
      if (now().getTime() >= deadline) {
        throw new Error('Skipped: the scoring time limit was reached');
      }
      return scorer.score(opening, profile);
    },
  );
  const scored: ScoredJobOpening[] = [];
  const fits = new Map<string, JobFit>();
  results.forEach((result, index) => {
    const { opening, fitKey } = candidates[index];
    if (result.status === 'rejected') {
      logger.warn('Scoring a job opening failed', {
        dedupeKey: opening.dedupeKey,
        error: String(result.reason),
      });
      return;
    }
    scored.push(withFit(opening, result.value));
    fits.set(fitKey, result.value);
  });
  return { scored, fits, failedCount: candidates.length - scored.length };
}

/** No stored fits when reading them fails, so every opening is scored. */
async function loadStoredFits(
  fitKeys: string[],
  { loadJobFits, logger }: SyncDependencies,
): Promise<Map<string, JobFit>> {
  if (fitKeys.length === 0) return new Map();
  try {
    return await loadJobFits(fitKeys);
  } catch (error) {
    logger.warn('Reading stored job fits failed', { error: String(error) });
    return new Map();
  }
}

/** A failed save only costs the next run new Gemini calls. */
async function saveNewFits(
  fits: Map<string, JobFit>,
  { saveJobFits, logger, now }: SyncDependencies,
): Promise<void> {
  if (fits.size === 0) return;
  try {
    await saveJobFits(fits, now());
  } catch (error) {
    logger.warn('Storing job fits failed', { error: String(error) });
  }
}

function withFit(opening: MatchedJobOpening, fit: JobFit): ScoredJobOpening {
  return {
    ...opening,
    // Gemini also finds skills the job names differently, such as Compose
    // for Jetpack Compose. Both lists hold portfolio spellings only.
    matchedSkills: mergeSkills(opening.matchedSkills, fit.matchedSkills),
    score: fit.score,
    missingSkills: fit.missingSkills,
    reasons: fit.reasons,
  };
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
