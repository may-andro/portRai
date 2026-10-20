import { createHash } from 'node:crypto';

import type { JobOpening } from '../job_opening.js';

/**
 * A key for the same job across feeds and weeks: the company and title,
 * normalized, hashed into a value that is safe as a Firestore document id.
 */
export function dedupeKey(
  opening: Pick<JobOpening, 'company' | 'title'>,
): string {
  const normalized = `${normalize(opening.company)}|${normalize(opening.title)}`;
  return createHash('sha256').update(normalized).digest('hex').slice(0, 32);
}

/** Keeps the first opening for each key, so earlier feeds win. */
export function dedupeJobOpenings<T extends JobOpening>(
  openings: T[],
): Array<T & { dedupeKey: string }> {
  const byKey = new Map<string, T & { dedupeKey: string }>();
  for (const opening of openings) {
    const key = dedupeKey(opening);
    if (!byKey.has(key)) byKey.set(key, { ...opening, dedupeKey: key });
  }
  return [...byKey.values()];
}

function normalize(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/\((m|w|f|d|x|all genders?)(\s*\/\s*(m|w|f|d|x))*\)/g, ' ')
    .replace(/[^a-z0-9+#]+/g, ' ')
    .trim();
}
