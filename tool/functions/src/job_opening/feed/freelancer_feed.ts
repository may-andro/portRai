import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringOrNull } from '../../shared/json_value.js';
import { settleAll } from '../../shared/settle_all.js';
import type { JobOpening } from '../job_opening.js';
import { isWantedJob, type JobFeed, type JobSearchQuery } from './job_feed.js';

/** Terms searched at the same time. */
const termConcurrency = 2;

const dayMilliseconds = 24 * 60 * 60 * 1000;

/** The smallest budgets kept, in US dollars. */
export interface FreelancerBudgetFloor {
  /** For a fixed-price project, its whole budget. */
  fixed: number;
  /** For an hourly project, its rate per hour. */
  hourly: number;
}

/**
 * Remote projects from Freelancer.com's public projects API, searched for
 * each term. Only projects whose highest budget, in US dollars, reaches
 * [budgetFloor] are kept. A term that fails is skipped; the feed fails only
 * when every term fails.
 *
 * Freelancer.com's API terms ask for cached data to be refreshed at least
 * every 24 hours, so every opening expires when the project's bidding closes.
 * Every opening keeps the Freelancer.com project `url` and `sourceName`.
 */
export class FreelancerFeed implements JobFeed {
  static readonly url =
    'https://www.freelancer.com/api/projects/0.1/projects/active/';

  static projectUrl(seoUrl: string): string {
    return `https://www.freelancer.com/projects/${seoUrl}`;
  }

  readonly source = 'freelancer' as const;

  constructor(
    private readonly fetchJson: FetchJson,
    private readonly budgetFloor: FreelancerBudgetFloor = {
      fixed: 1000,
      hourly: 30,
    },
    private readonly projectsPerTerm = 100,
  ) {}

  async fetchJobs(query: JobSearchQuery): Promise<JobOpening[]> {
    const results = await settleAll(query.terms, termConcurrency, (term) =>
      this.search(term),
    );
    const rejected = results.find(
      (result): result is PromiseRejectedResult => result.status === 'rejected',
    );
    if (rejected && results.every((result) => result.status === 'rejected')) {
      throw rejected.reason;
    }
    return results.flatMap((result) =>
      result.status === 'fulfilled'
        ? result.value.flatMap((project) => {
            const opening = toJobOpening(project, query, this.budgetFloor);
            return opening === null ? [] : [opening];
          })
        : [],
    );
  }

  private async search(term: string): Promise<unknown[]> {
    const body = await this.fetchJson(
      `${FreelancerFeed.url}?query=${encodeURIComponent(term)}&limit=${this.projectsPerTerm}&job_details=true&full_description=true`,
    );
    if (
      !isRecord(body) ||
      !isRecord(body.result) ||
      !Array.isArray(body.result.projects)
    ) {
      throw new Error(`Freelancer.com term "${term}" has no projects list`);
    }
    return body.result.projects;
  }
}

/**
 * The opening for [project], or null when it is invalid, on site, below
 * [budgetFloor] or [query] drops it.
 */
function toJobOpening(
  project: unknown,
  query: JobSearchQuery,
  budgetFloor: FreelancerBudgetFloor,
): JobOpening | null {
  if (!isRecord(project) || project.local === true) return null;
  const id = typeof project.id === 'number' ? String(project.id) : null;
  const title = stringOrNull(project.title);
  const seoUrl = stringOrNull(project.seo_url);
  const publishedAt = secondsToDate(project.time_submitted);
  if (!id || !title || !seoUrl || !publishedAt) return null;
  const hourly = project.type === 'hourly';
  const highestBudget = highestBudgetInDollars(project);
  if (
    highestBudget === null ||
    highestBudget < (hourly ? budgetFloor.hourly : budgetFloor.fixed)
  ) {
    return null;
  }
  const jobTypes = ['Freelance', hourly ? 'Hourly' : 'Fixed price'];
  if (!isWantedJob(query, { title, location: null, jobTypes, publishedAt })) {
    return null;
  }

  const bidDays = project.bidperiod;
  return {
    source: 'freelancer',
    sourceName: 'Freelancer.com',
    sourceId: id,
    title,
    // Projects do not name their client.
    company: 'Freelancer.com client',
    url: FreelancerFeed.projectUrl(seoUrl),
    location: null,
    tags: Array.isArray(project.jobs)
      ? project.jobs.flatMap((job) => {
          const name = isRecord(job) ? stringOrNull(job.name) : null;
          return name ? [name] : [];
        })
      : [],
    jobTypes,
    description:
      typeof project.description === 'string' ? project.description.trim() : '',
    publishedAt,
    ...(typeof bidDays === 'number' && bidDays > 0
      ? {
          expiresAt: new Date(
            publishedAt.getTime() + bidDays * dayMilliseconds,
          ),
        }
      : {}),
  };
}

/**
 * The project's highest budget, or its lowest when it has no highest, in US
 * dollars by the currency's `exchange_rate`; null without a budget or rate.
 */
function highestBudgetInDollars(
  project: Record<string, unknown>,
): number | null {
  const budget = isRecord(project.budget) ? project.budget : {};
  const amount =
    typeof budget.maximum === 'number' ? budget.maximum : budget.minimum;
  const rate = isRecord(project.currency)
    ? project.currency.exchange_rate
    : null;
  if (typeof amount !== 'number' || typeof rate !== 'number') return null;
  return amount * rate;
}

function secondsToDate(value: unknown): Date | null {
  return typeof value === 'number' && Number.isFinite(value)
    ? new Date(value * 1000)
    : null;
}
