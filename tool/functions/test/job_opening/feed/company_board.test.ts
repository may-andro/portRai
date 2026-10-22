import { describe, expect, it, vi } from 'vitest';

import {
  type BoardPosting,
  type CompanyBoard,
  companyBoardsLoader,
  defaultCompanyBoards,
  fetchCompanyBoards,
  loadCompanyBoards,
  maxOpeningsPerBoard,
} from '../../../src/job_opening/feed/company_board.js';
import type { JobOpening } from '../../../src/job_opening/job_opening.js';
import { searchQuery } from '../fixture.js';

const board: CompanyBoard = {
  system: 'greenhouse',
  slug: 'acme',
  name: 'Acme',
};

function posting(
  title: string,
  {
    isRemote = true,
    location = 'Remote' as string | null,
    publishedAt = new Date('2026-10-20T00:00:00Z') as Date | null,
  } = {},
): BoardPosting {
  return {
    title,
    location,
    isRemote,
    publishedAt,
    toJobOpening: vi.fn(() =>
      Promise.resolve<JobOpening>({
        source: 'greenhouse',
        sourceName: 'Acme',
        sourceId: title,
        title,
        company: 'Acme',
        url: 'https://example.com',
        location,
        tags: [],
        jobTypes: [],
        description: '',
        publishedAt: publishedAt ?? new Date(0),
      }),
    ),
  };
}

describe('loadCompanyBoards', () => {
  it('should use the default boards when the document does not exist', async () => {
    const boards = await loadCompanyBoards(vi.fn().mockResolvedValue(null));

    expect(boards).toBe(defaultCompanyBoards);
  });

  it('should read the boards from the company boards document', async () => {
    const readDocument = vi.fn().mockResolvedValue({
      boards: [
        { system: 'lever', slug: ' qonto ', name: 'Qonto' },
        { system: 'ashby', slug: 'ramp' },
        { system: 'workday', slug: 'acme', name: 'Acme' },
        { system: 'greenhouse', name: 'No slug' },
        'not a board',
      ],
    });

    const boards = await loadCompanyBoards(readDocument);

    expect(readDocument).toHaveBeenCalledWith('job_search', 'company_boards');
    expect(boards).toEqual([
      { system: 'lever', slug: 'qonto', name: 'Qonto' },
      { system: 'ashby', slug: 'ramp', name: 'ramp' },
    ]);
  });

  it('should turn the boards off with an empty list', async () => {
    const boards = await loadCompanyBoards(
      vi.fn().mockResolvedValue({ boards: [] }),
    );

    expect(boards).toEqual([]);
  });
});

describe('companyBoardsLoader', () => {
  it('should read the company list once and give each system its boards', async () => {
    const readDocument = vi.fn().mockResolvedValue({
      boards: [
        { system: 'greenhouse', slug: 'reddit', name: 'Reddit' },
        { system: 'lever', slug: 'qonto', name: 'Qonto' },
      ],
    });
    const loadBoards = companyBoardsLoader(readDocument);

    const [greenhouseBoards, leverBoards, ashbyBoards] = await Promise.all([
      loadBoards('greenhouse'),
      loadBoards('lever'),
      loadBoards('ashby'),
    ]);

    expect(readDocument).toHaveBeenCalledTimes(1);
    expect(greenhouseBoards.map((companyBoard) => companyBoard.slug)).toEqual([
      'reddit',
    ]);
    expect(leverBoards.map((companyBoard) => companyBoard.slug)).toEqual([
      'qonto',
    ]);
    expect(ashbyBoards).toEqual([]);
  });

  it('should not read the company list before a board feed asks for it', () => {
    const readDocument = vi.fn();

    companyBoardsLoader(readDocument);

    expect(readDocument).not.toHaveBeenCalled();
  });
});

describe('fetchCompanyBoards', () => {
  const query = searchQuery({ terms: ['Android', 'Mobile'] });

  it('should keep remote postings whose title names a search term', async () => {
    const openings = await fetchCompanyBoards([board], query, () =>
      Promise.resolve([
        posting('Senior Android Engineer'),
        posting('Mobile Engineer', { isRemote: false }),
        posting('Backend Engineer'),
      ]),
    );

    expect(openings.map((opening) => opening.title)).toEqual([
      'Senior Android Engineer',
    ]);
  });

  it('should merge one job posted for several locations', async () => {
    const openings = await fetchCompanyBoards([board], query, () =>
      Promise.resolve([
        posting('Android Engineer', { location: 'Remote Spain' }),
        posting('Android  engineer', { location: 'Remote Netherlands' }),
        posting('Android Engineer', { location: 'Remote Spain' }),
      ]),
    );

    expect(openings).toHaveLength(1);
    expect(openings[0].location).toBe('Remote Spain · Remote Netherlands');
  });

  it('should keep at most the per-board limit', async () => {
    const openings = await fetchCompanyBoards([board], query, () =>
      Promise.resolve(
        Array.from({ length: maxOpeningsPerBoard + 5 }, (_, index) =>
          posting(`Android Engineer ${index}`),
        ),
      ),
    );

    expect(openings).toHaveLength(maxOpeningsPerBoard);
  });

  it('should report and skip a failing board', async () => {
    const onBoardError = vi.fn();
    const failing: CompanyBoard = { ...board, slug: 'gone' };

    const openings = await fetchCompanyBoards(
      [failing, board],
      query,
      (current) =>
        current.slug === 'gone'
          ? Promise.reject(new Error('404'))
          : Promise.resolve([posting('Android Engineer')]),
      onBoardError,
    );

    expect(openings).toHaveLength(1);
    expect(onBoardError).toHaveBeenCalledWith(failing, expect.any(Error));
  });

  it('should fail when every board fails', async () => {
    await expect(
      fetchCompanyBoards([board], query, () =>
        Promise.reject(new Error('down')),
      ),
    ).rejects.toThrow('Every company board failed');
  });

  it('should return nothing without boards', async () => {
    const listPostings = vi.fn();

    expect(await fetchCompanyBoards([], query, listPostings)).toEqual([]);
    expect(listPostings).not.toHaveBeenCalled();
  });

  it('should drop stale, other-region and other-role postings before reading them', async () => {
    const stale = posting('Android Engineer, Payments', {
      publishedAt: new Date('2026-08-01T00:00:00Z'),
    });
    const undated = posting('Android Engineer, Growth', { publishedAt: null });
    const otherRegion = posting('Android Engineer, Search', {
      location: 'Remote - USA',
    });
    const otherRole = posting('Product Manager, Android');
    const wanted = posting('Android Engineer', { location: 'Remote Spain' });

    const openings = await fetchCompanyBoards(
      [board],
      searchQuery({
        terms: ['Android'],
        publishedAfter: new Date('2026-09-19T00:00:00Z'),
        regions: new Set(['europe']),
        roles: ['Senior Android Developer'],
      }),
      () => Promise.resolve([stale, undated, otherRegion, otherRole, wanted]),
    );

    expect(openings.map((opening) => opening.title)).toEqual([
      'Android Engineer',
    ]);
    for (const dropped of [stale, undated, otherRegion, otherRole]) {
      expect(dropped.toJobOpening).not.toHaveBeenCalled();
    }
  });

  it('should not let dropped postings use up the per-board limit', async () => {
    const openings = await fetchCompanyBoards(
      [board],
      searchQuery({ terms: ['Android'], regions: new Set(['europe']) }),
      () =>
        Promise.resolve([
          ...Array.from({ length: maxOpeningsPerBoard }, (_, index) =>
            posting(`Android Engineer US ${index}`, {
              location: 'Remote - USA',
            }),
          ),
          posting('Android Engineer', { location: 'Remote Spain' }),
        ]),
    );

    expect(openings.map((opening) => opening.title)).toEqual([
      'Android Engineer',
    ]);
  });

  it('should start the next board as soon as one finishes', async () => {
    const boards = Array.from({ length: 6 }, (_, index) => ({
      ...board,
      slug: `board-${index}`,
    }));
    let finishSlowBoard: (postings: BoardPosting[]) => void = () => {};
    const listPostings = vi.fn((current: CompanyBoard) =>
      current.slug === 'board-0'
        ? new Promise<BoardPosting[]>((resolve) => {
            finishSlowBoard = resolve;
          })
        : Promise.resolve([posting(`Android Engineer ${current.slug}`)]),
    );

    const fetching = fetchCompanyBoards(boards, query, listPostings);
    await vi.waitFor(() => expect(listPostings).toHaveBeenCalledTimes(6));
    finishSlowBoard([posting('Android Engineer board-0')]);
    const openings = await fetching;

    expect(openings.map((opening) => opening.title)).toEqual(
      boards.map((current) => `Android Engineer ${current.slug}`),
    );
  });
});
