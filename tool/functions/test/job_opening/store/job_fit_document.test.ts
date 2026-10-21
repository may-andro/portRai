import { Timestamp } from 'firebase-admin/firestore';
import { describe, expect, it } from 'vitest';

import {
  fromJobFitDocument,
  toJobFitDocument,
} from '../../../src/job_opening/store/job_fit_document.js';

const fit = {
  score: 82,
  matchedSkills: ['Flutter'],
  missingSkills: ['GraphQL'],
  reasons: ['The core stack is Flutter.'],
};

describe('toJobFitDocument', () => {
  it('should keep the fit and expire 30 days after the run', () => {
    const now = new Date('2026-10-19T04:00:00Z');

    const document = toJobFitDocument(fit, now);

    expect(document).toEqual({
      ...fit,
      expiresAt: Timestamp.fromDate(new Date('2026-11-18T04:00:00Z')),
    });
  });
});

describe('fromJobFitDocument', () => {
  it('should read back the fit that was stored', () => {
    const document = toJobFitDocument(fit, new Date());

    expect(fromJobFitDocument(document)).toEqual(fit);
  });

  it('should return null when the document has no score', () => {
    expect(fromJobFitDocument(undefined)).toBeNull();
    expect(fromJobFitDocument({ reasons: [] })).toBeNull();
  });
});
