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

export type PortfolioCollection = (typeof portfolioCollections)[number];

/**
 * When each collection last changed, at `portfolio_versions/{locale}`, so the
 * app can refresh only the collections it cached before that.
 */
export const portfolioVersionsCollection = 'portfolio_versions';

/**
 * The collections changed since the last notification, at
 * `portfolio_update_batches/{locale}`.
 */
export const portfolioUpdateBatchesCollection = 'portfolio_update_batches';

/**
 * A batch is sent once no change was added to it for this long, so one import
 * that writes many documents gives one notification.
 */
export const portfolioUpdateQuietMs = 2 * 60 * 1000;

/** Tells the app what a tapped notification is about. */
export const portfolioUpdateKind = 'portfolio_update';

interface LocaleTexts {
  title: string;
  /** The body before the list of changed sections. */
  updated: string;
  /** Each collection as the app names its section. */
  sections: Record<PortfolioCollection, string>;
}

const texts: Record<string, LocaleTexts> = {
  en: {
    title: 'Portfolio updated',
    updated: 'Updated',
    sections: {
      profile: 'About Me',
      experiences: 'Experience',
      expertise: 'Expertises',
      projects: 'Projects',
      services: 'Services',
      testimonials: 'Testimonials',
    },
  },
  es: {
    title: 'Portfolio actualizado',
    updated: 'Actualizado',
    sections: {
      profile: 'Sobre Mí',
      experiences: 'Experiencia',
      expertise: 'Experiencia Técnica',
      projects: 'Proyectos',
      services: 'Servicios',
      testimonials: 'Testimonios',
    },
  },
  nl: {
    title: 'Portfolio bijgewerkt',
    updated: 'Bijgewerkt',
    sections: {
      profile: 'Over Mij',
      experiences: 'Ervaring',
      expertise: 'Expertise',
      projects: 'Projecten',
      services: 'Diensten',
      testimonials: 'Testimonials',
    },
  },
};

/** The topic the app subscribes to for updates in [locale], such as `es`. */
export function portfolioUpdateTopic(locale: string): string {
  return `portfolio_updates_${locale}`;
}

/**
 * The notification naming [collections] for [locale], English otherwise,
 * such as "Updated: Projects and Services."
 */
export function portfolioUpdateNotification(
  locale: string,
  collections: readonly PortfolioCollection[],
): PushNotification {
  const language = locale in texts ? locale : 'en';
  const { title, updated, sections } = texts[language];
  const names = new Intl.ListFormat(language, { type: 'conjunction' }).format(
    collections.map((collection) => sections[collection]),
  );
  return {
    title,
    body: `${updated}: ${names}.`,
    data: { kind: portfolioUpdateKind, sections: collections.join(',') },
    group: portfolioUpdateKind,
  };
}

export interface PortfolioChangeRecorder {
  /**
   * Records that [collection] of [locale] changed at [now], in its version
   * and in the batch of [locale].
   */
  recordChange(
    locale: string,
    collection: PortfolioCollection,
    now: Date,
  ): Promise<void>;
}

export type PortfolioChangeOutcome =
  'recorded' | 'unchanged' | 'deleted' | 'unknown_locale';

/**
 * Records that [collection] of [locale] changed, unless the document was
 * deleted or its content is the same as [before].
 */
export async function recordPortfolioChange(
  { recordChange }: PortfolioChangeRecorder,
  {
    collection,
    locale,
    before,
    after,
    now,
  }: {
    collection: PortfolioCollection;
    locale: string;
    before: unknown;
    after: unknown;
    now: Date;
  },
): Promise<PortfolioChangeOutcome> {
  if (after === undefined) return 'deleted';
  if (isDeepStrictEqual(before, after)) return 'unchanged';
  // Topic names allow only some characters; locales are two letters.
  if (!/^[a-z]{2}$/.test(locale)) return 'unknown_locale';
  await recordChange(locale, collection, now);
  return 'recorded';
}

/** The collections of one locale changed since its last notification. */
export interface PortfolioUpdateBatch {
  locale: string;
  collections: readonly string[];
}

export interface PortfolioUpdateNotifier {
  /**
   * Removes and returns the batches with no change after [changedBefore], so
   * a batch is sent once.
   */
  claimQuietBatches(changedBefore: Date): Promise<PortfolioUpdateBatch[]>;
  sender: PushSender;
}

export interface PortfolioUpdateSend {
  locale: string;
  collections: PortfolioCollection[];
  error?: unknown;
}

/**
 * Sends one notification to the topic of each locale whose batch has been
 * quiet for [portfolioUpdateQuietMs] at [now], naming its collections. A
 * failed send does not stop the others and is not retried.
 */
export async function notifyPortfolioUpdates(
  { claimQuietBatches, sender }: PortfolioUpdateNotifier,
  now: Date,
): Promise<PortfolioUpdateSend[]> {
  const batches = await claimQuietBatches(
    new Date(now.getTime() - portfolioUpdateQuietMs),
  );
  const sends: PortfolioUpdateSend[] = [];
  for (const { locale, collections } of batches) {
    // In the app's order, without names this code does not know.
    const known = portfolioCollections.filter((collection) =>
      collections.includes(collection),
    );
    if (known.length === 0) continue;
    try {
      await sender.sendToTopic(
        portfolioUpdateTopic(locale),
        portfolioUpdateNotification(locale, known),
      );
      sends.push({ locale, collections: known });
    } catch (error) {
      sends.push({ locale, collections: known, error });
    }
  }
  return sends;
}
