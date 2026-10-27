import type { CallBookingSettings } from '../../src/call_booking/call_booking_settings.js';
import type { CallOwner } from '../../src/call_booking/call_messages.js';
import type { CallRequest } from '../../src/call_booking/call_request.js';

/** Monday 2 November 2026, 09:00 in Madrid. */
export const now = new Date('2026-11-02T08:00:00Z');

/** Weekdays 09:00 to 11:00 in Madrid, 30-minute slots, 24 hours notice, 3 days ahead. */
export function settings(
  overrides: Partial<CallBookingSettings> = {},
): CallBookingSettings {
  const morning = [{ start: '09:00', end: '11:00' }];
  return {
    ownerId: 'owner-uid',
    timeZone: 'Europe/Madrid',
    weeklyHours: {
      monday: morning,
      tuesday: morning,
      wednesday: morning,
      thursday: morning,
      friday: morning,
      saturday: [],
      sunday: [],
    },
    slotMinutes: 30,
    minNoticeHours: 24,
    horizonDays: 3,
    meetingLink: 'https://meet.example.com/owner',
    ...overrides,
  };
}

export const owner: CallOwner = {
  name: 'Owner Name',
  email: 'owner@example.com',
};

export function callRequest(overrides: Partial<CallRequest> = {}): CallRequest {
  return {
    id: 'request-1',
    slotStart: new Date('2026-11-03T08:00:00Z'),
    slotEnd: new Date('2026-11-03T08:30:00Z'),
    name: 'Visitor Name',
    email: 'visitor@example.com',
    topic: 'Flutter consulting',
    message: 'Looking for help with an app.',
    language: 'en',
    timeZone: 'America/New_York',
    status: 'requested',
    createdAt: now,
    ...overrides,
  };
}

/** The app's request for the first offered slot. */
export function requestData(overrides: Record<string, unknown> = {}) {
  return {
    slotStart: '2026-11-03T08:00:00.000Z',
    name: 'Visitor Name',
    email: 'Visitor@Example.com',
    topic: 'Flutter consulting',
    message: 'Looking for help with an app.',
    locale: 'es',
    timeZone: 'America/New_York',
    ...overrides,
  };
}
