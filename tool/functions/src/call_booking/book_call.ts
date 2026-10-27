import type { CallBookingSettings } from './call_booking_settings.js';
import {
  type CallRequest,
  type CallRequestField,
  parseCallRequestInput,
} from './call_request.js';
import { callSlotId, isCallSlot, openCallSlots } from './call_slots.js';

/** The most requests one email address may have waiting for an answer. */
export const maxOpenRequestsPerEmail = 2;

/** The most requests accepted in any 24 hours, across all visitors. */
export const maxRequestsPerDay = 20;

/** How long after its slot ends a request is kept, until the TTL deletes it. */
export const callRequestRetentionDays = 30;

export interface CallBookingStore {
  /** The settings, or null when booking is not set up. */
  loadSettings(): Promise<CallBookingSettings | null>;
  /** The IDs of the slots taken from [from] on. */
  listTakenSlotIds(from: Date): Promise<Set<string>>;
  countOpenRequests(ownerId: string, email: string): Promise<number>;
  countRequestsSince(ownerId: string, since: Date): Promise<number>;
  /**
   * Takes the slot of [request] and saves the request in one transaction.
   * Returns the request's ID, or null when the slot is already taken.
   */
  saveRequest(
    ownerId: string,
    request: Omit<CallRequest, 'id'>,
    expiresAt: Date,
  ): Promise<string | null>;
}

export interface OpenCallSlots {
  /** Slot starts as ISO strings in UTC, earliest first. */
  slots: string[];
  slotMinutes: number;
  /** The owner's IANA time zone. */
  timeZone: string;
}

/** The slots a visitor can book, or null when booking is not set up. */
export async function listOpenCallSlots(
  store: Pick<CallBookingStore, 'loadSettings' | 'listTakenSlotIds'>,
  now: Date,
): Promise<OpenCallSlots | null> {
  const settings = await store.loadSettings();
  if (settings === null) return null;
  const takenSlotIds = await store.listTakenSlotIds(now);
  return {
    slots: openCallSlots(settings, now, takenSlotIds).map(callSlotId),
    slotMinutes: settings.slotMinutes,
    timeZone: settings.timeZone,
  };
}

export type BookCallOutcome =
  | { kind: 'requested'; requestId: string }
  | { kind: 'invalid'; field: CallRequestField }
  | { kind: 'not_set_up' }
  | { kind: 'slot_not_offered' }
  | { kind: 'slot_taken' }
  | { kind: 'too_many_open_requests' }
  | { kind: 'daily_limit' };

/**
 * Books the slot in [data] for the visitor when it is offered and free, and
 * the visitor's address and the day are under their limits.
 */
export async function bookCall(
  store: CallBookingStore,
  data: unknown,
  now: Date,
): Promise<BookCallOutcome> {
  const parsed = parseCallRequestInput(data);
  if ('invalidField' in parsed) {
    return { kind: 'invalid', field: parsed.invalidField };
  }
  const { input } = parsed;
  const settings = await store.loadSettings();
  if (settings === null) return { kind: 'not_set_up' };
  if (!isCallSlot(settings, now, input.slotStart)) {
    return { kind: 'slot_not_offered' };
  }
  const { ownerId } = settings;
  const [openRequests, requestsToday] = await Promise.all([
    store.countOpenRequests(ownerId, input.email),
    store.countRequestsSince(ownerId, new Date(now.getTime() - 86_400_000)),
  ]);
  if (openRequests >= maxOpenRequestsPerEmail) {
    return { kind: 'too_many_open_requests' };
  }
  if (requestsToday >= maxRequestsPerDay) return { kind: 'daily_limit' };
  const slotEnd = new Date(
    input.slotStart.getTime() + settings.slotMinutes * 60_000,
  );
  const expiresAt = new Date(
    slotEnd.getTime() + callRequestRetentionDays * 86_400_000,
  );
  const requestId = await store.saveRequest(
    ownerId,
    { ...input, slotEnd, status: 'requested', createdAt: now },
    expiresAt,
  );
  return requestId === null
    ? { kind: 'slot_taken' }
    : { kind: 'requested', requestId };
}
