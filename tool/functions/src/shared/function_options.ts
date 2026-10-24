/** Region every function deploys to, except Firestore triggers. */
export const functionRegion = 'europe-west3';

/**
 * Region Firestore triggers deploy to. A trigger must run in the region of
 * the Cloud Firestore database, which is `us-central1`.
 */
export const firestoreTriggerRegion = 'us-central1';

/**
 * The project the code is deployed to or runs in. The Firebase CLI sets it
 * while reading the functions at deploy time, and Cloud Functions at runtime.
 */
export function projectId(): string {
  const id = process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT;
  if (!id) throw new Error('The Google Cloud project is not set');
  return id;
}

/**
 * The full email of a service account in this project. Cloud Functions and
 * Cloud Scheduler need the full email, and building it keeps the project ID
 * out of the code.
 */
export function serviceAccountEmail(name: string): string {
  return `${name}@${projectId()}.iam.gserviceaccount.com`;
}
