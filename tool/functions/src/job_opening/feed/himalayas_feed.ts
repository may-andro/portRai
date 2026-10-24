import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import { settleAll } from '../../shared/settle_all.js';
import type { JobOpening } from '../job_opening.js';
import { type Region, regionsOf } from '../match/region_filter.js';
import { htmlToText } from './html_text.js';
import { isWantedJob, type JobFeed, type JobSearchQuery } from './job_feed.js';

const maxListedLocations = 3;

/** Terms searched at the same time. */
const termConcurrency = 2;

/**
 * Remote jobs from the Himalayas search API, newest first, for each search
 * term. A page that fails ends its term and keeps the pages read before it;
 * the feed fails only when the first page of every term fails.
 *
 * Himalayas' terms: use the job's `applicationLink` unchanged for applying,
 * show Himalayas as the source with a link, do not pass the jobs on to other
 * job boards, and remove jobs once they expire. The opening's `url` is the
 * `applicationLink`, a Himalayas page, and its `expiresAt` is the job's
 * expiry. The data refreshes daily, and this runs once a week.
 */
export class HimalayasFeed implements JobFeed {
  static readonly url = 'https://himalayas.app/jobs/api/search';

  readonly source = 'himalayas' as const;

  constructor(
    private readonly fetchJson: FetchJson,
    private readonly maxPagesPerTerm = 3,
  ) {}

  async fetchJobs(query: JobSearchQuery): Promise<JobOpening[]> {
    const results = await settleAll(query.terms, termConcurrency, (term) =>
      this.searchTerm(term, query),
    );
    const rejected = results.find(
      (result): result is PromiseRejectedResult => result.status === 'rejected',
    );
    if (rejected && results.every((result) => result.status === 'rejected')) {
      throw rejected.reason;
    }
    return results.flatMap((result) =>
      result.status === 'fulfilled' ? result.value : [],
    );
  }

  /**
   * The wanted jobs on the pages of [term], until a page is empty. Throws
   * only when the first page fails.
   */
  private async searchTerm(
    term: string,
    query: JobSearchQuery,
  ): Promise<JobOpening[]> {
    const openings: JobOpening[] = [];
    for (let page = 1; page <= this.maxPagesPerTerm; page++) {
      let jobs: unknown[];
      try {
        jobs = await this.readPage(term, page);
      } catch (error) {
        if (page === 1) throw error;
        break;
      }
      for (const job of jobs) {
        const opening = toJobOpening(job, query);
        if (opening !== null) openings.push(opening);
      }
      if (jobs.length === 0) break;
    }
    return openings;
  }

  private async readPage(term: string, page: number): Promise<unknown[]> {
    const body = await this.fetchJson(
      `${HimalayasFeed.url}?q=${encodeURIComponent(term)}&sort=recent&page=${page}`,
    );
    if (!isRecord(body) || !Array.isArray(body.jobs)) {
      throw new Error(
        `Himalayas search "${term}" page ${page} has no jobs list`,
      );
    }
    return body.jobs;
  }
}

/** The opening for [job], or null when it is invalid or [query] drops it. */
function toJobOpening(job: unknown, query: JobSearchQuery): JobOpening | null {
  if (!isRecord(job)) return null;
  const id = stringOrNull(job.guid);
  const title = stringOrNull(job.title);
  const company = stringOrNull(job.companyName);
  const url = stringOrNull(job.applicationLink);
  const publishedAt = fromUnixSeconds(job.pubDate);
  if (!id || !title || !company || !url || !publishedAt) return null;
  const location = formatLocations(
    stringList(job.locationRestrictions),
    query.regions,
  );
  const employmentType = stringOrNull(job.employmentType);
  const jobTypes = employmentType ? [employmentType] : [];
  if (!isWantedJob(query, { title, location, jobTypes, publishedAt })) {
    return null;
  }
  return {
    source: 'himalayas',
    sourceName: 'Himalayas',
    sourceId: id,
    title,
    company,
    url,
    location,
    tags: [
      ...stringList(job.seniority),
      ...stringList(job.categories).map((category) =>
        category.replaceAll('-', ' '),
      ),
    ],
    jobTypes,
    description: htmlToText(
      typeof job.description === 'string' ? job.description : '',
    ),
    publishedAt,
    expiresAt: fromUnixSeconds(job.expiryDate) ?? undefined,
  };
}

/**
 * No restriction means the job is open worldwide. A long list starts with the
 * places in [regions], so the region filter sees them before `+N more`.
 */
function formatLocations(
  locations: string[],
  regions: ReadonlySet<Region>,
): string {
  if (locations.length === 0) return 'Worldwide';
  if (locations.length <= maxListedLocations) return locations.join(', ');
  const isPreferred = (location: string) =>
    [...regionsOf(location)].some((region) => regions.has(region));
  const ordered = [
    ...locations.filter(isPreferred),
    ...locations.filter((location) => !isPreferred(location)),
  ];
  const listed = ordered.slice(0, maxListedLocations).join(', ');
  return `${listed} +${locations.length - maxListedLocations} more`;
}

function fromUnixSeconds(value: unknown): Date | null {
  return typeof value === 'number' && Number.isFinite(value) && value > 0
    ? new Date(value * 1000)
    : null;
}
