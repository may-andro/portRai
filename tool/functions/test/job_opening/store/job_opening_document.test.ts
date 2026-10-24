import { Timestamp } from 'firebase-admin/firestore';
import { describe, expect, it } from 'vitest';

import { toJobOpeningDocument } from '../../../src/job_opening/store/job_opening_document.js';
import { jobOpening } from '../fixture.js';

describe('toJobOpeningDocument', () => {
  it('should expire 14 days after the run and keep the source attribution and fit', () => {
    const now = new Date('2026-10-19T04:00:00Z');
    const opening = {
      ...jobOpening(),
      dedupeKey: 'key',
      matchedSkills: ['Flutter', 'Dart'],
      score: 82,
      missingSkills: ['GraphQL'],
      reasons: ['The core stack is Flutter.'],
      openToCandidate: true,
    };

    const document = toJobOpeningDocument(opening, now);

    expect(document).toMatchObject({
      source: 'remotive',
      sourceName: 'Remotive',
      url: opening.url,
      matchedSkills: ['Flutter', 'Dart'],
      score: 82,
      missingSkills: ['GraphQL'],
      reasons: ['The core stack is Flutter.'],
      fetchedAt: Timestamp.fromDate(now),
      publishedAt: Timestamp.fromDate(opening.publishedAt),
      expiresAt: Timestamp.fromDate(new Date('2026-11-02T04:00:00Z')),
    });
    expect(document).not.toHaveProperty('dedupeKey');
  });

  it('should expire when the source does when that is sooner', () => {
    const now = new Date('2026-10-19T04:00:00Z');
    const sourceExpiry = new Date('2026-10-25T00:00:00Z');
    const opening = {
      ...jobOpening({ expiresAt: sourceExpiry }),
      dedupeKey: 'key',
      matchedSkills: [],
      score: 70,
      missingSkills: [],
      reasons: [],
      openToCandidate: true,
    };

    expect(toJobOpeningDocument(opening, now).expiresAt).toEqual(
      Timestamp.fromDate(sourceExpiry),
    );
  });
});
