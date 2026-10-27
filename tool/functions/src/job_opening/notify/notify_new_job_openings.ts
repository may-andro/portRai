import type { PushNotification } from '../../shared/messaging.js';
import {
  type UserDeviceNotifier,
  notifyUserDevices,
} from '../../shared/user_devices.js';

export type NewJobOpeningsNotifier = UserDeviceNotifier;

/** Tells the app what a tapped notification is about. */
export const newJobOpeningsKind = 'job_openings';

const texts: Record<string, (count: number) => [string, string]> = {
  en: (count) => [
    'New jobs for you',
    count === 1
      ? '1 new job opening matches your portfolio.'
      : `${count} new job openings match your portfolio.`,
  ],
  es: (count) => [
    'Nuevas ofertas para ti',
    count === 1
      ? '1 nueva oferta de empleo encaja con tu portfolio.'
      : `${count} nuevas ofertas de empleo encajan con tu portfolio.`,
  ],
  nl: (count) => [
    'Nieuwe vacatures voor jou',
    count === 1
      ? '1 nieuwe vacature past bij je portfolio.'
      : `${count} nieuwe vacatures passen bij je portfolio.`,
  ],
};

/** The notification for [count] new openings in [locale], English otherwise. */
export function newJobOpeningsNotification(
  locale: string,
  count: number,
): PushNotification {
  const [title, body] = (texts[locale] ?? texts.en)(count);
  return {
    title,
    body,
    data: { kind: newJobOpeningsKind },
    group: newJobOpeningsKind,
  };
}

/**
 * Sends the notification for [count] new openings to every device of
 * [userId], in each device's language, and deletes the devices whose token is
 * no longer registered. Returns whether the user has any device.
 */
export function notifyNewJobOpenings(
  notifier: NewJobOpeningsNotifier,
  userId: string,
  count: number,
): Promise<boolean> {
  return notifyUserDevices(notifier, userId, Object.keys(texts), (language) =>
    newJobOpeningsNotification(language, count),
  );
}
