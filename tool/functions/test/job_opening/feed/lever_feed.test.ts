import { describe, expect, it, vi } from 'vitest';

import { LeverFeed } from '../../../src/job_opening/feed/lever_feed.js';
import { searchQuery } from '../fixture.js';

const board = { system: 'lever' as const, slug: 'qonto', name: 'Qonto' };

describe('LeverFeed', () => {
  it('should map a remote posting with its lists and credit the company', async () => {
    const fetchJson = vi.fn().mockResolvedValue([
      {
        id: 'abc',
        text: 'Senior Android Engineer',
        hostedUrl: 'https://jobs.lever.co/qonto/abc',
        createdAt: Date.UTC(2026, 9, 20),
        workplaceType: 'remote',
        categories: {
          location: 'Paris',
          commitment: 'Full-time',
          department: 'Engineering',
          team: 'Engineering',
        },
        description: '<p>Build the app.</p>',
        lists: [{ text: 'You have', content: '<li>Kotlin</li>' }],
        additional: '<p>Remote in Europe.</p>',
      },
      {
        id: 'def',
        text: 'Android Engineer',
        hostedUrl: 'https://jobs.lever.co/qonto/def',
        createdAt: Date.UTC(2026, 9, 20),
        workplaceType: 'on-site',
        categories: { location: 'Berlin' },
      },
    ]);

    const openings = await new LeverFeed(fetchJson, async () => [
      board,
    ]).fetchJobs(searchQuery({ terms: ['Android'] }));

    expect(fetchJson).toHaveBeenCalledWith(
      'https://api.lever.co/v0/postings/qonto?mode=json',
    );
    expect(openings).toEqual([
      {
        source: 'lever',
        sourceName: 'Qonto',
        sourceId: 'qonto:abc',
        title: 'Senior Android Engineer',
        company: 'Qonto',
        url: 'https://jobs.lever.co/qonto/abc',
        location: 'Paris',
        tags: ['Engineering'],
        jobTypes: ['Full-time'],
        description:
          'Build the app.\n\nYou have\n- Kotlin\n\nRemote in Europe.',
        publishedAt: new Date(Date.UTC(2026, 9, 20)),
      },
    ]);
  });
});
