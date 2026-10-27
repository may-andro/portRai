import { describe, expect, it } from 'vitest';

import {
  callRequestMaxLengths,
  parseCallRequestInput,
  parseStoredCallRequest,
} from '../../src/call_booking/call_request.js';
import { requestData } from './fixture.js';

describe('parseCallRequestInput', () => {
  it('should read the request and store the email in lowercase', () => {
    expect(parseCallRequestInput(requestData())).toEqual({
      input: {
        slotStart: new Date('2026-11-03T08:00:00.000Z'),
        name: 'Visitor Name',
        email: 'visitor@example.com',
        topic: 'Flutter consulting',
        message: 'Looking for help with an app.',
        language: 'es',
        timeZone: 'America/New_York',
      },
    });
  });

  it('should trim the texts and allow a missing message', () => {
    const parsed = parseCallRequestInput(
      requestData({ name: '  Visitor  ', message: undefined }),
    );

    expect(parsed).toMatchObject({ input: { name: 'Visitor', message: '' } });
  });

  it('should fall back to English and no time zone when they are unknown', () => {
    const parsed = parseCallRequestInput(
      requestData({ locale: 'fr', timeZone: 'Nowhere/Land' }),
    );

    expect(parsed).toMatchObject({
      input: { language: 'en', timeZone: null },
    });
  });

  it.each([
    ['slotStart', { slotStart: 'next Tuesday' }],
    ['slotStart', { slotStart: undefined }],
    ['name', { name: '   ' }],
    ['name', { name: 'n'.repeat(callRequestMaxLengths.name + 1) }],
    ['email', { email: 'not-an-email' }],
    ['email', { email: 42 }],
    ['topic', { topic: '' }],
    ['message', { message: 'm'.repeat(callRequestMaxLengths.message + 1) }],
  ])('should report %s when it is invalid', (field, overrides) => {
    expect(parseCallRequestInput(requestData(overrides))).toEqual({
      invalidField: field,
    });
  });
});

describe('parseStoredCallRequest', () => {
  const timestamp = (iso: string) => ({ toDate: () => new Date(iso) });
  const stored = {
    slotStart: timestamp('2026-11-03T08:00:00Z'),
    slotEnd: timestamp('2026-11-03T08:30:00Z'),
    createdAt: timestamp('2026-11-02T08:00:00Z'),
    name: 'Visitor Name',
    email: 'visitor@example.com',
    topic: 'Flutter consulting',
    message: '',
    locale: 'nl',
    timeZone: null,
    status: 'accepted',
  };

  it('should read a stored request with Firestore timestamps', () => {
    expect(parseStoredCallRequest('request-1', stored)).toMatchObject({
      id: 'request-1',
      slotStart: new Date('2026-11-03T08:00:00Z'),
      language: 'nl',
      timeZone: null,
      status: 'accepted',
    });
  });

  it.each([
    ['an unknown status', { status: 'maybe' }],
    ['a missing slot', { slotStart: undefined }],
    ['a missing email', { email: undefined }],
  ])('should return null for %s', (_, overrides) => {
    expect(
      parseStoredCallRequest('request-1', { ...stored, ...overrides }),
    ).toBeNull();
  });
});
