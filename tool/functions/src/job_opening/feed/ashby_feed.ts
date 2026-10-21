import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringOrNull } from '../../shared/json_value.js';
import type { JobOpening } from '../job_opening.js';
import {
  type BoardErrorHandler,
  type BoardPosting,
  type CompanyBoard,
  fetchCompanyBoards,
  parseDate,
} from './company_board.js';
import { htmlToText } from './html_text.js';
import type { JobFeed, JobSearchQuery } from './job_feed.js';

const remotePattern = /\bremote\b/i;

/**
 * Remote roles from companies' public Ashby job boards. A posting counts as
 * remote when its workplace type or one of its locations says so; Ashby's
 * `isRemote` flag is also set for office roles.
 */
export class AshbyFeed implements JobFeed {
  static readonly url = 'https://api.ashbyhq.com/posting-api/job-board';

  readonly source = 'ashby' as const;

  constructor(
    private readonly fetchJson: FetchJson,
    private readonly boards: CompanyBoard[],
    private readonly onBoardError?: BoardErrorHandler,
  ) {}

  fetchJobs(query: JobSearchQuery): Promise<JobOpening[]> {
    return fetchCompanyBoards(
      this.boards,
      query,
      (board) => this.listPostings(board),
      this.onBoardError,
    );
  }

  private async listPostings(board: CompanyBoard): Promise<BoardPosting[]> {
    const body = await this.fetchJson(
      `${AshbyFeed.url}/${encodeURIComponent(board.slug)}`,
    );
    if (!isRecord(body) || !Array.isArray(body.jobs)) {
      throw new Error(`Ashby board "${board.slug}" returned no jobs list`);
    }
    return body.jobs.flatMap((job): BoardPosting[] => {
      if (!isRecord(job) || job.isListed === false) return [];
      const title = stringOrNull(job.title)?.trim();
      if (!title) return [];
      const location = locationsOf(job);
      return [
        {
          title,
          location,
          isRemote:
            job.workplaceType === 'Remote' ||
            remotePattern.test(location ?? ''),
          toJobOpening: () =>
            Promise.resolve(toJobOpening(board, job, title, location)),
        },
      ];
    });
  }
}

/** The main location followed by the secondary ones, or null. */
function locationsOf(job: Record<string, unknown>): string | null {
  const secondaryLocations = Array.isArray(job.secondaryLocations)
    ? job.secondaryLocations.flatMap((location) =>
        isRecord(location) && typeof location.location === 'string'
          ? [location.location]
          : [],
      )
    : [];
  const locations = [stringOrNull(job.location), ...secondaryLocations].filter(
    (location): location is string => Boolean(location),
  );
  return locations.length > 0 ? [...new Set(locations)].join(', ') : null;
}

function toJobOpening(
  board: CompanyBoard,
  job: Record<string, unknown>,
  title: string,
  location: string | null,
): JobOpening | null {
  const id = stringOrNull(job.id);
  const url = stringOrNull(job.jobUrl);
  const publishedAt = parseDate(job.publishedAt);
  if (!id || !url || !publishedAt) return null;
  const employmentType = stringOrNull(job.employmentType);
  const tags = [stringOrNull(job.department), stringOrNull(job.team)].filter(
    (tag): tag is string => Boolean(tag),
  );
  return {
    source: 'ashby',
    sourceName: board.name,
    sourceId: `${board.slug}:${id}`,
    title,
    company: board.name,
    url,
    location,
    tags: [...new Set(tags)],
    // `FullTime` as `Full Time`.
    jobTypes: employmentType
      ? [employmentType.replace(/([a-z])([A-Z])/g, '$1 $2')]
      : [],
    description: htmlToText(
      typeof job.descriptionHtml === 'string' ? job.descriptionHtml : '',
    ),
    publishedAt,
  };
}
