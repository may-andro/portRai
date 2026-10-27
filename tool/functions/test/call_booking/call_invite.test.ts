import { describe, expect, it } from 'vitest';

import { callInviteCalendar } from '../../src/call_booking/call_invite.js';
import { now } from './fixture.js';

const invite = {
  uid: 'request-1@portrai',
  start: new Date('2026-11-03T08:00:00Z'),
  end: new Date('2026-11-03T08:30:00Z'),
  summary: 'Owner / Visitor: Flutter, apps; more',
  description: 'Flutter consulting\n\nhttps://meet.example.com/owner',
  location: 'https://meet.example.com/owner',
  organizer: { name: 'Owner "The" Name', email: 'owner@example.com' },
  attendee: { name: 'Visitor Name', email: 'visitor@example.com' },
  createdAt: now,
};

describe('callInviteCalendar', () => {
  it('should write a request event with UTC times', () => {
    const calendar = callInviteCalendar(invite);

    expect(calendar).toContain('METHOD:REQUEST\r\n');
    expect(calendar).toContain('UID:request-1@portrai\r\n');
    expect(calendar).toContain('DTSTART:20261103T080000Z\r\n');
    expect(calendar).toContain('DTEND:20261103T083000Z\r\n');
    expect(calendar).toContain('DTSTAMP:20261102T080000Z\r\n');
    expect(calendar.endsWith('END:VCALENDAR\r\n')).toBe(true);
  });

  it('should escape commas, semicolons and line breaks in texts', () => {
    const calendar = callInviteCalendar(invite);

    expect(calendar).toContain(
      'SUMMARY:Owner / Visitor: Flutter\\, apps\; more\r\n',
    );
    expect(calendar).toContain(
      'DESCRIPTION:Flutter consulting\\n\\nhttps://meet.example.com/owner',
    );
  });

  it('should drop double quotes from names', () => {
    expect(callInviteCalendar(invite)).toContain(
      'ORGANIZER;CN="Owner The Name":mailto:owner@example.com',
    );
  });

  it('should fold lines longer than 75 bytes without splitting a character', () => {
    const calendar = callInviteCalendar({
      ...invite,
      description: 'é'.repeat(100),
    });

    for (const line of calendar.split('\r\n')) {
      expect(Buffer.byteLength(line)).toBeLessThanOrEqual(75);
    }
    const unfolded = calendar.replace(/\r\n /g, '');
    expect(unfolded).toContain(`DESCRIPTION:${'é'.repeat(100)}\r\n`);
  });
});
