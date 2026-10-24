import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import { isWantedJob, type JobFeed, type JobSearchQuery } from './job_feed.js';

/**
 * Remote jobs from Arbeitnow's public job board API.
 *
 * The API needs no key. Its terms ask not to abuse it and to link back to the
 * site, so this reads a few pages once a week and every opening keeps its
 * Arbeitnow `url`. Only jobs marked remote are kept. A page that fails ends
 * the read and keeps the pages read before it; the feed fails only when the
 * first page fails.
 */
export class ArbeitnowFeed implements JobFeed {
  static readonly url = 'https://www.arbeitnow.com/api/job-board-api';

  readonly source = 'arbeitnow' as const;

  constructor(
    private readonly fetchJson: FetchJson,
    private readonly maxPages = 5,
  ) {}

  async fetchJobs(query: JobSearchQuery): Promise<JobOpening[]> {
    const openings: JobOpening[] = [];
    for (let page = 1; page <= this.maxPages; page++) {
      let body: { data: unknown[]; hasNextPage: boolean };
      try {
        body = await this.readPage(page);
      } catch (error) {
        if (page === 1) throw error;
        break;
      }
      for (const job of body.data) {
        const opening = toJobOpening(job, query);
        if (opening !== null) openings.push(opening);
      }
      if (!body.hasNextPage || body.data.length === 0) break;
    }
    return openings;
  }

  private async readPage(
    page: number,
  ): Promise<{ data: unknown[]; hasNextPage: boolean }> {
    const body = await this.fetchJson(`${ArbeitnowFeed.url}?page=${page}`);
    if (!isRecord(body) || !Array.isArray(body.data)) {
      throw new Error(`Arbeitnow page ${page} has no data list`);
    }
    return {
      data: body.data,
      hasNextPage: isRecord(body.links) && Boolean(body.links.next),
    };
  }
}

/** The opening for [job], or null when it is invalid or [query] drops it. */
function toJobOpening(job: unknown, query: JobSearchQuery): JobOpening | null {
  if (!isRecord(job) || job.remote !== true) return null;
  const slug = stringOrNull(job.slug);
  const title = stringOrNull(job.title);
  const company = stringOrNull(job.company_name);
  const url = stringOrNull(job.url);
  const publishedAt =
    typeof job.created_at === 'number' && Number.isFinite(job.created_at)
      ? new Date(job.created_at * 1000)
      : null;
  if (!slug || !title || !company || !url || !publishedAt) return null;
  const location = stringOrNull(job.location);
  const jobTypes = stringList(job.job_types);
  if (!isWantedJob(query, { title, location, jobTypes, publishedAt })) {
    return null;
  }

  return {
    source: 'arbeitnow',
    sourceName: 'Arbeitnow',
    sourceId: slug,
    title,
    company,
    url,
    location,
    tags: stringList(job.tags),
    jobTypes,
    description: htmlToText(
      typeof job.description === 'string' ? job.description : '',
    ),
    publishedAt,
  };
}
