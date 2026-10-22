import { describe, expect, it, vi } from 'vitest';

import { RemoteOkFeed } from '../../../src/job_opening/feed/remoteok_feed.js';
import { searchQuery } from '../fixture.js';

const remoteOkJob = {
  id: '1137548',
  position: 'Senior Flutter Developer',
  company: 'Acme',
  url: 'https://remoteOK.com/remote-jobs/remote-senior-flutter-developer-acme-1137548',
  location: '',
  tags: ['flutter', 'dart'],
  description: '<p>Flutter apps.</p>',
  date: '2026-10-20T08:00:05+00:00',
};

describe('RemoteOkFeed', () => {
  it('should skip the legal notice and map the jobs', async () => {
    const openings = await new RemoteOkFeed(
      vi.fn().mockResolvedValue([{ legal: 'Please link back' }, remoteOkJob]),
    ).fetchJobs(searchQuery());

    expect(openings).toEqual([
      {
        source: 'remoteok',
        sourceName: 'Remote OK',
        sourceId: '1137548',
        title: 'Senior Flutter Developer',
        company: 'Acme',
        url: remoteOkJob.url,
        location: null,
        tags: ['flutter', 'dart'],
        jobTypes: [],
        description: 'Flutter apps.',
        publishedAt: new Date('2026-10-20T08:00:05Z'),
      },
    ]);
  });

  it('should drop jobs the query does not keep', async () => {
    const openings = await new RemoteOkFeed(
      vi
        .fn()
        .mockResolvedValue([
          remoteOkJob,
          { ...remoteOkJob, id: '2', date: '2026-08-01T08:00:00+00:00' },
          { ...remoteOkJob, id: '3', location: 'USA only' },
          { ...remoteOkJob, id: '4', position: 'Flutter Recruiter' },
        ]),
    ).fetchJobs(
      searchQuery({
        publishedAfter: new Date('2026-09-21T00:00:00Z'),
        regions: new Set(['europe']),
        roles: ['Senior Flutter Developer'],
      }),
    );

    expect(openings.map((opening) => opening.sourceId)).toEqual(['1137548']);
  });

  it('should throw when the response is not a list', async () => {
    await expect(
      new RemoteOkFeed(vi.fn().mockResolvedValue({})).fetchJobs(searchQuery()),
    ).rejects.toThrow('Remote OK response is not a list');
  });
});
