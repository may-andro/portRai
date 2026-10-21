import type { JobOpening, JobSource } from '../job_opening.js';

export interface JobFeed {
  readonly source: JobSource;
  fetchJobs(): Promise<JobOpening[]>;
}
