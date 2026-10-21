import type { JobOpening, JobSource } from '../job_opening.js';
import { isLocationInRegions, type Region } from '../match/region_filter.js';
import { isPortfolioKindOfRole } from '../match/role_filter.js';

/**
 * What to search for and which jobs the run keeps. Feeds that cannot search
 * ignore [terms]. The run drops jobs published before [publishedAfter], from
 * other [regions] or of another kind of role than [roles] after the feeds
 * return, so a feed may skip them early, before reading their details.
 */
export interface JobSearchQuery {
  terms: string[];
  publishedAfter: Date;
  /** The preferred regions; empty keeps every region. */
  regions: ReadonlySet<Region>;
  /** The portfolio's roles. */
  roles: readonly string[];
}

export interface JobFeed {
  readonly source: JobSource;
  fetchJobs(query: JobSearchQuery): Promise<JobOpening[]>;
}

/**
 * Whether a job with this [title], [location] and [publishedAt] can be kept
 * for [query]: published on or after `publishedAfter`, in one of the
 * preferred regions and the kind of role the portfolio holds.
 */
export function isWantedJob(
  query: JobSearchQuery,
  {
    title,
    location,
    publishedAt,
  }: { title: string; location: string | null; publishedAt: Date },
): boolean {
  return (
    publishedAt >= query.publishedAfter &&
    isLocationInRegions(location, query.regions) &&
    isPortfolioKindOfRole(title, query.roles)
  );
}
