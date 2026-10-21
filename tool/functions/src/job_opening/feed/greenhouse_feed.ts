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
import { decodeHtmlEntities, htmlToText } from './html_text.js';
import type { JobFeed, JobSearchQuery } from './job_feed.js';

const remotePattern = /\bremote\b/i;

/**
 * Remote roles from companies' public Greenhouse job boards. The list comes
 * without descriptions, so only the postings kept are read in full.
 */
export class GreenhouseFeed implements JobFeed {
  static readonly url = 'https://boards-api.greenhouse.io/v1/boards';

  readonly source = 'greenhouse' as const;

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
    const boardUrl = `${GreenhouseFeed.url}/${encodeURIComponent(board.slug)}/jobs`;
    const body = await this.fetchJson(boardUrl);
    if (!isRecord(body) || !Array.isArray(body.jobs)) {
      throw new Error(`Greenhouse board "${board.slug}" returned no jobs list`);
    }
    return body.jobs.flatMap((job): BoardPosting[] => {
      if (!isRecord(job) || typeof job.id !== 'number') return [];
      const title = stringOrNull(job.title)?.trim();
      if (!title) return [];
      const location = isRecord(job.location)
        ? stringOrNull(job.location.name)
        : null;
      return [
        {
          title,
          location,
          isRemote: remotePattern.test(location ?? ''),
          toJobOpening: async () =>
            toJobOpening(
              board,
              job,
              title,
              location,
              await this.fetchJson(`${boardUrl}/${job.id}`),
            ),
        },
      ];
    });
  }
}

function toJobOpening(
  board: CompanyBoard,
  job: Record<string, unknown>,
  title: string,
  location: string | null,
  details: unknown,
): JobOpening | null {
  const url = stringOrNull(job.absolute_url);
  const publishedAt =
    parseDate(job.first_published) ?? parseDate(job.updated_at);
  if (!url || !publishedAt) return null;

  // Greenhouse escapes the description's HTML.
  const content =
    isRecord(details) && typeof details.content === 'string'
      ? decodeHtmlEntities(details.content)
      : '';
  const departments =
    isRecord(details) && Array.isArray(details.departments)
      ? details.departments.flatMap((department) =>
          isRecord(department) && typeof department.name === 'string'
            ? [department.name]
            : [],
        )
      : [];
  return {
    source: 'greenhouse',
    sourceName: board.name,
    sourceId: `${board.slug}:${String(job.id)}`,
    title,
    company: board.name,
    url,
    location,
    tags: departments,
    jobTypes: [],
    description: htmlToText(content),
    publishedAt,
  };
}
