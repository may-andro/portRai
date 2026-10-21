import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import type { JobFeed, JobSearchQuery } from './job_feed.js';

/**
 * Remote jobs from Jobicy's public API, by tag, for each search term.
 *
 * Jobicy's terms: credit Jobicy with a direct link to the source, and send
 * every apply button to the original job URL from the feed. Every opening
 * keeps the Jobicy `url` and `sourceName`.
 */
export class JobicyFeed implements JobFeed {
  static readonly url = 'https://jobicy.com/api/v2/remote-jobs';

  readonly source = 'jobicy' as const;

  constructor(
    private readonly fetchJson: FetchJson,
    private readonly jobsPerTerm = 50,
  ) {}

  async fetchJobs(query: JobSearchQuery): Promise<JobOpening[]> {
    const openings: JobOpening[] = [];
    for (const term of query.terms) {
      const body = await this.fetchJson(
        `${JobicyFeed.url}?count=${this.jobsPerTerm}&tag=${encodeURIComponent(term.toLowerCase())}`,
      );
      if (!isRecord(body)) {
        throw new Error(`Jobicy tag "${term}" returned no object`);
      }
      // A tag without jobs comes back without a jobs list.
      const jobs = Array.isArray(body.jobs) ? body.jobs : [];
      for (const job of jobs) {
        const opening = toJobOpening(job);
        if (opening !== null) openings.push(opening);
      }
    }
    return openings;
  }
}

function toJobOpening(job: unknown): JobOpening | null {
  if (!isRecord(job)) return null;
  const id = typeof job.id === 'number' ? String(job.id) : stringOrNull(job.id);
  const title = stringOrNull(job.jobTitle);
  const company = stringOrNull(job.companyName);
  const url = stringOrNull(job.url);
  const publishedAt = parseDate(job.pubDate);
  if (!id || !title || !company || !url || !publishedAt) return null;

  const level = stringOrNull(job.jobLevel);
  return {
    source: 'jobicy',
    sourceName: 'Jobicy',
    sourceId: id,
    title,
    company,
    url,
    location: stringOrNull(job.jobGeo),
    tags: [...(level ? [level] : []), ...stringList(job.jobIndustry)],
    jobTypes: stringList(job.jobType),
    description: htmlToText(
      typeof job.jobDescription === 'string' ? job.jobDescription : '',
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
