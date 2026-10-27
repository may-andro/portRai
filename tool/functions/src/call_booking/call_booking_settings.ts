import { DateTime } from 'luxon';

import { isRecord, stringOrNull } from '../shared/json_value.js';

/** The settings document, at `call_booking/settings`. */
export const callBookingSettingsPath = 'call_booking/settings';

export const weekdays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
] as const;

export type Weekday = (typeof weekdays)[number];

/** A time range in the owner's time zone, such as `09:00` to `12:30`. */
export interface TimeRange {
  start: string;
  end: string;
}

export interface CallBookingSettings {
  /** The user who receives the requests, at `users/{ownerId}/call_requests`. */
  ownerId: string;
  /** The owner's IANA time zone, such as `Europe/Madrid`. */
  timeZone: string;
  /** When calls can be booked on each weekday. A day without ranges has no slots. */
  weeklyHours: Record<Weekday, TimeRange[]>;
  slotMinutes: number;
  /** How long before a slot it can still be booked. */
  minNoticeHours: number;
  /** How many days ahead, today included, slots are offered. */
  horizonDays: number;
  /** Where the call takes place, sent with an accepted request. */
  meetingLink: string;
}

const timeOfDay = /^([01]\d|2[0-3]):[0-5]\d$/;

/** The minutes since midnight of a `HH:mm` time. */
export function minutesOfDay(time: string): number {
  const [hours, minutes] = time.split(':').map(Number);
  return hours * 60 + minutes;
}

export function isValidTimeZone(timeZone: string): boolean {
  return DateTime.now().setZone(timeZone).isValid;
}

function timeRanges(value: unknown): TimeRange[] {
  if (!Array.isArray(value)) return [];
  return value.filter(isRecord).flatMap(({ start, end }) => {
    if (typeof start !== 'string' || typeof end !== 'string') return [];
    if (!timeOfDay.test(start) || !timeOfDay.test(end)) return [];
    return minutesOfDay(start) < minutesOfDay(end) ? [{ start, end }] : [];
  });
}

/** [value] when it is a whole number, kept within [min] and [max], [fallback] otherwise. */
function wholeNumber(
  value: unknown,
  fallback: number,
  min: number,
  max: number,
): number {
  if (typeof value !== 'number' || !Number.isInteger(value)) return fallback;
  return Math.min(Math.max(value, min), max);
}

/**
 * The settings in [data], or null when the owner, time zone or meeting link
 * is missing or invalid. Invalid time ranges are left out, and the numbers
 * fall back to a 30-minute slot, 24 hours of notice and 14 days ahead.
 */
export function parseCallBookingSettings(
  data: unknown,
): CallBookingSettings | null {
  if (!isRecord(data)) return null;
  const ownerId = stringOrNull(data.ownerId);
  const timeZone = stringOrNull(data.timeZone);
  const meetingLink = stringOrNull(data.meetingLink);
  if (ownerId === null || timeZone === null || meetingLink === null) {
    return null;
  }
  if (!isValidTimeZone(timeZone) || !meetingLink.startsWith('https://')) {
    return null;
  }
  const hours = isRecord(data.weeklyHours) ? data.weeklyHours : {};
  const weeklyHours = Object.fromEntries(
    weekdays.map((weekday) => [weekday, timeRanges(hours[weekday])]),
  ) as Record<Weekday, TimeRange[]>;
  return {
    ownerId,
    timeZone,
    weeklyHours,
    slotMinutes: wholeNumber(data.slotMinutes, 30, 15, 120),
    minNoticeHours: wholeNumber(data.minNoticeHours, 24, 0, 14 * 24),
    horizonDays: wholeNumber(data.horizonDays, 14, 1, 60),
    meetingLink,
  };
}
