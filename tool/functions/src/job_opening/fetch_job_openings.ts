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
import { ArbeitnowFeed } from './feed/arbeitnow_feed.js';
import { RemotiveFeed } from './feed/remotive_feed.js';
import { GeminiJobScorer } from './score/job_scorer.js';
import { loadPortfolioSkills } from './skill/portfolio_skills.js';
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
    // Feeds plus up to 50 Gemini calls, 4 at a time, each with a 30 s deadline.
    timeoutSeconds: 900,
    memory: '512MiB',
    retryCount: 0,
  },
  async () => {
    const db = getFirestore();
    const result = await syncJobOpenings({
      // Remotive comes first, so it keeps a job both feeds list.
      feeds: [new RemotiveFeed(fetchJson), new ArbeitnowFeed(fetchJson)],
      listUserIds: () => listJobSearchUserIds(db),
      loadSkills: () => loadPortfolioSkills(firestoreReadDocument(db)),
      scorer: new GeminiJobScorer(createGeminiGenerateJson(projectId())),
      writeJobOpenings: (userId, openings, now) =>
        writeJobOpenings(db, userId, openings, now),
      now: () => new Date(),
      logger,
    });
    logger.info('Job openings sync finished', result);
  },
);
