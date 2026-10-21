import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import type { JobFeed } from './job_feed.js';

/**
 * The latest remote jobs from the Remote OK API, which cannot search.
 *
 * Remote OK's terms: link back to the job's Remote OK URL and mention Remote
 * OK as the source; do not use its logo. Every opening keeps the Remote OK
 * `url` and `sourceName`.
 */
export class RemoteOkFeed implements JobFeed {
  static readonly url = 'https://remoteok.com/api';

  readonly source = 'remoteok' as const;

  constructor(private readonly fetchJson: FetchJson) {}

  async fetchJobs(): Promise<JobOpening[]> {
    const body = await this.fetchJson(RemoteOkFeed.url);
    if (!Array.isArray(body)) {
      throw new Error('Remote OK response is not a list');
    }
    // The first entry is the API's legal notice, which has no job fields.
    return body.flatMap((job) => {
      const opening = toJobOpening(job);
      return opening === null ? [] : [opening];
    });
  }
}

function toJobOpening(job: unknown): JobOpening | null {
  if (!isRecord(job)) return null;
  const id = stringOrNull(job.id);
  const title = stringOrNull(job.position);
  const company = stringOrNull(job.company);
  const url = stringOrNull(job.url);
  const publishedAt = parseDate(job.date);
  if (!id || !title || !company || !url || !publishedAt) return null;

  return {
    source: 'remoteok',
    sourceName: 'Remote OK',
    sourceId: id,
    title,
    company,
    url,
    location: stringOrNull(job.location),
    tags: stringList(job.tags),
    jobTypes: [],
    description: htmlToText(
      typeof job.description === 'string' ? job.description : '',
    ),
    publishedAt,
  };
}

function parseDate(value: unknown): Date | null {
  const text = stringOrNull(value);
  if (!text) return null;
  const date = new Date(text);
  return Number.isNaN(date.getTime()) ? null : date;
}
