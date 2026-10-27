import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import * as logger from 'firebase-functions/logger';
import { defineSecret } from 'firebase-functions/params';
import {
  onDocumentCreated,
  onDocumentUpdated,
} from 'firebase-functions/v2/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import { gmailEmailSender } from '../shared/email.js';
import {
  firestoreTriggerRegion,
  functionRegion,
  serviceAccountEmail,
} from '../shared/function_options.js';
import { cloudMessagingSender } from '../shared/messaging.js';
import { firestoreUserDevices } from '../shared/user_devices.js';
import {
  type BookCallOutcome,
  bookCall,
  listOpenCallSlots,
} from './book_call.js';
import {
  type CallRequestEventDependencies,
  type CallRequestEventOutcome,
  callRequestDecision,
  handleCallRequestDecision,
  handleNewCallRequest,
} from './call_request_events.js';
import { parseStoredCallRequest } from './call_request.js';
import {
  firestoreCallBookingStore,
  loadCallBookingSettings,
  loadCallOwner,
  releaseCallSlot,
} from './firestore_call_booking_store.js';

/** The Gmail address the emails are sent from. */
const gmailUser = defineSecret('CALL_BOOKING_GMAIL_USER');

/** An app password of that address. */
const gmailAppPassword = defineSecret('CALL_BOOKING_GMAIL_APP_PASSWORD');

// Only allowed to read and write Firestore, send notifications and read the
// email secrets.
const serviceAccount = serviceAccountEmail('call-booking');

/** The slots a visitor can book. Only the app may call it. */
export const getCallSlots = onCall(
  {
    region: functionRegion,
    serviceAccount,
    enforceAppCheck: true,
  },
  async () => {
    const openSlots = await listOpenCallSlots(
      firestoreCallBookingStore(getFirestore()),
      new Date(),
    );
    if (openSlots === null) {
      throw new HttpsError('failed-precondition', 'Booking is not set up', {
        reason: 'not_set_up',
      });
    }
    return openSlots;
  },
);

/** The error the app gets for each outcome other than a booked call. */
function bookCallError(
  outcome: Exclude<BookCallOutcome, { kind: 'requested' }>,
) {
  switch (outcome.kind) {
    case 'invalid':
      return new HttpsError('invalid-argument', `Invalid ${outcome.field}`, {
        reason: 'invalid',
        field: outcome.field,
      });
    case 'not_set_up':
    case 'slot_not_offered':
    case 'slot_taken':
      return new HttpsError('failed-precondition', outcome.kind, {
        reason: outcome.kind,
      });
    case 'too_many_open_requests':
    case 'daily_limit':
      return new HttpsError('resource-exhausted', outcome.kind, {
        reason: outcome.kind,
      });
  }
}

/**
 * Books a slot for a visitor. Only the app may call it, and each App Check
 * token works once, so a captured request cannot be replayed.
 */
export const requestCall = onCall(
  {
    region: functionRegion,
    serviceAccount,
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    const outcome = await bookCall(
      firestoreCallBookingStore(getFirestore()),
      request.data,
      new Date(),
    );
    // The outcome holds no visitor details, so it is safe to log.
    logger.info('Handled a call request', { outcome });
    if (outcome.kind !== 'requested') throw bookCallError(outcome);
    return { requestId: outcome.requestId };
  },
);

function eventDependencies(): CallRequestEventDependencies {
  const db = getFirestore();
  return {
    loadSettings: () => loadCallBookingSettings(db),
    loadOwner: () => loadCallOwner(db),
    emailSender: gmailEmailSender({
      user: gmailUser.value(),
      appPassword: gmailAppPassword.value(),
      senderName: 'PortRai',
    }),
    devices: {
      ...firestoreUserDevices(db),
      sender: cloudMessagingSender(getMessaging()),
    },
    releaseSlot: (slotId, requestId) => releaseCallSlot(db, slotId, requestId),
  };
}

function logOutcome(requestId: string, outcome: CallRequestEventOutcome) {
  if (outcome.kind === 'not_set_up') {
    logger.error('Call booking is not set up', { requestId });
    return;
  }
  for (const { step, error } of outcome.failures) {
    logger.error('A call request step failed', {
      requestId,
      step,
      error: String(error),
    });
  }
}

const callRequestDocument = 'users/{userId}/call_requests/{requestId}';

const triggerOptions = {
  document: callRequestDocument,
  region: firestoreTriggerRegion,
  serviceAccount,
  secrets: [gmailUser, gmailAppPassword],
  retry: false,
};

/** Tells the owner about a new request and the visitor that it is in. */
export const callRequestCreated = onDocumentCreated(
  triggerOptions,
  async (event) => {
    const { userId, requestId } = event.params;
    const request = parseStoredCallRequest(requestId, event.data?.data());
    if (request === null) {
      logger.error('A call request could not be read', { requestId });
      return;
    }
    logOutcome(
      requestId,
      await handleNewCallRequest(eventDependencies(), userId, request),
    );
  },
);

/** Emails the visitor, and the owner on accept, when the owner answers. */
export const callRequestDecided = onDocumentUpdated(
  triggerOptions,
  async (event) => {
    const { requestId } = event.params;
    const before = parseStoredCallRequest(requestId, event.data?.before.data());
    const after = parseStoredCallRequest(requestId, event.data?.after.data());
    const decision = callRequestDecision(before, after);
    if (decision === null || after === null) return;
    logOutcome(
      requestId,
      await handleCallRequestDecision(
        eventDependencies(),
        decision,
        after,
        new Date(),
      ),
    );
  },
);
