import { describe, expect, it, vi } from 'vitest';

import {
  bookCall,
  type CallBookingStore,
  listOpenCallSlots,
  maxOpenRequestsPerEmail,
  maxRequestsPerDay,
} from '../../src/call_booking/book_call.js';
import { now, requestData, settings } from './fixture.js';

function store(overrides: Partial<CallBookingStore> = {}): CallBookingStore {
  return {
    loadSettings: vi.fn().mockResolvedValue(settings()),
    listTakenSlotIds: vi.fn().mockResolvedValue(new Set<string>()),
    countOpenRequests: vi.fn().mockResolvedValue(0),
    countRequestsSince: vi.fn().mockResolvedValue(0),
    saveRequest: vi.fn().mockResolvedValue('request-1'),
    ...overrides,
  };
}

describe('listOpenCallSlots', () => {
  it('should return the free slots with the slot length and time zone', async () => {
    const openSlots = await listOpenCallSlots(
      store({
        listTakenSlotIds: vi
          .fn()
          .mockResolvedValue(new Set(['2026-11-03T08:00:00.000Z'])),
      }),
      now,
    );

    expect(openSlots?.slots[0]).toBe('2026-11-03T08:30:00.000Z');
    expect(openSlots).toMatchObject({
      slotMinutes: 30,
      timeZone: 'Europe/Madrid',
    });
  });

  it('should return null when booking is not set up', async () => {
    const openSlots = await listOpenCallSlots(
      store({ loadSettings: vi.fn().mockResolvedValue(null) }),
      now,
    );

    expect(openSlots).toBeNull();
  });
});

describe('bookCall', () => {
  it('should save the request with its end and expiry when the slot is free', async () => {
    const deps = store();

    const outcome = await bookCall(deps, requestData(), now);

    expect(outcome).toEqual({ kind: 'requested', requestId: 'request-1' });
    expect(deps.saveRequest).toHaveBeenCalledWith(
      'owner-uid',
      expect.objectContaining({
        email: 'visitor@example.com',
        slotEnd: new Date('2026-11-03T08:30:00.000Z'),
        status: 'requested',
        createdAt: now,
      }),
      new Date('2026-12-03T08:30:00.000Z'),
    );
    expect(deps.countOpenRequests).toHaveBeenCalledWith(
      'owner-uid',
      'visitor@example.com',
    );
    expect(deps.countRequestsSince).toHaveBeenCalledWith(
      'owner-uid',
      new Date('2026-11-01T08:00:00.000Z'),
    );
  });

  it('should report the invalid field without reading the settings', async () => {
    const deps = store();

    const outcome = await bookCall(deps, requestData({ email: 'x' }), now);

    expect(outcome).toEqual({ kind: 'invalid', field: 'email' });
    expect(deps.loadSettings).not.toHaveBeenCalled();
  });

  it('should refuse when booking is not set up', async () => {
    const outcome = await bookCall(
      store({ loadSettings: vi.fn().mockResolvedValue(null) }),
      requestData(),
      now,
    );

    expect(outcome).toEqual({ kind: 'not_set_up' });
  });

  it('should refuse a start that is not an offered slot', async () => {
    const deps = store();

    const outcome = await bookCall(
      deps,
      requestData({ slotStart: '2026-11-03T08:10:00.000Z' }),
      now,
    );

    expect(outcome).toEqual({ kind: 'slot_not_offered' });
    expect(deps.saveRequest).not.toHaveBeenCalled();
  });

  it('should refuse when the address already has its open requests', async () => {
    const deps = store({
      countOpenRequests: vi.fn().mockResolvedValue(maxOpenRequestsPerEmail),
    });

    const outcome = await bookCall(deps, requestData(), now);

    expect(outcome).toEqual({ kind: 'too_many_open_requests' });
    expect(deps.saveRequest).not.toHaveBeenCalled();
  });

  it('should refuse when the day has reached its limit', async () => {
    const outcome = await bookCall(
      store({
        countRequestsSince: vi.fn().mockResolvedValue(maxRequestsPerDay),
      }),
      requestData(),
      now,
    );

    expect(outcome).toEqual({ kind: 'daily_limit' });
  });

  it('should report a taken slot when another request took it first', async () => {
    const outcome = await bookCall(
      store({ saveRequest: vi.fn().mockResolvedValue(null) }),
      requestData(),
      now,
    );

    expect(outcome).toEqual({ kind: 'slot_taken' });
  });
});
