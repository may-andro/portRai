import { settleAll } from '../shared/settle_all.js';
import type { JobFeed } from './feed/job_feed.js';
import type {
  JobOpening,
  MatchedJobOpening,
  ScoredJobOpening,
} from './job_opening.js';
import { dedupeJobOpenings } from './match/dedupe.js';
import { SkillMatcher } from './match/skill_matcher.js';
import type { JobScorer } from './score/job_scorer.js';

/** Openings scoring below this are not stored. */
export const minJobFitScore = 60;

/** Bounds the Gemini calls of one run; the best keyword matches go first. */
export const maxScoredOpenings = 50;

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
  loadSkills(): Promise<string[]>;
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
  matchedCount: number;
  scoredCount: number;
  failedScoreCount: number;
  keptCount: number;
  failedSources: string[];
}

/**
 * Fetches every feed, keeps the openings that match the portfolio skills,
 * scores them with the [JobScorer] and writes the ones scoring at least
 * [minJobFitScore] for each user with job search on. A feed or score that
 * fails is skipped; the run fails only when every feed or every score fails.
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
      matchedCount: 0,
      scoredCount: 0,
      failedScoreCount: 0,
      keptCount: 0,
      failedSources: [],
    };
  }

  const skills = await dependencies.loadSkills();
  if (skills.length === 0) {
    logger.warn('The portfolio has no skills; nothing can match');
    return {
      userCount: userIds.length,
      fetchedCount: 0,
      matchedCount: 0,
      scoredCount: 0,
      failedScoreCount: 0,
      keptCount: 0,
      failedSources: [],
    };
  }

  const feedResults = await Promise.allSettled(
    feeds.map((feed) => feed.fetchJobs()),
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

  const matcher = new SkillMatcher(skills);
  const matched = dedupeJobOpenings(openings).flatMap((opening) => {
    const matchedSkills = matcher.matchedSkills(opening);
    return matcher.isMatch(matchedSkills)
      ? [{ ...opening, matchedSkills }]
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
    candidates,
    skills,
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
    matchedCount: matched.length,
    scoredCount: scored.length,
    failedScoreCount: failedCount,
    keptCount: kept.length,
    failedSources,
  };
}

async function scoreOpenings(
  openings: MatchedJobOpening[],
  skills: string[],
  { scorer, logger, now }: SyncDependencies,
): Promise<{ scored: ScoredJobOpening[]; failedCount: number }> {
  const deadline = now().getTime() + scoringTimeLimitMs;
  const results = await settleAll(openings, scoringConcurrency, (opening) => {
    if (now().getTime() >= deadline) {
      throw new Error('Skipped: the scoring time limit was reached');
    }
    return scorer.score(opening, skills);
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

function byBestKeywordMatch(a: MatchedJobOpening, b: MatchedJobOpening) {
  return (
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
