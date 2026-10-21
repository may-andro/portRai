/** Where a job opening was found. */
export type JobSource =
  'himalayas' | 'remotive' | 'remoteok' | 'jobicy' | 'hackernews' | 'arbeitnow';

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
  /** When the source stops listing the job, for sources that say. */
  expiresAt?: Date;
}

/** What the job search knows about the portfolio owner. */
export interface PortfolioProfile {
  skills: string[];
  /** The current role, the headline title and past positions. */
  roles: string[];
  /** Words from the roles to search the job boards for, such as Flutter. */
  searchTerms: string[];
  yearsOfExperience: number | null;
}

/** A job opening that matched enough of the portfolio skills to be kept. */
export interface MatchedJobOpening extends JobOpening {
  /** Stable across weeks and feeds, so the same job keeps one document. */
  dedupeKey: string;
  matchedSkills: string[];
}

/** Gemini's view of how well an opening fits the portfolio. */
export interface JobFit {
  /** 0 to 100. */
  score: number;
  /** Portfolio skills the job needs, in their portfolio spelling. */
  matchedSkills: string[];
  /** Skills the job asks for that the portfolio lacks. */
  missingSkills: string[];
  reasons: string[];
}

/** A matched opening with its fit, ready to store. */
export interface ScoredJobOpening extends MatchedJobOpening {
  score: number;
  missingSkills: string[];
  reasons: string[];
}
