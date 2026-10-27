import { isRecord } from '../shared/json_value.js';
import { isValidTimeZone } from './call_booking_settings.js';

/** The languages of the emails and notifications, English otherwise. */
export const callBookingLanguages = ['en', 'es', 'nl'] as const;

export type CallBookingLanguage = (typeof callBookingLanguages)[number];

export function callBookingLanguage(locale: unknown): CallBookingLanguage {
  return callBookingLanguages.find((language) => language === locale) ?? 'en';
}

export type CallRequestStatus = 'requested' | 'accepted' | 'declined';

/** What a visitor sends to book a slot. */
export interface CallRequestInput {
  slotStart: Date;
  name: string;
  /** Stored in lowercase, so the limit per address ignores case. */
  email: string;
  topic: string;
  /** Empty when the visitor wrote none. */
  message: string;
  language: CallBookingLanguage;
  /** The visitor's IANA time zone, for the times in their emails, or null. */
  timeZone: string | null;
}

/** A request as stored at `users/{ownerId}/call_requests/{id}`. */
export interface CallRequest extends CallRequestInput {
  id: string;
  slotEnd: Date;
  status: CallRequestStatus;
  createdAt: Date;
}

/** The longest text each field may hold. */
export const callRequestMaxLengths = {
  name: 100,
  email: 254,
  topic: 120,
  message: 2000,
} as const;

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export type CallRequestField =
  'slotStart' | 'name' | 'email' | 'topic' | 'message';

export type ParsedCallRequestInput =
  { input: CallRequestInput } | { invalidField: CallRequestField };

function text(value: unknown, maxLength: number): string | null {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed.length <= maxLength ? trimmed : null;
}

/**
 * The request in [data], sent by the app, or the first field that is missing
 * or invalid. The language and time zone fall back to English and null.
 */
export function parseCallRequestInput(data: unknown): ParsedCallRequestInput {
  const fields = isRecord(data) ? data : {};
  const slotStart =
    typeof fields.slotStart === 'string' ? new Date(fields.slotStart) : null;
  if (slotStart === null || Number.isNaN(slotStart.getTime())) {
    return { invalidField: 'slotStart' };
  }
  const name = text(fields.name, callRequestMaxLengths.name);
  if (!name) return { invalidField: 'name' };
  const email = text(fields.email, callRequestMaxLengths.email)?.toLowerCase();
  if (!email || !emailPattern.test(email)) return { invalidField: 'email' };
  const topic = text(fields.topic, callRequestMaxLengths.topic);
  if (!topic) return { invalidField: 'topic' };
  const message = text(fields.message ?? '', callRequestMaxLengths.message);
  if (message === null) return { invalidField: 'message' };
  const timeZone =
    typeof fields.timeZone === 'string' && isValidTimeZone(fields.timeZone)
      ? fields.timeZone
      : null;
  return {
    input: {
      slotStart,
      name,
      email,
      topic,
      message,
      language: callBookingLanguage(fields.locale),
      timeZone,
    },
  };
}

/** Reads a timestamp field as stored by Firestore, or a date in tests. */
function dateOf(value: unknown): Date | null {
  if (value instanceof Date) return value;
  if (isRecord(value) && typeof value.toDate === 'function') {
    const date: unknown = value.toDate();
    return date instanceof Date ? date : null;
  }
  return null;
}

/** The stored request [data] with [id], or null when a field is missing. */
export function parseStoredCallRequest(
  id: string,
  data: unknown,
): CallRequest | null {
  if (!isRecord(data)) return null;
  const slotStart = dateOf(data.slotStart);
  const slotEnd = dateOf(data.slotEnd);
  const createdAt = dateOf(data.createdAt);
  const { name, email, topic, message, status } = data;
  if (slotStart === null || slotEnd === null || createdAt === null) return null;
  if (typeof name !== 'string' || typeof email !== 'string') return null;
  if (typeof topic !== 'string' || typeof message !== 'string') return null;
  if (
    status !== 'requested' &&
    status !== 'accepted' &&
    status !== 'declined'
  ) {
    return null;
  }
  return {
    id,
    slotStart,
    slotEnd,
    createdAt,
    name,
    email,
    topic,
    message,
    status,
    language: callBookingLanguage(data.locale),
    timeZone:
      typeof data.timeZone === 'string' && isValidTimeZone(data.timeZone)
        ? data.timeZone
        : null,
  };
}
