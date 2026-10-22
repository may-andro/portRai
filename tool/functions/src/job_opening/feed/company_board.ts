import { isRecord, stringOrNull } from '../../shared/json_value.js';
import { settleAll } from '../../shared/settle_all.js';
import { termPattern } from '../match/skill_matcher.js';
import type { ReadDocument } from '../skill/portfolio_skills.js';
import type { JobOpening } from '../job_opening.js';
import { isWantedJob, type JobSearchQuery } from './job_feed.js';

/** The applicant tracking systems whose public job boards are read. */
export type BoardSystem = 'greenhouse' | 'lever' | 'ashby';

/** One company's public job board. */
export interface CompanyBoard {
  system: BoardSystem;
  /** The board's name in its URL, such as `reddit` in `boards.greenhouse.io/reddit`. */
  slug: string;
  /** The company's display name, shown as the opening's source. */
  name: string;
}

/**
 * Where the company list lives. Only the function reads it; the owner edits
 * it in the Firebase console, as `{ boards: [{ system, slug, name }] }`.
 */
export const companyBoardsDocument = {
  collection: 'job_search',
  documentId: 'company_boards',
} as const;

/** Openings kept per company, so one large board cannot crowd the others out. */
export const maxOpeningsPerBoard = 10;

/** Boards read at the same time. */
const boardConcurrency = 4;

/**
 * Remote-friendly companies with mobile engineering roles, used until the
 * company boards document exists.
 */
export const defaultCompanyBoards: CompanyBoard[] = [
  { system: 'greenhouse', slug: 'affirm', name: 'Affirm' },
  { system: 'greenhouse', slug: 'airbnb', name: 'Airbnb' },
  { system: 'greenhouse', slug: 'canonical', name: 'Canonical' },
  { system: 'greenhouse', slug: 'coinbase', name: 'Coinbase' },
  { system: 'greenhouse', slug: 'doctolib', name: 'Doctolib' },
  { system: 'greenhouse', slug: 'duolingo', name: 'Duolingo' },
  { system: 'greenhouse', slug: 'flohealth', name: 'Flo Health' },
  { system: 'greenhouse', slug: 'instacart', name: 'Instacart' },
  { system: 'greenhouse', slug: 'jetbrains', name: 'JetBrains' },
  { system: 'greenhouse', slug: 'lyft', name: 'Lyft' },
  { system: 'greenhouse', slug: 'mozilla', name: 'Mozilla' },
  { system: 'greenhouse', slug: 'peloton', name: 'Peloton' },
  { system: 'greenhouse', slug: 'pinterest', name: 'Pinterest' },
  { system: 'greenhouse', slug: 'reddit', name: 'Reddit' },
  { system: 'greenhouse', slug: 'robinhood', name: 'Robinhood' },
  { system: 'greenhouse', slug: 'stripe', name: 'Stripe' },
  { system: 'greenhouse', slug: 'sumup', name: 'SumUp' },
  { system: 'greenhouse', slug: 'traderepublicbank', name: 'Trade Republic' },
  { system: 'greenhouse', slug: 'twilio', name: 'Twilio' },
  { system: 'greenhouse', slug: 'wikimedia', name: 'Wikimedia Foundation' },
  { system: 'greenhouse', slug: 'wolt', name: 'Wolt' },
  { system: 'lever', slug: 'qonto', name: 'Qonto' },
  { system: 'lever', slug: 'spotify', name: 'Spotify' },
  { system: 'ashby', slug: 'elevenlabs', name: 'ElevenLabs' },
  { system: 'ashby', slug: 'linear', name: 'Linear' },
  { system: 'ashby', slug: 'lovable', name: 'Lovable' },
  { system: 'ashby', slug: 'notion', name: 'Notion' },
  { system: 'ashby', slug: 'openai', name: 'OpenAI' },
  { system: 'ashby', slug: 'perplexity', name: 'Perplexity' },
  { system: 'ashby', slug: 'plane', name: 'Plane' },
  { system: 'ashby', slug: 'ramp', name: 'Ramp' },
  { system: 'ashby', slug: 'sentry', name: 'Sentry' },
];

const boardSystems = new Set<string>(['greenhouse', 'lever', 'ashby']);

/**
 * Reads the company list. A missing document or one without a `boards` list
 * gives [defaultCompanyBoards]; an empty list turns the company boards off.
 * Entries with an unknown system or a missing slug are skipped.
 */
export async function loadCompanyBoards(
  readDocument: ReadDocument,
): Promise<CompanyBoard[]> {
  const document = await readDocument(
    companyBoardsDocument.collection,
    companyBoardsDocument.documentId,
  );
  if (!isRecord(document) || !Array.isArray(document.boards)) {
    return defaultCompanyBoards;
  }
  return document.boards.flatMap((entry): CompanyBoard[] => {
    if (!isRecord(entry)) return [];
    const system = stringOrNull(entry.system);
    const slug = stringOrNull(entry.slug)?.trim();
    if (!system || !boardSystems.has(system) || !slug) return [];
    return [
      {
        system: system as BoardSystem,
        slug,
        name: stringOrNull(entry.name)?.trim() || slug,
      },
    ];
  });
}

/**
 * Reads the company list once, on the first call, and gives each caller the
 * boards of one system, so the feeds of several systems share one read.
 */
export function companyBoardsLoader(
  readDocument: ReadDocument,
): (system: BoardSystem) => Promise<CompanyBoard[]> {
  let boards: Promise<CompanyBoard[]> | undefined;
  return async (system) => {
    boards ??= loadCompanyBoards(readDocument);
    return (await boards).filter((board) => board.system === system);
  };
}

/** A posting as read from a board, before it is kept or dropped. */
export interface BoardPosting {
  title: string;
  location: string | null;
  isRemote: boolean;
  /** Null when the board gives no valid date; such a posting is dropped. */
  publishedAt: Date | null;
  toJobOpening(): Promise<JobOpening | null>;
}

export type BoardErrorHandler = (board: CompanyBoard, error: unknown) => void;

/**
 * Reads [boards] a few at a time and keeps each board's remote postings whose
 * title names a search term and that [isWantedJob] keeps for [query], up to
 * [maxOpeningsPerBoard] per board. Only the postings kept are turned into
 * openings. Boards often post one job once per location, so postings with
 * the same title become one opening listing every location. A board that
 * fails is reported to [onBoardError] and skipped; the feed fails only when
 * every board fails.
 */
export async function fetchCompanyBoards(
  boards: CompanyBoard[],
  query: JobSearchQuery,
  listPostings: (board: CompanyBoard) => Promise<BoardPosting[]>,
  onBoardError: BoardErrorHandler = () => {},
): Promise<JobOpening[]> {
  const patterns = query.terms.map((term) => termPattern(term));
  const results = await settleAll(boards, boardConcurrency, async (board) => {
    const postingsByTitle = new Map<string, BoardPosting[]>();
    for (const posting of await listPostings(board)) {
      const title = posting.title.toLowerCase();
      if (
        !posting.isRemote ||
        !patterns.some((pattern) => pattern.test(title)) ||
        posting.publishedAt === null ||
        !isWantedJob(query, { ...posting, publishedAt: posting.publishedAt })
      ) {
        continue;
      }
      const key = title.replace(/\s+/g, ' ').trim();
      postingsByTitle.set(key, [...(postingsByTitle.get(key) ?? []), posting]);
    }
    const boardOpenings = await Promise.all(
      [...postingsByTitle.values()]
        .slice(0, maxOpeningsPerBoard)
        .map(async (postings) => {
          const opening = await postings[0].toJobOpening();
          const locations = [
            ...new Set(
              postings.flatMap((posting) =>
                posting.location ? [posting.location] : [],
              ),
            ),
          ];
          return opening && locations.length > 1
            ? { ...opening, location: locations.join(' · ') }
            : opening;
        }),
    );
    return boardOpenings.filter(
      (opening): opening is JobOpening => opening !== null,
    );
  });

  const openings: JobOpening[] = [];
  let lastError: unknown;
  results.forEach((result, index) => {
    if (result.status === 'fulfilled') {
      openings.push(...result.value);
    } else {
      lastError = result.reason;
      onBoardError(boards[index], result.reason);
    }
  });
  if (
    boards.length > 0 &&
    results.every((result) => result.status === 'rejected')
  ) {
    throw new Error(`Every company board failed: ${String(lastError)}`);
  }
  return openings;
}

export function parseDate(value: unknown): Date | null {
  if (typeof value === 'number') {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }
  const text = stringOrNull(value);
  if (!text) return null;
  const date = new Date(text);
  return Number.isNaN(date.getTime()) ? null : date;
}
