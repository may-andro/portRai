import { readFileSync } from 'node:fs';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  Timestamp,
} from 'firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

const portfolioCollections = [
  'profile',
  'experiences',
  'expertise',
  'projects',
  'services',
  'testimonials',
  'app_config',
];

let environment: RulesTestEnvironment;

beforeAll(async () => {
  environment = await initializeTestEnvironment({
    projectId: 'demo-portrai',
    firestore: { rules: readFileSync('firestore.rules', 'utf8') },
  });
});

afterAll(() => environment.cleanup());

beforeEach(async () => {
  await environment.clearFirestore();
  await environment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    for (const name of portfolioCollections) {
      await setDoc(doc(db, name, 'en'), { title: 'Portfolio' });
    }
    await setDoc(doc(db, 'users/owner'), {
      jobSearch: { enabled: true, updatedAt: Timestamp.now() },
      plan: 'server-only',
    });
    await setDoc(doc(db, 'users/owner/job_openings/job-1'), { score: 82 });
    await setDoc(doc(db, 'other/document'), { value: 1 });
  });
});

const owner = () => environment.authenticatedContext('owner').firestore();
const stranger = () => environment.authenticatedContext('stranger').firestore();
const guest = () => environment.unauthenticatedContext().firestore();

describe('portfolio content', () => {
  for (const name of portfolioCollections) {
    it(`should let anyone read ${name} documents`, async () => {
      await assertSucceeds(getDoc(doc(guest(), name, 'en')));
    });

    it(`should not let a signed-in user write ${name} documents`, async () => {
      await assertFails(setDoc(doc(owner(), name, 'en'), { title: 'Changed' }));
      await assertFails(deleteDoc(doc(owner(), name, 'en')));
    });
  }

  it('should not let anyone list a portfolio collection', async () => {
    await assertFails(getDocs(collection(guest(), 'projects')));
  });
});

describe('users/{userId}', () => {
  it('should let the user read their own document', async () => {
    await assertSucceeds(getDoc(doc(owner(), 'users/owner')));
  });

  it("should not let anyone read another user's document", async () => {
    await assertFails(getDoc(doc(stranger(), 'users/owner')));
    await assertFails(getDoc(doc(guest(), 'users/owner')));
  });

  it('should let the user change job search with the server time', async () => {
    await assertSucceeds(
      setDoc(
        doc(owner(), 'users/owner'),
        { jobSearch: { enabled: false, updatedAt: serverTimestamp() } },
        { merge: true },
      ),
    );
  });

  it('should let a new user create their document with job search only', async () => {
    await assertSucceeds(
      setDoc(
        doc(stranger(), 'users/stranger'),
        { jobSearch: { enabled: true, updatedAt: serverTimestamp() } },
        { merge: true },
      ),
    );
  });

  it('should not accept a client-chosen time for updatedAt', async () => {
    await assertFails(
      setDoc(
        doc(owner(), 'users/owner'),
        {
          jobSearch: {
            enabled: true,
            updatedAt: Timestamp.fromDate(new Date('2020-01-01')),
          },
        },
        { merge: true },
      ),
    );
  });

  it('should not accept job search fields beyond enabled and updatedAt', async () => {
    await assertFails(
      setDoc(
        doc(owner(), 'users/owner'),
        {
          jobSearch: {
            enabled: true,
            updatedAt: serverTimestamp(),
            minScore: 0,
          },
        },
        { merge: true },
      ),
    );
  });

  it('should not accept an enabled value that is not a boolean', async () => {
    await assertFails(
      setDoc(
        doc(owner(), 'users/owner'),
        { jobSearch: { enabled: 'yes', updatedAt: serverTimestamp() } },
        { merge: true },
      ),
    );
  });

  it('should not let the user change fields outside job search', async () => {
    await assertFails(
      setDoc(doc(owner(), 'users/owner'), { plan: 'free' }, { merge: true }),
    );
  });

  it("should not let anyone write another user's document", async () => {
    await assertFails(
      setDoc(
        doc(stranger(), 'users/owner'),
        { jobSearch: { enabled: false, updatedAt: serverTimestamp() } },
        { merge: true },
      ),
    );
  });

  it('should not let the user delete their document', async () => {
    await assertFails(deleteDoc(doc(owner(), 'users/owner')));
  });
});

describe('users/{userId}/job_openings', () => {
  it('should let the user list and read their own openings', async () => {
    await assertSucceeds(
      getDocs(collection(owner(), 'users/owner/job_openings')),
    );
    await assertSucceeds(
      getDoc(doc(owner(), 'users/owner/job_openings/job-1')),
    );
  });

  it("should not let anyone read another user's openings", async () => {
    await assertFails(
      getDocs(collection(stranger(), 'users/owner/job_openings')),
    );
    await assertFails(getDoc(doc(guest(), 'users/owner/job_openings/job-1')));
  });

  it('should not let the user write their openings', async () => {
    await assertFails(
      setDoc(doc(owner(), 'users/owner/job_openings/job-1'), { score: 100 }),
    );
    await assertFails(
      deleteDoc(doc(owner(), 'users/owner/job_openings/job-1')),
    );
  });
});

describe('everything else', () => {
  it('should deny reads and writes to other collections', async () => {
    await assertFails(getDoc(doc(owner(), 'other/document')));
    await assertFails(setDoc(doc(owner(), 'other/document'), { value: 2 }));
  });
});
