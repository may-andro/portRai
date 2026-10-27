import { describe, expect, it, vi } from 'vitest';

import type { PushNotification } from '../../src/shared/messaging.js';
import {
  notifyUserDevices,
  type UserDeviceNotifier,
} from '../../src/shared/user_devices.js';

function notifier(
  overrides: Partial<UserDeviceNotifier> = {},
): UserDeviceNotifier {
  return {
    listDevices: vi.fn().mockResolvedValue([
      { token: 'phone', locale: 'nl' },
      { token: 'tablet', locale: 'de' },
    ]),
    deleteDevices: vi.fn().mockResolvedValue(undefined),
    sender: {
      sendToTokens: vi.fn().mockResolvedValue([]),
      sendToTopic: vi.fn(),
    },
    ...overrides,
  };
}

const notificationFor = (language: string): PushNotification => ({
  title: language,
  body: language,
  data: {},
  group: 'test',
});

describe('notifyUserDevices', () => {
  it('should send in English to a device whose language is not supported', async () => {
    const deps = notifier();

    await notifyUserDevices(deps, 'owner-uid', ['en', 'nl'], notificationFor);

    expect(deps.sender.sendToTokens).toHaveBeenCalledWith(
      ['phone'],
      notificationFor('nl'),
    );
    expect(deps.sender.sendToTokens).toHaveBeenCalledWith(
      ['tablet'],
      notificationFor('en'),
    );
  });

  it('should delete the devices the sender reports as unregistered', async () => {
    const deps = notifier({
      sender: {
        sendToTokens: vi.fn().mockResolvedValue(['tablet']),
        sendToTopic: vi.fn(),
      },
    });

    await notifyUserDevices(deps, 'owner-uid', ['en'], notificationFor);

    expect(deps.deleteDevices).toHaveBeenCalledWith('owner-uid', ['tablet']);
  });

  it('should return false without sending when the user has no device', async () => {
    const deps = notifier({ listDevices: vi.fn().mockResolvedValue([]) });

    const hasDevices = await notifyUserDevices(
      deps,
      'owner-uid',
      ['en'],
      notificationFor,
    );

    expect(hasDevices).toBe(false);
    expect(deps.sender.sendToTokens).not.toHaveBeenCalled();
  });
});
