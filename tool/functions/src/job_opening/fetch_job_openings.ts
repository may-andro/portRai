import { getFirestore } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import { fetchJson } from '../shared/fetch_json.js';
import {
  functionRegion,
  projectId,
  serviceAccountEmail,
} from '../shared/function_options.js';
import { createGeminiGenerateJson } from '../shared/gemini.js';
import { GeminiJobPostExtractor } from './extract/job_post_extractor.js';
import { ArbeitnowFeed } from './feed/arbeitnow_feed.js';
import { AshbyFeed } from './feed/ashby_feed.js';
import {
  type BoardErrorHandler,
  companyBoardsLoader,
} from './feed/company_board.js';
import { GreenhouseFeed } from './feed/greenhouse_feed.js';
import { HackerNewsFeed } from './feed/hacker_news_feed.js';
import { HimalayasFeed } from './feed/himalayas_feed.js';
import { JobicyFeed } from './feed/jobicy_feed.js';
import { LeverFeed } from './feed/lever_feed.js';
import { RemoteOkFeed } from './feed/remoteok_feed.js';
import { RemotiveFeed } from './feed/remotive_feed.js';
import { loadRegions } from './match/region_filter.js';
import { loadPortfolioProfile } from './profile/portfolio_profile.js';
import { GeminiJobScorer } from './score/job_scorer.js';
import {
  firestoreReadDocument,
  listJobSearchUserIds,
  loadJobFits,
  saveJobFits,
  writeJobOpenings,
} from './store/firestore_store.js';
import { syncJobOpenings } from './sync_job_openings.js';

/** Refreshes every job-search user's openings each Monday morning. */
export const fetchJobOpenings = onSchedule(
  {
    schedule: 'every monday 06:00',
    timeZone: 'Europe/Amsterdam',
    region: functionRegion,
    // Only allowed to read and write Firestore and to call Gemini.
    serviceAccount: serviceAccountEmail('job-openings'),
    // Feeds for at most 4 minutes, Gemini scoring until 11 minutes into the
    // run, then the writes.
    timeoutSeconds: 900,
    memory: '512MiB',
    retryCount: 0,
  },
  async () => {
    const db = getFirestore();
    const generateJson = createGeminiGenerateJson(projectId());
    const readDocument = firestoreReadDocument(db);
    // The board feeds read the company list when they start, alongside the
    // other feeds.
    const loadBoards = companyBoardsLoader(readDocument);
    const onBoardError: BoardErrorHandler = (board, error) =>
      logger.warn('A company board failed', {
        system: board.system,
        slug: board.slug,
        error: String(error),
      });
    const result = await syncJobOpenings({
      // Earlier feeds win when two list the same job. The company boards come
      // first, as they link to the employer's own posting; then the
      // searchable feeds with the richest data.
      feeds: [
        new GreenhouseFeed(
          fetchJson,
          () => loadBoards('greenhouse'),
          onBoardError,
        ),
        new LeverFeed(fetchJson, () => loadBoards('lever'), onBoardError),
        new AshbyFeed(fetchJson, () => loadBoards('ashby'), onBoardError),
        new HimalayasFeed(fetchJson),
        new RemotiveFeed(fetchJson),
        new RemoteOkFeed(fetchJson),
        new JobicyFeed(fetchJson),
        new HackerNewsFeed(fetchJson, new GeminiJobPostExtractor(generateJson)),
        new ArbeitnowFeed(fetchJson),
      ],
      listUserIds: () => listJobSearchUserIds(db),
      loadProfile: () => loadPortfolioProfile(readDocument),
      loadRegions: (profile) => loadRegions(readDocument, profile.country),
      scorer: new GeminiJobScorer(generateJson),
      loadJobFits: (fitKeys) => loadJobFits(db, fitKeys),
      saveJobFits: (fits, now) => saveJobFits(db, fits, now),
      writeJobOpenings: (userId, openings, now) =>
        writeJobOpenings(db, userId, openings, now),
      now: () => new Date(),
      logger,
    });
    logger.info('Job openings sync finished', result);
  },
);
