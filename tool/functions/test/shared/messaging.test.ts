import type { Messaging } from 'firebase-admin/messaging';
import { describe, expect, it, vi } from 'vitest';

import {
  cloudMessagingSender,
  type PushNotification,
} from '../../src/shared/messaging.js';

const notification: PushNotification = {
  title: 'Title',
  body: 'Body',
  data: { kind: 'item' },
  group: 'items',
};

type SendEachForMulticast = (message: { tokens: string[] }) => Promise<{
  responses: Array<{ success: boolean; error?: { code: string } }>;
}>;

function messaging(
  sendEachForMulticast: SendEachForMulticast = async ({ tokens }) => ({
    responses: tokens.map(() => ({ success: true })),
  }),
) {
  return {
    sendEachForMulticast: vi.fn(sendEachForMulticast),
    send: vi.fn().mockResolvedValue('message-id'),
  };
}

function failure(code: string) {
  return { success: false, error: { code, message: code } };
}

describe('cloudMessagingSender', () => {
  it('should send the notification with its data and group to every token', async () => {
    const fake = messaging();

    const unregistered = await cloudMessagingSender(
      fake as unknown as Messaging,
    ).sendToTokens(['token-1', 'token-2'], notification);

    expect(unregistered).toEqual([]);
    expect(fake.sendEachForMulticast).toHaveBeenCalledWith({
      notification: { title: 'Title', body: 'Body' },
      data: { kind: 'item' },
      android: { collapseKey: 'items', notification: { tag: 'items' } },
      apns: { headers: { 'apns-collapse-id': 'items' } },
      tokens: ['token-1', 'token-2'],
    });
  });

  it('should send at most 500 tokens per request', async () => {
    const fake = messaging();
    const tokens = Array.from({ length: 501 }, (_, index) => `token-${index}`);

    await cloudMessagingSender(fake as unknown as Messaging).sendToTokens(
      tokens,
      notification,
    );

    expect(fake.sendEachForMulticast).toHaveBeenCalledTimes(2);
    expect(fake.sendEachForMulticast.mock.calls[1][0].tokens).toEqual([
      'token-500',
    ]);
  });

  it('should return the tokens that are no longer registered', async () => {
    const fake = messaging(async () => ({
      responses: [
        { success: true },
        failure('messaging/registration-token-not-registered'),
        failure('messaging/invalid-registration-token'),
        failure('messaging/internal-error'),
      ],
    }));

    const unregistered = await cloudMessagingSender(
      fake as unknown as Messaging,
    ).sendToTokens(['ok', 'gone', 'invalid', 'busy'], notification);

    expect(unregistered).toEqual(['gone', 'invalid']);
  });

  it('should throw when every send fails for another reason', async () => {
    const fake = messaging(async () => ({
      responses: [failure('messaging/internal-error')],
    }));

    await expect(
      cloudMessagingSender(fake as unknown as Messaging).sendToTokens(
        ['token-1'],
        notification,
      ),
    ).rejects.toThrow('Every push send failed');
  });

  it('should send the notification to the topic', async () => {
    const fake = messaging();

    await cloudMessagingSender(fake as unknown as Messaging).sendToTopic(
      'updates',
      notification,
    );

    expect(fake.send).toHaveBeenCalledWith(
      expect.objectContaining({
        topic: 'updates',
        notification: { title: 'Title', body: 'Body' },
      }),
    );
  });
});
