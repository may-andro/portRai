import type { JobFeed } from './feed/job_feed.js';
import type { JobOpening, MatchedJobOpening } from './job_opening.js';
import { dedupeJobOpenings } from './match/dedupe.js';
import { SkillMatcher } from './match/skill_matcher.js';

export interface SyncLogger {
  info(message: string, data?: object): void;
  warn(message: string, data?: object): void;
}

export interface SyncDependencies {
  feeds: JobFeed[];
  listUserIds(): Promise<string[]>;
  loadSkills(): Promise<string[]>;
  writeJobOpenings(
    userId: string,
    openings: MatchedJobOpening[],
    now: Date,
  ): Promise<void>;
  now(): Date;
  logger: SyncLogger;
}

export interface SyncResult {
  userCount: number;
  fetchedCount: number;
  matchedCount: number;
  failedSources: string[];
}

/**
 * Fetches every feed, keeps the openings that match the portfolio skills and
 * writes them for each user with job search on. A feed that fails is skipped;
 * the run fails only when every feed fails.
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

  const now = dependencies.now();
  for (const userId of userIds) {
    await dependencies.writeJobOpenings(userId, matched, now);
  }
  logger.info('Wrote job openings', {
    users: userIds.length,
    openings: matched.length,
  });

  return {
    userCount: userIds.length,
    fetchedCount: openings.length,
    matchedCount: matched.length,
    failedSources,
  };
}
