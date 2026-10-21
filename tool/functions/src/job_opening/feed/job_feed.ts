import type { JobOpening, JobSource } from '../job_opening.js';

/** What to search for. Feeds that cannot search ignore it. */
export interface JobSearchQuery {
  terms: string[];
}

export interface JobFeed {
  readonly source: JobSource;
  fetchJobs(query: JobSearchQuery): Promise<JobOpening[]>;
}
