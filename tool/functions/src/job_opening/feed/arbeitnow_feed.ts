import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import type { JobFeed } from './job_feed.js';

/**
 * Remote jobs from Arbeitnow's public job board API.
 *
 * The API needs no key. Its terms ask not to abuse it and to link back to the
 * site, so this reads a few pages once a week and every opening keeps its
 * Arbeitnow `url`. Only jobs marked remote are kept.
 */
export class ArbeitnowFeed implements JobFeed {
  static readonly url = 'https://www.arbeitnow.com/api/job-board-api';

  readonly source = 'arbeitnow' as const;

  constructor(
    private readonly fetchJson: FetchJson,
    private readonly maxPages = 5,
  ) {}

  async fetchJobs(): Promise<JobOpening[]> {
    const openings: JobOpening[] = [];
    for (let page = 1; page <= this.maxPages; page++) {
      const body = await this.fetchJson(`${ArbeitnowFeed.url}?page=${page}`);
      if (!isRecord(body) || !Array.isArray(body.data)) {
        throw new Error(`Arbeitnow page ${page} has no data list`);
      }
      for (const job of body.data) {
        const opening = toJobOpening(job);
        if (opening !== null) openings.push(opening);
      }
      const hasNextPage = isRecord(body.links) && Boolean(body.links.next);
      if (!hasNextPage || body.data.length === 0) break;
    }
    return openings;
  }
}

function toJobOpening(job: unknown): JobOpening | null {
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

  return {
    source: 'arbeitnow',
    sourceName: 'Arbeitnow',
    sourceId: slug,
    title,
    company,
    url,
    location: stringOrNull(job.location),
    tags: stringList(job.tags),
    jobTypes: stringList(job.job_types),
    description: htmlToText(
      typeof job.description === 'string' ? job.description : '',
    ),
    publishedAt,
  };
}
