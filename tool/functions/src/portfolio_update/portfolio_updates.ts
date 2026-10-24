import { type Firestore, getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import * as logger from 'firebase-functions/logger';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';

import {
  functionRegion,
  serviceAccountEmail,
} from '../shared/function_options.js';
import { cloudMessagingSender } from '../shared/messaging.js';
import {
  notifyPortfolioUpdate,
  portfolioCollections,
} from './notify_portfolio_update.js';

/** The last send to each topic, at `notification_sends/{topic}`. */
const sendsCollection = 'notification_sends';

/**
 * Records a send to [topic] in a transaction, so two triggers running at the
 * same time cannot both claim it.
 */
function claimSend(db: Firestore) {
  return (topic: string, now: Date, cooldownMs: number) =>
    db.runTransaction(async (transaction) => {
      const ref = db.collection(sendsCollection).doc(topic);
      const sentAt = (await transaction.get(ref)).get('sentAt');
      if (
        sentAt !== undefined &&
        now.getTime() - sentAt.toDate().getTime() < cooldownMs
      ) {
        return false;
      }
      transaction.set(ref, { sentAt: now });
      return true;
    });
}

function portfolioUpdateTrigger(collection: string) {
  return onDocumentWritten(
    {
      document: `${collection}/{locale}`,
      region: functionRegion,
      // Only allowed to read and write Firestore and to send notifications.
      serviceAccount: serviceAccountEmail('notifications'),
      retry: false,
    },
    async (event) => {
      const db = getFirestore();
      const outcome = await notifyPortfolioUpdate(
        {
          claimSend: claimSend(db),
          sender: cloudMessagingSender(getMessaging()),
        },
        {
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
