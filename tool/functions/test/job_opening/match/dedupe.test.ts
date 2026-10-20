import { describe, expect, it } from 'vitest';

import {
  dedupeJobOpenings,
  dedupeKey,
} from '../../../src/job_opening/match/dedupe.js';
import { jobOpening } from '../fixture.js';

describe('dedupeKey', () => {
  it('should give the same key when case, accents and gender notes differ', () => {
    expect(
      dedupeKey({ company: 'Café GmbH', title: 'Flutter Developer (m/w/d)' }),
    ).toBe(dedupeKey({ company: 'cafe gmbh', title: 'Flutter  Developer' }));
  });

  it('should give different keys when the title differs', () => {
    expect(dedupeKey({ company: 'Acme', title: 'Flutter Developer' })).not.toBe(
      dedupeKey({ company: 'Acme', title: 'Android Developer' }),
    );
  });

  it('should keep C++ and C# apart when titles only differ by them', () => {
    expect(dedupeKey({ company: 'Acme', title: 'C++ Developer' })).not.toBe(
      dedupeKey({ company: 'Acme', title: 'C# Developer' }),
    );
  });

  it('should be a 32 character hex id', () => {
    expect(dedupeKey({ company: 'Acme', title: 'Dev' })).toMatch(
      /^[0-9a-f]{32}$/,
    );
  });
});

describe('dedupeJobOpenings', () => {
  it('should keep the first opening when two feeds list the same job', () => {
    const remotive = jobOpening({ source: 'remotive', sourceId: 'r1' });
    const arbeitnow = jobOpening({ source: 'arbeitnow', sourceId: 'a1' });

    const openings = dedupeJobOpenings([remotive, arbeitnow]);

    expect(openings).toHaveLength(1);
    expect(openings[0]).toMatchObject({
      source: 'remotive',
      dedupeKey: dedupeKey(remotive),
    });
  });
});
