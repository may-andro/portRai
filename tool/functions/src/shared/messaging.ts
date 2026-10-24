import type { Message, Messaging } from 'firebase-admin/messaging';

/** A notification as every platform shows it. */
export interface PushNotification {
  title: string;
  body: string;
  /** Read by the app when the notification is tapped. */
  data: Record<string, string>;
  /** A newer notification with the same group replaces the shown one. */
  group: string;
}

export interface PushSender {
  /**
   * Sends [notification] to every token and returns the tokens that are no
   * longer registered, so their owner can delete them. Throws when every
   * send fails for another reason.
   */
  sendToTokens(
    tokens: readonly string[],
    notification: PushNotification,
  ): Promise<string[]>;
  sendToTopic(topic: string, notification: PushNotification): Promise<void>;
}

// The most tokens one multicast request accepts.
const maxTokensPerRequest = 500;

// Errors that mean the token will never work again.
const unregisteredCodes = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/** Sends through Firebase Cloud Messaging. */
export function cloudMessagingSender(messaging: Messaging): PushSender {
  return {
    async sendToTokens(tokens, notification) {
      const unregistered: string[] = [];
      let lastError: unknown;
      let failedCount = 0;
      for (let start = 0; start < tokens.length; start += maxTokensPerRequest) {
        const batch = tokens.slice(start, start + maxTokensPerRequest);
        const { responses } = await messaging.sendEachForMulticast({
          ...toMessage(notification),
          tokens: batch,
        });
        responses.forEach((response, index) => {
          if (response.success) return;
          if (unregisteredCodes.has(response.error?.code ?? '')) {
            unregistered.push(batch[index]);
          } else {
            failedCount++;
            lastError = response.error;
          }
        });
      }
      if (tokens.length > 0 && failedCount === tokens.length) {
        throw new Error(`Every push send failed: ${String(lastError)}`);
      }
      return unregistered;
    },

    async sendToTopic(topic, notification) {
      await messaging.send({ ...toMessage(notification), topic });
    },
  };
}

function toMessage({
  title,
  body,
  data,
  group,
}: PushNotification): Omit<Message, 'token' | 'topic' | 'condition'> {
  return {
    notification: { title, body },
    data,
    android: { collapseKey: group, notification: { tag: group } },
    apns: { headers: { 'apns-collapse-id': group } },
  };
}
