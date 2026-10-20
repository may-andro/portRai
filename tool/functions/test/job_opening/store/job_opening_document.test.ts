import { Timestamp } from 'firebase-admin/firestore';
import { describe, expect, it } from 'vitest';

import { toJobOpeningDocument } from '../../../src/job_opening/store/job_opening_document.js';
import { jobOpening } from '../fixture.js';

describe('toJobOpeningDocument', () => {
  it('should expire 14 days after the run and keep the source attribution', () => {
    const now = new Date('2026-10-19T04:00:00Z');
    const opening = {
      ...jobOpening(),
      dedupeKey: 'key',
      matchedSkills: ['Flutter', 'Dart'],
    };

    const document = toJobOpeningDocument(opening, now);

    expect(document).toMatchObject({
      source: 'remotive',
      sourceName: 'Remotive',
      url: opening.url,
      matchedSkills: ['Flutter', 'Dart'],
      fetchedAt: Timestamp.fromDate(now),
      publishedAt: Timestamp.fromDate(opening.publishedAt),
      expiresAt: Timestamp.fromDate(new Date('2026-11-02T04:00:00Z')),
    });
    expect(document).not.toHaveProperty('dedupeKey');
  });
});
