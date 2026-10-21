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
import { HackerNewsFeed } from './feed/hacker_news_feed.js';
import { HimalayasFeed } from './feed/himalayas_feed.js';
import { JobicyFeed } from './feed/jobicy_feed.js';
import { RemoteOkFeed } from './feed/remoteok_feed.js';
import { RemotiveFeed } from './feed/remotive_feed.js';
import { loadPortfolioProfile } from './profile/portfolio_profile.js';
import { GeminiJobScorer } from './score/job_scorer.js';
import {
  firestoreReadDocument,
  listJobSearchUserIds,
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
    // Feeds, then at most 10 minutes of Gemini scoring, then the writes.
    timeoutSeconds: 900,
    memory: '512MiB',
    retryCount: 0,
  },
  async () => {
    const db = getFirestore();
    const generateJson = createGeminiGenerateJson(projectId());
    const result = await syncJobOpenings({
      // Earlier feeds win when two list the same job; the searchable feeds
      // with the richest data come first.
      feeds: [
        new HimalayasFeed(fetchJson),
        new RemotiveFeed(fetchJson),
        new RemoteOkFeed(fetchJson),
        new JobicyFeed(fetchJson),
        new HackerNewsFeed(fetchJson, new GeminiJobPostExtractor(generateJson)),
        new ArbeitnowFeed(fetchJson),
      ],
      listUserIds: () => listJobSearchUserIds(db),
      loadProfile: () => loadPortfolioProfile(firestoreReadDocument(db)),
      scorer: new GeminiJobScorer(generateJson),
      writeJobOpenings: (userId, openings, now) =>
        writeJobOpenings(db, userId, openings, now),
      now: () => new Date(),
      logger,
    });
    logger.info('Job openings sync finished', result);
  },
);
