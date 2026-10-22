import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
import { settleAll } from '../../shared/settle_all.js';
import type { JobOpening } from '../job_opening.js';
import { htmlToText } from './html_text.js';
import { isWantedJob, type JobFeed, type JobSearchQuery } from './job_feed.js';

/** Tags requested at the same time. */
const termConcurrency = 2;

/**
 * Remote jobs from Jobicy's public API, by tag, for each search term. A tag
 * that fails is skipped; the feed fails only when every tag fails.
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
    const results = await settleAll(query.terms, termConcurrency, (term) =>
      this.readTag(term),
    );
    const rejected = results.find(
      (result): result is PromiseRejectedResult => result.status === 'rejected',
    );
    if (rejected && results.every((result) => result.status === 'rejected')) {
      throw rejected.reason;
    }
    return results.flatMap((result) =>
      result.status === 'fulfilled'
        ? result.value.flatMap((job) => {
            const opening = toJobOpening(job, query);
            return opening === null ? [] : [opening];
          })
        : [],
    );
  }

  private async readTag(term: string): Promise<unknown[]> {
    const body = await this.fetchJson(
      `${JobicyFeed.url}?count=${this.jobsPerTerm}&tag=${encodeURIComponent(term.toLowerCase())}`,
    );
    if (!isRecord(body)) {
      throw new Error(`Jobicy tag "${term}" returned no object`);
    }
    // A tag without jobs comes back without a jobs list.
    return Array.isArray(body.jobs) ? body.jobs : [];
  }
}

/** The opening for [job], or null when it is invalid or [query] drops it. */
function toJobOpening(job: unknown, query: JobSearchQuery): JobOpening | null {
  if (!isRecord(job)) return null;
  const id = typeof job.id === 'number' ? String(job.id) : stringOrNull(job.id);
  const title = stringOrNull(job.jobTitle);
  const company = stringOrNull(job.companyName);
  const url = stringOrNull(job.url);
  const publishedAt = parseDate(job.pubDate);
  if (!id || !title || !company || !url || !publishedAt) return null;
  const location = stringOrNull(job.jobGeo);
  if (!isWantedJob(query, { title, location, publishedAt })) return null;

  const level = stringOrNull(job.jobLevel);
  return {
    source: 'jobicy',
    sourceName: 'Jobicy',
    sourceId: id,
    title,
    company,
    url,
    location,
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
