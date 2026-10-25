import {
  FieldValue,
  type Firestore,
  getFirestore,
} from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import * as logger from 'firebase-functions/logger';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import {
  firestoreTriggerRegion,
  functionRegion,
  serviceAccountEmail,
} from '../shared/function_options.js';
import { cloudMessagingSender } from '../shared/messaging.js';
import {
  type PortfolioCollection,
  type PortfolioUpdateBatch,
  notifyPortfolioUpdates,
  portfolioCollections,
  portfolioUpdateBatchesCollection,
  portfolioVersionsCollection,
  recordPortfolioChange,
} from './notify_portfolio_update.js';

/**
 * Sets the change time of one collection, keeping the others, and adds the
 * collection to the batch of [locale] in the same write.
 */
function recordChange(db: Firestore) {
  return async (locale: string, collection: PortfolioCollection, now: Date) => {
    const batch = db.batch();
    batch.set(
      db.collection(portfolioVersionsCollection).doc(locale),
      { [collection]: now },
      { merge: true },
    );
    batch.set(
      db.collection(portfolioUpdateBatchesCollection).doc(locale),
      { collections: FieldValue.arrayUnion(collection), lastChangedAt: now },
      { merge: true },
    );
    await batch.commit();
  };
}

/**
 * Deletes each quiet batch in a transaction, so a batch is sent once and a
 * change added after the query keeps its batch for the next run.
 */
function claimQuietBatches(db: Firestore) {
  return async (changedBefore: Date) => {
    const quiet = await db
      .collection(portfolioUpdateBatchesCollection)
      .where('lastChangedAt', '<=', changedBefore)
      .get();
    const batches: PortfolioUpdateBatch[] = [];
    for (const { ref } of quiet.docs) {
      const collections = await db.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(ref);
        const lastChangedAt = snapshot.get('lastChangedAt');
        if (!snapshot.exists || lastChangedAt.toDate() > changedBefore) {
          return undefined;
        }
        transaction.delete(ref);
        const stored: unknown = snapshot.get('collections');
        return Array.isArray(stored) ? stored : [];
      });
      if (collections) batches.push({ locale: ref.id, collections });
    }
    return batches;
  };
}

function portfolioUpdateTrigger(collection: PortfolioCollection) {
  return onDocumentWritten(
    {
      document: `${collection}/{locale}`,
      region: firestoreTriggerRegion,
      // Only allowed to read and write Firestore and to send notifications.
      serviceAccount: serviceAccountEmail('notifications'),
      retry: false,
    },
    async (event) => {
      const outcome = await recordPortfolioChange(
        { recordChange: recordChange(getFirestore()) },
        {
          collection,
          locale: event.params.locale,
          before: event.data?.before.data(),
          after: event.data?.after.data(),
          now: new Date(),
        },
      );
      logger.info('Handled a portfolio change', {
        collection,
        locale: event.params.locale,
        outcome,
      });
    },
  );
}

/** One trigger per portfolio collection, deployed as `portfolioUpdates-<collection>`. */
export const portfolioUpdates = Object.fromEntries(
  portfolioCollections.map((collection) => [
    collection,
    portfolioUpdateTrigger(collection),
  ]),
);

/** Sends one notification per locale for the changes that have gone quiet. */
export const sendPortfolioUpdates = onSchedule(
  {
    schedule: 'every 5 minutes',
    region: functionRegion,
    // Only allowed to read and write Firestore and to send notifications.
    serviceAccount: serviceAccountEmail('notifications'),
    retryCount: 0,
  },
  async () => {
    const db = getFirestore();
    const sends = await notifyPortfolioUpdates(
      {
        claimQuietBatches: claimQuietBatches(db),
        sender: cloudMessagingSender(getMessaging()),
      },
      new Date(),
    );
    for (const { locale, collections, error } of sends) {
      if (error === undefined) {
        logger.info('Sent a portfolio update', { locale, collections });
      } else {
        logger.error('A portfolio update failed to send', {
          locale,
          collections,
          error: String(error),
        });
      }
    }
  },
);
