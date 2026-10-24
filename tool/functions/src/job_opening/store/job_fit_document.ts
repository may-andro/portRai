import { Timestamp } from 'firebase-admin/firestore';

import { isRecord, stringList } from '../../shared/json_value.js';
import type { JobFit } from '../job_opening.js';

/**
 * Fits are kept as long as a job stays fresh enough to be scored, so a job
 * seen again in a later run reuses its fit.
 */
export const jobFitLifetimeDays = 30;

const dayMs = 24 * 60 * 60 * 1000;

/**
 * The Firestore document for `job_fits/{fitKey}`. `expiresAt` drives the TTL
 * policy that deletes fits [jobFitLifetimeDays] after they were scored.
 */
export function toJobFitDocument(fit: JobFit, now: Date) {
  return {
    score: fit.score,
    matchedSkills: fit.matchedSkills,
    missingSkills: fit.missingSkills,
    reasons: fit.reasons,
    openToCandidate: fit.openToCandidate,
    expiresAt: Timestamp.fromDate(
      new Date(now.getTime() + jobFitLifetimeDays * dayMs),
    ),
  };
}

/** The fit a document holds, or null when it does not hold one. */
export function fromJobFitDocument(data: unknown): JobFit | null {
  if (!isRecord(data) || typeof data.score !== 'number') return null;
  return {
    score: data.score,
    matchedSkills: stringList(data.matchedSkills),
    missingSkills: stringList(data.missingSkills),
    reasons: stringList(data.reasons),
    openToCandidate: data.openToCandidate !== false,
  };
}
