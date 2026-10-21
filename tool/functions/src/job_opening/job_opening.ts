/** Where a job opening was found. */
export type JobSource = 'remotive' | 'arbeitnow';

/** A job opening in the one shape every feed is mapped to. */
export interface JobOpening {
  source: JobSource;
  /** The source's display name, shown next to the job as its attribution. */
  sourceName: string;
  sourceId: string;
  title: string;
  company: string;
  /** The job page on the source site. Applying and attribution both link here. */
  url: string;
  location: string | null;
  tags: string[];
  jobTypes: string[];
  /** Plain text, without the source's HTML. */
  description: string;
  publishedAt: Date;
}

/** A job opening that matched enough of the portfolio skills to be kept. */
export interface MatchedJobOpening extends JobOpening {
  /** Stable across weeks and feeds, so the same job keeps one document. */
  dedupeKey: string;
  matchedSkills: string[];
}
