import { getFirestore } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import { fetchJson } from '../shared/fetch_json.js';
import { functionRegion } from '../shared/function_options.js';
import { ArbeitnowFeed } from './feed/arbeitnow_feed.js';
import { RemotiveFeed } from './feed/remotive_feed.js';
import { loadPortfolioSkills } from './skill/portfolio_skills.js';
import {
  firestoreReadCollection,
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
    timeoutSeconds: 540,
    memory: '512MiB',
    retryCount: 0,
  },
  async () => {
    const db = getFirestore();
    const result = await syncJobOpenings({
      // Remotive comes first, so it keeps a job both feeds list.
      feeds: [new RemotiveFeed(fetchJson), new ArbeitnowFeed(fetchJson)],
      listUserIds: () => listJobSearchUserIds(db),
      loadSkills: () => loadPortfolioSkills(firestoreReadCollection(db)),
      writeJobOpenings: (userId, openings, now) =>
        writeJobOpenings(db, userId, openings, now),
      now: () => new Date(),
      logger,
    });
    logger.info('Job openings sync finished', result);
  },
);
