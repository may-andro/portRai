import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import type { JobFeed } from './job_feed.js';

/**
 * Remote software jobs from Remotive's public API.
 *
 * Remotive's terms: link back to the job's Remotive URL, name Remotive as the
 * source, do not pass the jobs on to other job sites, and request the API at
 * most a few times a day. Every opening keeps the Remotive `url` and
 * `sourceName`, and this runs once a week.
 */
export class RemotiveFeed implements JobFeed {
  static readonly url =
    'https://remotive.com/api/remote-jobs?category=software-development';

  readonly source = 'remotive' as const;

  constructor(private readonly fetchJson: FetchJson) {}

  async fetchJobs(): Promise<JobOpening[]> {
    const body = await this.fetchJson(RemotiveFeed.url);
    if (!isRecord(body) || !Array.isArray(body.jobs)) {
      throw new Error('Remotive response has no jobs list');
    }
    return body.jobs.flatMap((job) => {
      const opening = toJobOpening(job);
      return opening === null ? [] : [opening];
    });
  }
}

function toJobOpening(job: unknown): JobOpening | null {
  if (!isRecord(job)) return null;
  const id = typeof job.id === 'number' ? String(job.id) : stringOrNull(job.id);
  const title = stringOrNull(job.title);
  const company = stringOrNull(job.company_name);
  const url = stringOrNull(job.url);
  const publishedAt = parsePublicationDate(job.publication_date);
  if (!id || !title || !company || !url || !publishedAt) return null;

  const jobType = stringOrNull(job.job_type);
  return {
    source: 'remotive',
    sourceName: 'Remotive',
    sourceId: id,
    title,
    company,
    url,
    location: stringOrNull(job.candidate_required_location),
    tags: stringList(job.tags),
    jobTypes: jobType ? [jobType] : [],
    description: htmlToText(
      typeof job.description === 'string' ? job.description : '',
    ),
    publishedAt,
  };
}

/** Remotive dates have no zone, for example `2026-10-17T16:04:29`; they are UTC. */
function parsePublicationDate(value: unknown): Date | null {
  const text = stringOrNull(value);
  if (!text) return null;
  const hasZone = /(z|[+-]\d{2}:?\d{2})$/i.test(text);
  const date = new Date(hasZone ? text : `${text}Z`);
  return Number.isNaN(date.getTime()) ? null : date;
}
