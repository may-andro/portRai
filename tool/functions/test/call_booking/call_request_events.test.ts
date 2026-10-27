import { describe, expect, it, vi } from 'vitest';

import {
  type CallRequestEventDependencies,
  callRequestDecision,
  handleCallRequestDecision,
  handleNewCallRequest,
} from '../../src/call_booking/call_request_events.js';
import type { Email } from '../../src/shared/email.js';
import { callRequest, now, owner, settings } from './fixture.js';

function dependencies(
  overrides: Partial<CallRequestEventDependencies> = {},
): CallRequestEventDependencies {
  return {
    loadSettings: vi.fn().mockResolvedValue(settings()),
    loadOwner: vi.fn().mockResolvedValue(owner),
    emailSender: { send: vi.fn().mockResolvedValue(undefined) },
    devices: {
      listDevices: vi
        .fn()
        .mockResolvedValue([{ token: 'phone', locale: 'nl' }]),
      deleteDevices: vi.fn().mockResolvedValue(undefined),
      sender: {
        sendToTokens: vi.fn().mockResolvedValue([]),
        sendToTopic: vi.fn(),
      },
    },
    releaseSlot: vi.fn().mockResolvedValue(undefined),
    ...overrides,
  };
}

function sentEmails(deps: CallRequestEventDependencies): Email[] {
  return vi.mocked(deps.emailSender.send).mock.calls.map(([email]) => email);
}

describe('handleNewCallRequest', () => {
  it("should notify the owner's devices and email the visitor", async () => {
    const deps = dependencies();

    const outcome = await handleNewCallRequest(
      deps,
      'owner-uid',
      callRequest(),
    );

    expect(outcome).toEqual({ kind: 'handled', failures: [] });
    expect(deps.devices.listDevices).toHaveBeenCalledWith('owner-uid');
    expect(deps.devices.sender.sendToTokens).toHaveBeenCalledWith(
      ['phone'],
      expect.objectContaining({ title: 'Nieuw belverzoek' }),
    );
    expect(sentEmails(deps)).toEqual([
      expect.objectContaining({
        to: 'visitor@example.com',
        subject: 'Your call request with Owner Name',
      }),
    ]);
  });

  it('should still email the visitor when the notification fails', async () => {
    const error = new Error('FCM down');
    const deps = dependencies({
      devices: {
        ...dependencies().devices,
        listDevices: vi.fn().mockRejectedValue(error),
      },
    });

    const outcome = await handleNewCallRequest(
      deps,
      'owner-uid',
      callRequest(),
    );

    expect(outcome).toEqual({
      kind: 'handled',
      failures: [{ step: 'owner_notification', error }],
    });
    expect(deps.emailSender.send).toHaveBeenCalledTimes(1);
  });

  it('should do nothing when the owner has no profile', async () => {
    const deps = dependencies({ loadOwner: vi.fn().mockResolvedValue(null) });

    const outcome = await handleNewCallRequest(
      deps,
      'owner-uid',
      callRequest(),
    );

    expect(outcome).toEqual({ kind: 'not_set_up' });
    expect(deps.emailSender.send).not.toHaveBeenCalled();
  });
});

describe('callRequestDecision', () => {
  it.each([
    ['accepted', 'accepted'],
    ['declined', 'declined'],
    ['requested', null],
  ] as const)(
    'should see %s after a waiting request as %s',
    (status, decision) => {
      expect(callRequestDecision(callRequest(), callRequest({ status }))).toBe(
        decision,
      );
    },
  );

  it('should ignore changes to a request that was already answered', () => {
    expect(
      callRequestDecision(
        callRequest({ status: 'accepted' }),
        callRequest({ status: 'declined' }),
      ),
    ).toBeNull();
  });
});

describe('handleCallRequestDecision', () => {
  it('should send the invite to the visitor and the owner when accepted', async () => {
    const deps = dependencies();

    const outcome = await handleCallRequestDecision(
      deps,
      'accepted',
      callRequest({ status: 'accepted' }),
      now,
    );

    expect(outcome).toEqual({ kind: 'handled', failures: [] });
    const [visitorEmail, ownerEmail] = sentEmails(deps);
    expect(visitorEmail).toMatchObject({
      to: 'visitor@example.com',
      subject: 'Your call with Owner Name is confirmed',
    });
    expect(ownerEmail).toMatchObject({ to: 'owner@example.com' });
    for (const email of [visitorEmail, ownerEmail]) {
      expect(email.calendarInvite).toContain('UID:request-1@portrai');
      expect(email.calendarInvite).toContain(
        'LOCATION:https://meet.example.com/owner',
      );
    }
    expect(deps.releaseSlot).not.toHaveBeenCalled();
  });

  it('should free the slot and tell the visitor when declined', async () => {
    const deps = dependencies();

    await handleCallRequestDecision(
      deps,
      'declined',
      callRequest({ status: 'declined' }),
      now,
    );

    expect(deps.releaseSlot).toHaveBeenCalledWith(
      '2026-11-03T08:00:00.000Z',
      'request-1',
    );
    expect(sentEmails(deps)).toEqual([
      expect.objectContaining({ subject: 'About your call request' }),
    ]);
    expect(sentEmails(deps)[0].calendarInvite).toBeUndefined();
  });
});
