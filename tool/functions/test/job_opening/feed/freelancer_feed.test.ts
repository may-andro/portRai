import { describe, expect, it, vi } from 'vitest';

import { FreelancerFeed } from '../../../src/job_opening/feed/freelancer_feed.js';
import { searchQuery } from '../fixture.js';

const usd = { code: 'USD', exchange_rate: 1 };

const freelancerProject = {
  id: 40788059,
  title: 'Flutter App for a Delivery Service',
  seo_url: 'mobile-app-development/Flutter-App-Delivery-40788059',
  type: 'fixed',
  budget: { minimum: 1500, maximum: 3000 },
  currency: usd,
  time_submitted: 1792576800,
  bidperiod: 7,
  local: false,
  jobs: [{ name: 'Flutter' }, { name: 'Mobile App Development' }],
  description: '  Build the rider and customer apps.\n',
};

function respond(projects: unknown[]) {
  return vi.fn().mockResolvedValue({ status: 'success', result: { projects } });
}

describe('FreelancerFeed', () => {
  it('should search each term', async () => {
    const fetchJson = respond([]);

    await new FreelancerFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Android', 'C++'] }),
    );

    expect(fetchJson.mock.calls.map(([url]) => url)).toEqual([
      'https://www.freelancer.com/api/projects/0.1/projects/active/?query=Android&limit=100&job_details=true&full_description=true',
      'https://www.freelancer.com/api/projects/0.1/projects/active/?query=C%2B%2B&limit=100&job_details=true&full_description=true',
    ]);
  });

  it('should map a project with Freelancer.com as its source', async () => {
    const [opening] = await new FreelancerFeed(
      respond([freelancerProject]),
    ).fetchJobs(searchQuery({ terms: ['Flutter'] }));

    expect(opening).toEqual({
      source: 'freelancer',
      sourceName: 'Freelancer.com',
      sourceId: '40788059',
      title: 'Flutter App for a Delivery Service',
      company: 'Freelancer.com client',
      url: 'https://www.freelancer.com/projects/mobile-app-development/Flutter-App-Delivery-40788059',
      location: null,
      tags: ['Flutter', 'Mobile App Development'],
      jobTypes: ['Freelance', 'Fixed price'],
      description: 'Build the rider and customer apps.',
      publishedAt: new Date('2026-10-21T10:00:00Z'),
      expiresAt: new Date('2026-10-28T10:00:00Z'),
    });
  });

  it('should keep projects whose highest budget in dollars reaches the floor', async () => {
    const openings = await new FreelancerFeed(
      respond([
        freelancerProject,
        { ...freelancerProject, id: 2, budget: { minimum: 30, maximum: 250 } },
        {
          ...freelancerProject,
          id: 3,
          budget: { minimum: 75000, maximum: 150000 },
          currency: { code: 'INR', exchange_rate: 0.0105 },
        },
        {
          ...freelancerProject,
          id: 4,
          budget: { minimum: 15000, maximum: 37500 },
          currency: { code: 'INR', exchange_rate: 0.0105 },
        },
        { ...freelancerProject, id: 5, budget: { minimum: 1200 } },
        { ...freelancerProject, id: 6, budget: {} },
      ]),
      { fixed: 1000, hourly: 30 },
    ).fetchJobs(searchQuery({ terms: ['Flutter'] }));

    expect(openings.map((opening) => opening.sourceId)).toEqual([
      '40788059',
      '3',
      '5',
    ]);
  });

  it('should hold hourly projects to the hourly rate floor', async () => {
    const openings = await new FreelancerFeed(
      respond([
        {
          ...freelancerProject,
          id: 1,
          type: 'hourly',
          budget: { minimum: 25, maximum: 40 },
        },
        {
          ...freelancerProject,
          id: 2,
          type: 'hourly',
          budget: { minimum: 8, maximum: 15 },
        },
      ]),
      { fixed: 1000, hourly: 30 },
    ).fetchJobs(searchQuery({ terms: ['Flutter'] }));

    expect(openings).toHaveLength(1);
    expect(openings[0]).toMatchObject({
      sourceId: '1',
      jobTypes: ['Freelance', 'Hourly'],
    });
  });

  it('should drop on-site projects and projects the query does not keep', async () => {
    const openings = await new FreelancerFeed(
      respond([
        freelancerProject,
        { ...freelancerProject, id: 2, local: true },
        { ...freelancerProject, id: 3, time_submitted: 1785924000 },
        { ...freelancerProject, id: 4, title: 'Flutter Product Manager' },
      ]),
    ).fetchJobs(
      searchQuery({
        terms: ['Flutter'],
        publishedAfter: new Date('2026-09-21T00:00:00Z'),
        regions: new Set(['europe']),
        roles: ['Senior Flutter Developer'],
      }),
    );

    expect(openings.map((opening) => opening.sourceId)).toEqual(['40788059']);
  });

  it('should leave out the expiry without a bid period', async () => {
    const [opening] = await new FreelancerFeed(
      respond([{ ...freelancerProject, bidperiod: null }]),
    ).fetchJobs(searchQuery({ terms: ['Flutter'] }));

    expect(opening).not.toHaveProperty('expiresAt');
  });

  it('should keep the other terms when one term fails', async () => {
    const fetchJson = vi.fn(async (url: string) => {
      if (url.includes('query=Kotlin')) throw new Error('HTTP 503');
      return { result: { projects: [freelancerProject] } };
    });

    const openings = await new FreelancerFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Kotlin', 'Flutter'] }),
    );

    expect(openings).toHaveLength(1);
  });

  it('should fail when every term fails', async () => {
    await expect(
      new FreelancerFeed(
        vi.fn().mockResolvedValue({ status: 'error' }),
      ).fetchJobs(searchQuery({ terms: ['Kotlin', 'Flutter'] })),
    ).rejects.toThrow('Freelancer.com term "Kotlin" has no projects list');
  });
});
