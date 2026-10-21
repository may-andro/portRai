import { describe, expect, it, vi } from 'vitest';

import type { JobPostExtractor } from '../../../src/job_opening/extract/job_post_extractor.js';
import { HackerNewsFeed } from '../../../src/job_opening/feed/hacker_news_feed.js';

const threads = {
  hits: [
    { objectID: '200', title: 'Ask HN: Who wants to be hired? (October 2026)' },
    { objectID: '100', title: 'Ask HN: Who is hiring? (October 2026)' },
  ],
};

function thread(children: object[]) {
  return { id: 100, children };
}

const flexibitsPost = {
  id: 1,
  created_at: '2026-10-01T15:02:51.000Z',
  text: 'Flexibits | Android Software Engineer | Remote | Full-time<p>Kotlin &amp; Compose.',
};

function fetchJsonFor(posts: object[]) {
  return vi.fn(async (url: string) =>
    url === HackerNewsFeed.threadsUrl ? threads : thread(posts),
  );
}

function extractor(
  extractRoles: JobPostExtractor['extractRoles'] = async () => [
    {
      title: 'Android Software Engineer',
      company: 'Flexibits',
      location: 'Remote',
      isRemote: true,
    },
  ],
): JobPostExtractor {
  return { extractRoles: vi.fn(extractRoles) };
}

describe('HackerNewsFeed', () => {
  it('should read only the hiring thread and map remote roles to the post link', async () => {
    const fetchJson = fetchJsonFor([flexibitsPost]);

    const openings = await new HackerNewsFeed(fetchJson, extractor()).fetchJobs(
      { terms: ['Android'] },
    );

    expect(fetchJson.mock.calls.map(([url]) => url)).toEqual([
      HackerNewsFeed.threadsUrl,
      'https://hn.algolia.com/api/v1/items/100',
    ]);
    expect(openings).toEqual([
      {
        source: 'hackernews',
        sourceName: 'Hacker News',
        sourceId: '1-0',
        title: 'Android Software Engineer',
        company: 'Flexibits',
        url: 'https://news.ycombinator.com/item?id=1',
        location: 'Remote',
        tags: [],
        jobTypes: [],
        description:
          'Flexibits | Android Software Engineer | Remote | Full-time\nKotlin & Compose.',
        publishedAt: new Date('2026-10-01T15:02:51Z'),
      },
    ]);
  });

  it('should only read posts that mention a term and remote work', async () => {
    const postExtractor = extractor();
    await new HackerNewsFeed(
      fetchJsonFor([
        flexibitsPost,
        {
          id: 2,
          created_at: flexibitsPost.created_at,
          text: 'Acme | Android | ONSITE Berlin',
        },
        {
          id: 3,
          created_at: flexibitsPost.created_at,
          text: 'Acme | Go Engineer | Remote',
        },
        {
          id: 4,
          created_at: flexibitsPost.created_at,
          text: 'Acme | Androids | Remote',
        },
      ]),
      postExtractor,
    ).fetchJobs({ terms: ['Android'] });

    expect(postExtractor.extractRoles).toHaveBeenCalledTimes(1);
  });

  it('should drop roles that are not remote', async () => {
    const openings = await new HackerNewsFeed(
      fetchJsonFor([flexibitsPost]),
      extractor(async () => [
        {
          title: 'Android Engineer',
          company: 'Acme',
          location: 'Berlin',
          isRemote: false,
        },
      ]),
    ).fetchJobs({ terms: ['Android'] });

    expect(openings).toEqual([]);
  });

  it('should skip a post whose roles cannot be read', async () => {
    const openings = await new HackerNewsFeed(
      fetchJsonFor([
        flexibitsPost,
        { ...flexibitsPost, id: 5, text: 'Other | Android Developer | Remote' },
      ]),
      extractor(async (post) => {
        if (post.startsWith('Other')) throw new Error('HTTP 503');
        return [
          {
            title: 'Android Software Engineer',
            company: 'Flexibits',
            location: null,
            isRemote: true,
          },
        ];
      }),
    ).fetchJobs({ terms: ['Android'] });

    expect(openings.map((opening) => opening.company)).toEqual(['Flexibits']);
  });

  it('should fail when every post fails to be read', async () => {
    await expect(
      new HackerNewsFeed(
        fetchJsonFor([flexibitsPost]),
        extractor(async () => {
          throw new Error('PERMISSION_DENIED');
        }),
      ).fetchJobs({ terms: ['Android'] }),
    ).rejects.toThrow('Reading every Hacker News post failed (1)');
  });

  it('should not call the network when there are no search terms', async () => {
    const fetchJson = fetchJsonFor([flexibitsPost]);

    expect(
      await new HackerNewsFeed(fetchJson, extractor()).fetchJobs({ terms: [] }),
    ).toEqual([]);
    expect(fetchJson).not.toHaveBeenCalled();
  });
});
