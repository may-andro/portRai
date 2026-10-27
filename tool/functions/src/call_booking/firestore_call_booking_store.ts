import { type Firestore, Timestamp } from 'firebase-admin/firestore';

import { isRecord, stringOrNull } from '../shared/json_value.js';
import type { CallBookingStore } from './book_call.js';
import {
  type CallBookingSettings,
  callBookingSettingsPath,
  parseCallBookingSettings,
} from './call_booking_settings.js';
import type { CallOwner } from './call_messages.js';
import type { CallRequest } from './call_request.js';
import { callSlotId } from './call_slots.js';

/** One document per taken slot, keyed by its ID, holding the request that took it. */
export const callSlotsCollection = 'call_slots';

function callRequests(db: Firestore, ownerId: string) {
  return db.collection('users').doc(ownerId).collection('call_requests');
}

export async function loadCallBookingSettings(
  db: Firestore,
): Promise<CallBookingSettings | null> {
  const snapshot = await db.doc(callBookingSettingsPath).get();
  return parseCallBookingSettings(snapshot.data());
}

/** The owner's name and address from the English portfolio profile. */
export async function loadCallOwner(db: Firestore): Promise<CallOwner | null> {
  const snapshot = await db.doc('profile/en').get();
  const profile: unknown = snapshot.get('profile');
  if (!isRecord(profile)) return null;
  const name = stringOrNull(profile.fullName);
  const email = stringOrNull(profile.email);
  return name === null || email === null ? null : { name, email };
}

export function firestoreCallBookingStore(db: Firestore): CallBookingStore {
  return {
    loadSettings: () => loadCallBookingSettings(db),

    async listTakenSlotIds(from) {
      const snapshot = await db
        .collection(callSlotsCollection)
        .where('start', '>=', from)
        .get();
      return new Set(snapshot.docs.map((document) => document.id));
    },

    async countOpenRequests(ownerId, email) {
      const snapshot = await callRequests(db, ownerId)
        .where('email', '==', email)
        .where('status', '==', 'requested')
        .count()
        .get();
      return snapshot.data().count;
    },

    async countRequestsSince(ownerId, since) {
      const snapshot = await callRequests(db, ownerId)
        .where('createdAt', '>=', since)
        .count()
        .get();
      return snapshot.data().count;
    },

    saveRequest(ownerId, request, expiresAt) {
      const slotRef = db
        .collection(callSlotsCollection)
        .doc(callSlotId(request.slotStart));
      const requestRef = callRequests(db, ownerId).doc();
      return db.runTransaction(async (transaction) => {
        const slot = await transaction.get(slotRef);
        if (slot.exists) return null;
        transaction.create(slotRef, {
          start: request.slotStart,
          requestId: requestRef.id,
          expiresAt,
        });
        transaction.create(requestRef, {
          ...toCallRequestDocument(request),
          expiresAt,
        });
        return requestRef.id;
      });
    },
  };
}

function toCallRequestDocument(request: Omit<CallRequest, 'id'>) {
  return {
    slotStart: Timestamp.fromDate(request.slotStart),
    slotEnd: Timestamp.fromDate(request.slotEnd),
    name: request.name,
    email: request.email,
    topic: request.topic,
    message: request.message,
    locale: request.language,
    timeZone: request.timeZone,
    status: request.status,
    createdAt: Timestamp.fromDate(request.createdAt),
  };
}

/** Deletes the slot [slotId] when [requestId] still holds it. */
export async function releaseCallSlot(
  db: Firestore,
  slotId: string,
  requestId: string,
): Promise<void> {
  const slotRef = db.collection(callSlotsCollection).doc(slotId);
  await db.runTransaction(async (transaction) => {
    const slot = await transaction.get(slotRef);
    if (slot.get('requestId') === requestId) transaction.delete(slotRef);
  });
}
