import { describe, expect, it } from 'vitest';

import {
  callTime,
  newCallRequestNotification,
  ownerAcceptedEmail,
  visitorEmail,
} from '../../src/call_booking/call_messages.js';
import { callRequest, owner } from './fixture.js';

const meetingLink = 'https://meet.example.com/owner';

describe('callTime', () => {
  it.each([
    ['en', 'Tuesday, November 3, 2026 at 9:00 AM GMT+1'],
    ['es', 'martes, 3 de noviembre de 2026, 9:00 CET'],
    ['nl', 'dinsdag 3 november 2026 om 09:00 CET'],
  ] as const)('should write the time in %s', (language, expected) => {
    expect(
      callTime(new Date('2026-11-03T08:00:00Z'), 'Europe/Madrid', language),
    ).toBe(expected);
  });
});

describe('visitorEmail', () => {
  it("should show the time in the visitor's time zone and reply to the owner", () => {
    const email = visitorEmail(
      'received',
      callRequest(),
      owner,
      'Europe/Madrid',
      meetingLink,
    );

    expect(email).toMatchObject({
      to: 'visitor@example.com',
      replyTo: 'owner@example.com',
      subject: 'Your call request with Owner Name',
    });
    expect(email.text).toContain('Hi Visitor Name,');
    expect(email.text).toContain('"Flutter consulting"');
    expect(email.text).toContain('Tuesday, November 3, 2026 at 3:00 AM EST');
  });

  it("should use the owner's time zone when the visitor sent none", () => {
    const email = visitorEmail(
      'declined',
      callRequest({ timeZone: null }),
      owner,
      'Europe/Madrid',
      meetingLink,
    );

    expect(email.text).toContain('9:00 AM GMT+1');
    expect(email.subject).toBe('About your call request');
  });

  it("should write in the visitor's language", () => {
    const email = visitorEmail(
      'accepted',
      callRequest({ language: 'nl' }),
      owner,
      'Europe/Madrid',
      meetingLink,
    );

    expect(email.subject).toBe('Je gesprek met Owner Name is bevestigd');
    expect(email.text).toContain(`Doe hier mee: ${meetingLink}`);
  });

  it('should not fill placeholders written by the visitor', () => {
    const email = visitorEmail(
      'received',
      callRequest({ topic: 'About {link}' }),
      owner,
      'Europe/Madrid',
      meetingLink,
    );

    expect(email.text).toContain('"About {link}"');
  });
});

describe('ownerAcceptedEmail', () => {
  it("should give the owner the visitor's details and reply to the visitor", () => {
    const email = ownerAcceptedEmail(
      callRequest({ message: '' }),
      owner,
      'Europe/Madrid',
      meetingLink,
    );

    expect(email).toMatchObject({
      to: 'owner@example.com',
      replyTo: 'visitor@example.com',
      subject: 'Call with Visitor Name confirmed',
    });
    expect(email.text).toContain('Visitor Name (visitor@example.com)');
    expect(email.text).toContain('Message:\n-');
  });
});

describe('newCallRequestNotification', () => {
  it("should name the visitor and the time in the owner's time zone", () => {
    expect(
      newCallRequestNotification('es', callRequest(), 'Europe/Madrid'),
    ).toEqual({
      title: 'Nueva solicitud de llamada',
      body: 'Visitor Name · martes, 3 de noviembre de 2026, 9:00 CET',
      data: { kind: 'call_request', requestId: 'request-1' },
      group: 'call_request_request-1',
    });
  });

  it('should fall back to English for another device language', () => {
    expect(
      newCallRequestNotification('de', callRequest(), 'Europe/Madrid').title,
    ).toBe('New call request');
  });
});
