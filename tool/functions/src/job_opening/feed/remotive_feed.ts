import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import { isWantedJob, type JobFeed, type JobSearchQuery } from './job_feed.js';

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

  async fetchJobs(query: JobSearchQuery): Promise<JobOpening[]> {
    const body = await this.fetchJson(RemotiveFeed.url);
    if (!isRecord(body) || !Array.isArray(body.jobs)) {
      throw new Error('Remotive response has no jobs list');
    }
    return body.jobs.flatMap((job) => {
      const opening = toJobOpening(job, query);
      return opening === null ? [] : [opening];
    });
  }
}

/** The opening for [job], or null when it is invalid or [query] drops it. */
function toJobOpening(job: unknown, query: JobSearchQuery): JobOpening | null {
  if (!isRecord(job)) return null;
  const id = typeof job.id === 'number' ? String(job.id) : stringOrNull(job.id);
  const title = stringOrNull(job.title);
  const company = stringOrNull(job.company_name);
  const url = stringOrNull(job.url);
  const publishedAt = parsePublicationDate(job.publication_date);
  if (!id || !title || !company || !url || !publishedAt) return null;
  const location = stringOrNull(job.candidate_required_location);
  const jobType = stringOrNull(job.job_type);
  const jobTypes = jobType ? [jobType] : [];
  if (!isWantedJob(query, { title, location, jobTypes, publishedAt })) {
    return null;
  }

  return {
    source: 'remotive',
    sourceName: 'Remotive',
    sourceId: id,
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

/** Remotive dates have no zone, for example `2026-10-17T16:04:29`; they are UTC. */
function parsePublicationDate(value: unknown): Date | null {
  const text = stringOrNull(value);
  if (!text) return null;
  const hasZone = /(z|[+-]\d{2}:?\d{2})$/i.test(text);
  const date = new Date(hasZone ? text : `${text}Z`);
  return Number.isNaN(date.getTime()) ? null : date;
}
