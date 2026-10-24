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
 * Notifies the topic of [locale] that the portfolio changed, unless the
 * document was deleted, its content is the same as [before], or the topic
 * was sent to within [portfolioUpdateCooldownMs].
 */
export async function notifyPortfolioUpdate(
  { claimSend, sender }: PortfolioUpdateNotifier,
  {
    locale,
    before,
    after,
    now,
  }: { locale: string; before: unknown; after: unknown; now: Date },
): Promise<PortfolioUpdateOutcome> {
  if (after === undefined) return 'deleted';
  if (isDeepStrictEqual(before, after)) return 'unchanged';
  // Topic names allow only some characters; locales are two letters.
  if (!/^[a-z]{2}$/.test(locale)) return 'unknown_locale';
  const topic = portfolioUpdateTopic(locale);
  if (!(await claimSend(topic, now, portfolioUpdateCooldownMs))) {
    return 'cooling_down';
  }
  await sender.sendToTopic(topic, portfolioUpdateNotification(locale));
  return 'sent';
}
