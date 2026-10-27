import type { Firestore } from 'firebase-admin/firestore';

import type { PushNotification, PushSender } from './messaging.js';

/** A device of a user that receives their notifications. */
export interface UserDevice {
  token: string;
  /** The app's language on the device, such as `es`. */
  locale: string;
}

export interface UserDeviceNotifier {
  listDevices(userId: string): Promise<UserDevice[]>;
  deleteDevices(userId: string, tokens: string[]): Promise<void>;
  sender: PushSender;
}

/** The devices at `users/{uid}/devices/{token}` that receive notifications. */
export async function listUserDevices(
  db: Firestore,
  userId: string,
): Promise<UserDevice[]> {
  const snapshot = await db
    .collection('users')
    .doc(userId)
    .collection('devices')
    .get();
  return snapshot.docs.map((document) => {
    const locale = document.get('locale');
    return {
      token: document.id,
      locale: typeof locale === 'string' ? locale : 'en',
    };
  });
}

export async function deleteUserDevices(
  db: Firestore,
  userId: string,
  tokens: string[],
): Promise<void> {
  const collection = db.collection('users').doc(userId).collection('devices');
  const writer = db.bulkWriter();
  for (const token of tokens) void writer.delete(collection.doc(token));
  await writer.close();
}

/** Lists and deletes the devices in [db]. */
export function firestoreUserDevices(
  db: Firestore,
): Omit<UserDeviceNotifier, 'sender'> {
  return {
    listDevices: (userId) => listUserDevices(db, userId),
    deleteDevices: (userId, tokens) => deleteUserDevices(db, userId, tokens),
  };
}

/**
 * Sends [notificationFor] each device's language to every device of
 * [userId], using English for a language outside [languages], and deletes
 * the devices whose token is no longer registered. Returns whether the user
 * has any device.
 */
export async function notifyUserDevices(
  { listDevices, deleteDevices, sender }: UserDeviceNotifier,
  userId: string,
  languages: readonly string[],
  notificationFor: (language: string) => PushNotification,
): Promise<boolean> {
  const devices = await listDevices(userId);
  const tokensByLanguage = new Map<string, string[]>();
  for (const { token, locale } of devices) {
    const language = languages.includes(locale) ? locale : 'en';
    tokensByLanguage.set(language, [
      ...(tokensByLanguage.get(language) ?? []),
      token,
    ]);
  }
  const unregistered: string[] = [];
  for (const [language, tokens] of tokensByLanguage) {
    unregistered.push(
      ...(await sender.sendToTokens(tokens, notificationFor(language))),
    );
  }
  if (unregistered.length > 0) await deleteDevices(userId, unregistered);
  return devices.length > 0;
}
