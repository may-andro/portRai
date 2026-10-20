import { Timestamp } from 'firebase-admin/firestore';

import type { MatchedJobOpening } from '../job_opening.js';

/** Openings are kept this long after the run that last saw them. */
export const jobOpeningLifetimeDays = 14;

const dayMs = 24 * 60 * 60 * 1000;

/**
 * The Firestore document for `users/{uid}/job_openings/{dedupeKey}`.
 * `expiresAt` drives the TTL policy that deletes openings no run has seen for
 * [jobOpeningLifetimeDays].
 */
export function toJobOpeningDocument(opening: MatchedJobOpening, now: Date) {
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
    publishedAt: Timestamp.fromDate(opening.publishedAt),
    fetchedAt: Timestamp.fromDate(now),
    expiresAt: Timestamp.fromDate(
      new Date(now.getTime() + jobOpeningLifetimeDays * dayMs),
    ),
  };
}
