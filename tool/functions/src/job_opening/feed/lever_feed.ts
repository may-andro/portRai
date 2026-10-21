import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';
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

/** Remote roles from companies' public Lever job boards. */
export class LeverFeed implements JobFeed {
  static readonly url = 'https://api.lever.co/v0/postings';

  readonly source = 'lever' as const;

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
      `${LeverFeed.url}/${encodeURIComponent(board.slug)}?mode=json`,
    );
    if (!Array.isArray(body)) {
      throw new Error(`Lever board "${board.slug}" returned no postings list`);
    }
    return body.flatMap((posting): BoardPosting[] => {
      if (!isRecord(posting)) return [];
      const title = stringOrNull(posting.text)?.trim();
      if (!title) return [];
      const categories = isRecord(posting.categories) ? posting.categories : {};
      const location = stringOrNull(categories.location);
      return [
        {
          title,
          location,
          isRemote:
            posting.workplaceType === 'remote' ||
            remotePattern.test(location ?? ''),
          toJobOpening: () =>
            Promise.resolve(toJobOpening(board, posting, title, location)),
        },
      ];
    });
  }
}

function toJobOpening(
  board: CompanyBoard,
  posting: Record<string, unknown>,
  title: string,
  location: string | null,
): JobOpening | null {
  const id = stringOrNull(posting.id);
  const url = stringOrNull(posting.hostedUrl);
  const publishedAt = parseDate(posting.createdAt);
  if (!id || !url || !publishedAt) return null;

  const categories = isRecord(posting.categories) ? posting.categories : {};
  const lists = Array.isArray(posting.lists)
    ? posting.lists.flatMap((list) =>
        isRecord(list) && typeof list.content === 'string'
          ? [`<p>${String(list.text ?? '')}</p><ul>${list.content}</ul>`]
          : [],
      )
    : [];
  const description = [
    typeof posting.description === 'string' ? posting.description : '',
    ...lists,
    typeof posting.additional === 'string' ? posting.additional : '',
  ].join('\n');
  const commitment = stringOrNull(categories.commitment);
  return {
    source: 'lever',
    sourceName: board.name,
    sourceId: `${board.slug}:${id}`,
    title,
    company: board.name,
    url,
    location,
    tags: [...new Set(stringList([categories.department, categories.team]))],
    jobTypes: commitment ? [commitment] : [],
    description: htmlToText(description),
    publishedAt,
  };
}
