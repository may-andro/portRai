import { describe, expect, it } from 'vitest';

import { parseCallBookingSettings } from '../../src/call_booking/call_booking_settings.js';

const stored = {
  ownerId: 'owner-uid',
  timeZone: 'Europe/Madrid',
  meetingLink: 'https://meet.example.com/owner',
  weeklyHours: {
    monday: [
      { start: '09:00', end: '12:30' },
      { start: '15:00', end: '17:00' },
    ],
    tuesday: [{ start: '09:00', end: '12:30' }],
  },
  slotMinutes: 45,
  minNoticeHours: 12,
  horizonDays: 21,
};

describe('parseCallBookingSettings', () => {
  it('should read every field of a complete settings document', () => {
    const settings = parseCallBookingSettings(stored);

    expect(settings).toMatchObject({
      ownerId: 'owner-uid',
      timeZone: 'Europe/Madrid',
      meetingLink: 'https://meet.example.com/owner',
      slotMinutes: 45,
      minNoticeHours: 12,
      horizonDays: 21,
    });
    expect(settings?.weeklyHours.monday).toHaveLength(2);
    expect(settings?.weeklyHours.wednesday).toEqual([]);
  });

  it('should fall back to the default numbers when they are missing or not whole', () => {
    const settings = parseCallBookingSettings({
      ...stored,
      slotMinutes: 'thirty',
      minNoticeHours: 1.5,
      horizonDays: undefined,
    });

    expect(settings).toMatchObject({
      slotMinutes: 30,
      minNoticeHours: 24,
      horizonDays: 14,
    });
  });

  it('should keep the numbers within their limits', () => {
    const settings = parseCallBookingSettings({
      ...stored,
      slotMinutes: 5,
      horizonDays: 365,
    });

    expect(settings).toMatchObject({ slotMinutes: 15, horizonDays: 60 });
  });

  it('should leave out time ranges that are malformed or end before they start', () => {
    const settings = parseCallBookingSettings({
      ...stored,
      weeklyHours: {
        monday: [
          { start: '9:00', end: '12:00' },
          { start: '14:00', end: '13:00' },
          { start: '24:00', end: '25:00' },
          'all day',
          { start: '16:00', end: '17:00' },
        ],
      },
    });

    expect(settings?.weeklyHours.monday).toEqual([
      { start: '16:00', end: '17:00' },
    ]);
  });

  it.each([
    ['the owner', { ownerId: '' }],
    ['the time zone', { timeZone: undefined }],
    ['a valid time zone', { timeZone: 'Mars/Olympus' }],
    ['the meeting link', { meetingLink: undefined }],
    ['a secure meeting link', { meetingLink: 'http://meet.example.com' }],
  ])('should return null without %s', (_, overrides) => {
    expect(parseCallBookingSettings({ ...stored, ...overrides })).toBeNull();
  });

  it('should return null when there is no document', () => {
    expect(parseCallBookingSettings(undefined)).toBeNull();
  });
});
