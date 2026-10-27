import { describe, expect, it } from 'vitest';

import {
  callSlotId,
  isCallSlot,
  openCallSlots,
} from '../../src/call_booking/call_slots.js';
import { now, settings } from './fixture.js';

const ids = (slots: Date[]) => slots.map(callSlotId);

describe('openCallSlots', () => {
  it('should offer the slots after the notice until the horizon ends', () => {
    const slots = openCallSlots(settings(), now);

    // Monday is within the notice; Tuesday and Wednesday 09:00 to 11:00 in
    // Madrid are 08:00 to 10:00 UTC.
    expect(ids(slots)).toEqual([
      '2026-11-03T08:00:00.000Z',
      '2026-11-03T08:30:00.000Z',
      '2026-11-03T09:00:00.000Z',
      '2026-11-03T09:30:00.000Z',
      '2026-11-04T08:00:00.000Z',
      '2026-11-04T08:30:00.000Z',
      '2026-11-04T09:00:00.000Z',
      '2026-11-04T09:30:00.000Z',
    ]);
  });

  it('should leave out the taken slots', () => {
    const slots = openCallSlots(
      settings(),
      now,
      new Set(['2026-11-03T08:30:00.000Z']),
    );

    expect(ids(slots)).not.toContain('2026-11-03T08:30:00.000Z');
    expect(slots).toHaveLength(7);
  });

  it('should offer no slots on days without hours', () => {
    const slots = openCallSlots(
      settings({ minNoticeHours: 0, horizonDays: 7 }),
      // Saturday 7 November.
      new Date('2026-11-07T08:00:00Z'),
    );

    expect(ids(slots)[0]).toBe('2026-11-09T08:00:00.000Z');
  });

  it('should not offer a slot that does not fit before the range ends', () => {
    const slots = openCallSlots(
      settings({
        minNoticeHours: 0,
        horizonDays: 1,
        slotMinutes: 45,
      }),
      new Date('2026-11-02T07:00:00Z'),
    );

    // 09:00 and 09:45; 10:30 would end after 11:00.
    expect(ids(slots)).toEqual([
      '2026-11-02T08:00:00.000Z',
      '2026-11-02T08:45:00.000Z',
    ]);
  });

  it('should offer a slot once when time ranges overlap', () => {
    const slots = openCallSlots(
      settings({
        minNoticeHours: 0,
        horizonDays: 1,
        weeklyHours: {
          ...settings().weeklyHours,
          monday: [
            { start: '09:00', end: '10:00' },
            { start: '09:30', end: '10:30' },
          ],
        },
      }),
      new Date('2026-11-02T07:00:00Z'),
    );

    expect(ids(slots)).toEqual([
      '2026-11-02T08:00:00.000Z',
      '2026-11-02T08:30:00.000Z',
      '2026-11-02T09:00:00.000Z',
    ]);
  });

  it('should skip the local times a daylight saving change leaves out', () => {
    const slots = openCallSlots(
      settings({
        minNoticeHours: 0,
        horizonDays: 2,
        weeklyHours: {
          ...settings().weeklyHours,
          sunday: [{ start: '01:30', end: '03:30' }],
        },
      }),
      // Saturday 27 March 2027; clocks in Madrid go from 02:00 to 03:00 on Sunday.
      new Date('2027-03-27T00:00:00Z'),
    );

    // 01:30 winter time and 03:00 summer time; 02:00 and 02:30 do not exist.
    expect(ids(slots)).toEqual([
      '2027-03-28T00:30:00.000Z',
      '2027-03-28T01:00:00.000Z',
    ]);
  });

  it('should follow the summer offset of the time zone', () => {
    const slots = openCallSlots(
      settings({ minNoticeHours: 0, horizonDays: 1 }),
      // Monday 6 September 2027, when Madrid is two hours ahead of UTC.
      new Date('2027-09-06T05:00:00Z'),
    );

    expect(ids(slots)[0]).toBe('2027-09-06T07:00:00.000Z');
  });
});

describe('isCallSlot', () => {
  it('should accept an offered slot even when it is taken', () => {
    expect(
      isCallSlot(settings(), now, new Date('2026-11-03T08:30:00.000Z')),
    ).toBe(true);
  });

  it.each([
    ['between two slots', '2026-11-03T08:15:00.000Z'],
    ['within the notice', '2026-11-02T09:00:00.000Z'],
    ['after the horizon', '2026-11-05T08:00:00.000Z'],
  ])('should reject a start %s', (_, start) => {
    expect(isCallSlot(settings(), now, new Date(start))).toBe(false);
  });
});
