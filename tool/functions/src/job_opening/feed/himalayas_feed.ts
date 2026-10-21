import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import type { JobFeed, JobSearchQuery } from './job_feed.js';

const maxListedLocations = 3;

/**
 * Remote jobs from the Himalayas search API, newest first, for each search
 * term.
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
    const openings: JobOpening[] = [];
    for (const term of query.terms) {
      for (let page = 1; page <= this.maxPagesPerTerm; page++) {
        const body = await this.fetchJson(
          `${HimalayasFeed.url}?q=${encodeURIComponent(term)}&sort=recent&page=${page}`,
        );
        if (!isRecord(body) || !Array.isArray(body.jobs)) {
          throw new Error(
            `Himalayas search "${term}" page ${page} has no jobs list`,
          );
        }
        for (const job of body.jobs) {
          const opening = toJobOpening(job);
          if (opening !== null) openings.push(opening);
        }
        if (body.jobs.length === 0) break;
      }
    }
    return openings;
  }
}

function toJobOpening(job: unknown): JobOpening | null {
  if (!isRecord(job)) return null;
  const id = stringOrNull(job.guid);
  const title = stringOrNull(job.title);
  const company = stringOrNull(job.companyName);
  const url = stringOrNull(job.applicationLink);
  const publishedAt = fromUnixSeconds(job.pubDate);
  if (!id || !title || !company || !url || !publishedAt) return null;

  const employmentType = stringOrNull(job.employmentType);
  return {
    source: 'himalayas',
    sourceName: 'Himalayas',
    sourceId: id,
    title,
    company,
    url,
    location: formatLocations(stringList(job.locationRestrictions)),
    tags: [
      ...stringList(job.seniority),
      ...stringList(job.categories).map((category) =>
        category.replaceAll('-', ' '),
      ),
    ],
    jobTypes: employmentType ? [employmentType] : [],
    description: htmlToText(
      typeof job.description === 'string' ? job.description : '',
    ),
    publishedAt,
    expiresAt: fromUnixSeconds(job.expiryDate) ?? undefined,
  };
}

/** No restriction means the job is open worldwide. */
function formatLocations(locations: string[]): string {
  if (locations.length === 0) return 'Worldwide';
  if (locations.length <= maxListedLocations) return locations.join(', ');
  const listed = locations.slice(0, maxListedLocations).join(', ');
  return `${listed} +${locations.length - maxListedLocations} more`;
}

function fromUnixSeconds(value: unknown): Date | null {
  return typeof value === 'number' && Number.isFinite(value) && value > 0
    ? new Date(value * 1000)
    : null;
}
