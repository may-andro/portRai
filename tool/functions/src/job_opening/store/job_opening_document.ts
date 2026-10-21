import { Timestamp } from 'firebase-admin/firestore';

import type { ScoredJobOpening } from '../job_opening.js';

/** Openings are kept this long after the run that last saw them. */
export const jobOpeningLifetimeDays = 14;

const dayMs = 24 * 60 * 60 * 1000;

/**
 * The Firestore document for `users/{uid}/job_openings/{dedupeKey}`.
 * `expiresAt` drives the TTL policy that deletes openings no run has seen for
 * [jobOpeningLifetimeDays].
 */
export function toJobOpeningDocument(opening: ScoredJobOpening, now: Date) {
  return {
    source: opening.source,
    sourceName: opening.sourceName,
    sourceId: opening.sourceId,
    title: opening.title,
    company: opening.company,
    url: opening.url,
    location: opening.location,
    tags: opening.tags,
    jobTypes: opening.jobTypes,
    description: opening.description,
    matchedSkills: opening.matchedSkills,
    score: opening.score,
    missingSkills: opening.missingSkills,
    reasons: opening.reasons,
    publishedAt: Timestamp.fromDate(opening.publishedAt),
    fetchedAt: Timestamp.fromDate(now),
    expiresAt: Timestamp.fromDate(expiryFor(opening, now)),
  };
}

/**
 * [jobOpeningLifetimeDays] after the run, or earlier when the source says the
 * job stops being listed sooner.
 */
function expiryFor(opening: ScoredJobOpening, now: Date): Date {
  const lifetimeEnd = new Date(now.getTime() + jobOpeningLifetimeDays * dayMs);
  return opening.expiresAt !== undefined && opening.expiresAt < lifetimeEnd
    ? opening.expiresAt
    : lifetimeEnd;
}
