import { isDeepStrictEqual } from 'node:util';

import type { PushNotification, PushSender } from '../shared/messaging.js';

/** The public portfolio collections, one document per locale. */
export const portfolioCollections = [
  'profile',
  'experiences',
  'expertise',
  'projects',
  'services',
  'testimonials',
] as const;

/**
 * One import writes many documents within seconds, so a topic is sent to at
 * most once in this time.
 */
export const portfolioUpdateCooldownMs = 6 * 60 * 60 * 1000;

/**
 * When each collection last changed, at `portfolio_versions/{locale}`, so the
 * app can refresh only the collections it cached before that.
 */
export const portfolioVersionsCollection = 'portfolio_versions';

/** Tells the app what a tapped notification is about. */
export const portfolioUpdateKind = 'portfolio_update';

const texts: Record<string, [string, string]> = {
  en: ['Portfolio updated', "Take a look at what's new."],
  es: ['Portfolio actualizado', 'Echa un vistazo a las novedades.'],
  nl: ['Portfolio bijgewerkt', 'Bekijk wat er nieuw is.'],
};

/** The topic the app subscribes to for updates in [locale], such as `es`. */
export function portfolioUpdateTopic(locale: string): string {
  return `portfolio_updates_${locale}`;
}

/** The notification for [locale], English otherwise. */
export function portfolioUpdateNotification(locale: string): PushNotification {
  const [title, body] = texts[locale] ?? texts.en;
  return {
    title,
    body,
    data: { kind: portfolioUpdateKind },
    group: portfolioUpdateKind,
  };
}

export interface PortfolioUpdateNotifier {
  /** Records that [collection] of [locale] changed at [now]. */
  recordChange(locale: string, collection: string, now: Date): Promise<void>;
  /**
   * Records a send to [topic] at [now] and returns true, or returns false
   * when the last send was less than [cooldownMs] before [now].
   */
  claimSend(topic: string, now: Date, cooldownMs: number): Promise<boolean>;
  sender: PushSender;
}

export type PortfolioUpdateOutcome =
  'sent' | 'unchanged' | 'deleted' | 'unknown_locale' | 'cooling_down';

/**
 * Records that [collection] of [locale] changed and notifies the topic of
 * [locale], unless the document was deleted or its content is the same as
 * [before]. The change is recorded every time, but the topic is not sent to
 * again within [portfolioUpdateCooldownMs].
 */
export async function notifyPortfolioUpdate(
  { recordChange, claimSend, sender }: PortfolioUpdateNotifier,
  {
    collection,
    locale,
    before,
    after,
    now,
  }: {
    collection: string;
    locale: string;
    before: unknown;
    after: unknown;
    now: Date;
  },
): Promise<PortfolioUpdateOutcome> {
  if (after === undefined) return 'deleted';
  if (isDeepStrictEqual(before, after)) return 'unchanged';
  // Topic names allow only some characters; locales are two letters.
  if (!/^[a-z]{2}$/.test(locale)) return 'unknown_locale';
  await recordChange(locale, collection, now);
  const topic = portfolioUpdateTopic(locale);
  if (!(await claimSend(topic, now, portfolioUpdateCooldownMs))) {
    return 'cooling_down';
  }
  await sender.sendToTopic(topic, portfolioUpdateNotification(locale));
  return 'sent';
}
