import { describe, expect, it, vi } from 'vitest';

import {
  type NewJobOpeningsNotifier,
  newJobOpeningsNotification,
  notifyNewJobOpenings,
} from '../../../src/job_opening/notify/notify_new_job_openings.js';

function notifier(
  overrides: Partial<NewJobOpeningsNotifier> = {},
): NewJobOpeningsNotifier {
  return {
    listDevices: vi.fn().mockResolvedValue([
      { token: 'phone', locale: 'es' },
      { token: 'tablet', locale: 'en' },
      { token: 'old-phone', locale: 'fr' },
    ]),
    deleteDevices: vi.fn().mockResolvedValue(undefined),
    sender: {
      sendToTokens: vi.fn().mockResolvedValue([]),
      sendToTopic: vi.fn(),
    },
    ...overrides,
  };
}

describe('newJobOpeningsNotification', () => {
  it.each([
    ['en', 1, '1 new job opening matches your portfolio.'],
    ['en', 3, '3 new job openings match your portfolio.'],
    ['es', 2, '2 nuevas ofertas de empleo encajan con tu portfolio.'],
    ['nl', 1, '1 nieuwe vacature past bij je portfolio.'],
    ['fr', 2, '2 new job openings match your portfolio.'],
  ])('should say %s with %d openings as %s', (locale, count, body) => {
    expect(newJobOpeningsNotification(locale, count)).toMatchObject({
      body,
      data: { kind: 'job_openings' },
      group: 'job_openings',
    });
  });
});

describe('notifyNewJobOpenings', () => {
  it("should send to the user's devices in each device's language", async () => {
    const deps = notifier();

    const hasDevices = await notifyNewJobOpenings(deps, 'owner-uid', 2);

    expect(hasDevices).toBe(true);
    expect(deps.listDevices).toHaveBeenCalledWith('owner-uid');
    expect(deps.sender.sendToTokens).toHaveBeenCalledWith(
      ['phone'],
      newJobOpeningsNotification('es', 2),
    );
    expect(deps.sender.sendToTokens).toHaveBeenCalledWith(
      ['tablet', 'old-phone'],
      newJobOpeningsNotification('en', 2),
    );
    expect(deps.deleteDevices).not.toHaveBeenCalled();
  });

  it('should delete the devices whose token is no longer registered', async () => {
    const deps = notifier({
      sender: {
        sendToTokens: vi.fn(async (tokens: readonly string[]) =>
          tokens.filter((token) => token === 'old-phone'),
        ),
        sendToTopic: vi.fn(),
      },
    });

    await notifyNewJobOpenings(deps, 'owner-uid', 2);

    expect(deps.deleteDevices).toHaveBeenCalledWith('owner-uid', ['old-phone']);
  });

  it('should send nothing when the user has no device', async () => {
    const deps = notifier({ listDevices: vi.fn().mockResolvedValue([]) });

    const hasDevices = await notifyNewJobOpenings(deps, 'owner-uid', 2);

    expect(hasDevices).toBe(false);
    expect(deps.sender.sendToTokens).not.toHaveBeenCalled();
  });
});
