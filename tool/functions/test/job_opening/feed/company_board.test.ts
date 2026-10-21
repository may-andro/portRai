import { describe, expect, it, vi } from 'vitest';

import {
  type BoardPosting,
  type CompanyBoard,
  defaultCompanyBoards,
  fetchCompanyBoards,
  loadCompanyBoards,
  maxOpeningsPerBoard,
} from '../../../src/job_opening/feed/company_board.js';
import type { JobOpening } from '../../../src/job_opening/job_opening.js';

const board: CompanyBoard = {
  system: 'greenhouse',
  slug: 'acme',
  name: 'Acme',
};

function posting(
  title: string,
  { isRemote = true, location = 'Remote' as string | null } = {},
): BoardPosting {
  return {
    title,
    location,
    isRemote,
    toJobOpening: () =>
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
        publishedAt: new Date('2026-10-20T00:00:00Z'),
      }),
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

describe('fetchCompanyBoards', () => {
  const query = { terms: ['Android', 'Mobile'] };

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
});
