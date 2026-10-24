import type { PushNotification, PushSender } from '../../shared/messaging.js';

/** A device of a user that receives their notifications. */
export interface UserDevice {
  token: string;
  /** The app's language on the device, such as `es`. */
  locale: string;
}

export interface NewJobOpeningsNotifier {
  listDevices(userId: string): Promise<UserDevice[]>;
  deleteDevices(userId: string, tokens: string[]): Promise<void>;
  sender: PushSender;
}

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
export async function notifyNewJobOpenings(
  { listDevices, deleteDevices, sender }: NewJobOpeningsNotifier,
  userId: string,
  count: number,
): Promise<boolean> {
  const devices = await listDevices(userId);
  const tokensByLocale = new Map<string, string[]>();
  for (const { token, locale } of devices) {
    const key = locale in texts ? locale : 'en';
    tokensByLocale.set(key, [...(tokensByLocale.get(key) ?? []), token]);
  }
  const unregistered: string[] = [];
  for (const [locale, tokens] of tokensByLocale) {
    unregistered.push(
      ...(await sender.sendToTokens(
        tokens,
        newJobOpeningsNotification(locale, count),
      )),
    );
  }
  if (unregistered.length > 0) await deleteDevices(userId, unregistered);
  return devices.length > 0;
}
