import type { Firestore } from 'firebase-admin/firestore';

import type { ScoredJobOpening } from '../job_opening.js';
import type { ReadDocument } from '../skill/portfolio_skills.js';
import { toJobOpeningDocument } from './job_opening_document.js';

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
 * Writes the openings under the user. An opening seen again replaces its
 * document, which also pushes its expiry back.
 */
export async function writeJobOpenings(
  db: Firestore,
  userId: string,
  openings: ScoredJobOpening[],
  now: Date,
): Promise<void> {
  const collection = db
    .collection('users')
    .doc(userId)
    .collection('job_openings');
  const writer = db.bulkWriter();
  for (const opening of openings) {
    void writer.set(
      collection.doc(opening.dedupeKey),
      toJobOpeningDocument(opening, now),
    );
  }
  await writer.close();
}
