import type { Firestore } from 'firebase-admin/firestore';

import type { JobFit, ScoredJobOpening } from '../job_opening.js';
import type { ReadDocument } from '../skill/portfolio_skills.js';
import { fromJobFitDocument, toJobFitDocument } from './job_fit_document.js';
import { toJobOpeningDocument } from './job_opening_document.js';

const jobFitsCollection = 'job_fits';

// Keeps each read well within Firestore's request limits.
const readBatchSize = 100;

export function firestoreReadDocument(db: Firestore): ReadDocument {
  return async (collection, documentId) => {
    const snapshot = await db.collection(collection).doc(documentId).get();
    return snapshot.data() ?? null;
  };
}

/** Ids of the users whose `jobSearch.enabled` is true. */
export async function listJobSearchUserIds(db: Firestore): Promise<string[]> {
  const snapshot = await db
    .collection('users')
    .where('jobSearch.enabled', '==', true)
    .select()
    .get();
  return snapshot.docs.map((document) => document.id);
}

/**
 * Writes the openings under the user and returns how many the user did not
 * have yet. An opening seen again replaces its document, which also pushes
 * its expiry back.
 */
export async function writeJobOpenings(
  db: Firestore,
  userId: string,
  openings: ScoredJobOpening[],
  now: Date,
): Promise<number> {
  const collection = db
    .collection('users')
    .doc(userId)
    .collection('job_openings');
  const refs = openings.map((opening) => collection.doc(opening.dedupeKey));
  let existingCount = 0;
  for (let start = 0; start < refs.length; start += readBatchSize) {
    const snapshots = await db.getAll(
      ...refs.slice(start, start + readBatchSize),
    );
    existingCount += snapshots.filter((snapshot) => snapshot.exists).length;
  }

  const writer = db.bulkWriter();
  openings.forEach((opening, index) => {
    void writer.set(refs[index], toJobOpeningDocument(opening, now));
  });
  await writer.close();
  return openings.length - existingCount;
}

/** The stored fits for [fitKeys], by key. Keys without a fit are left out. */
export async function loadJobFits(
  db: Firestore,
  fitKeys: string[],
): Promise<Map<string, JobFit>> {
  const collection = db.collection(jobFitsCollection);
  const fits = new Map<string, JobFit>();
  for (let start = 0; start < fitKeys.length; start += readBatchSize) {
    const refs = fitKeys
      .slice(start, start + readBatchSize)
      .map((key) => collection.doc(key));
    const snapshots = await db.getAll(...refs);
    for (const snapshot of snapshots) {
      const fit = fromJobFitDocument(snapshot.data());
      if (fit !== null) fits.set(snapshot.id, fit);
    }
  }
  return fits;
}

/** Stores each fit under its key for later runs to reuse. */
export async function saveJobFits(
  db: Firestore,
  fits: Map<string, JobFit>,
  now: Date,
): Promise<void> {
  const collection = db.collection(jobFitsCollection);
  const writer = db.bulkWriter();
  for (const [key, fit] of fits) {
    void writer.set(collection.doc(key), toJobFitDocument(fit, now));
  }
  await writer.close();
}
