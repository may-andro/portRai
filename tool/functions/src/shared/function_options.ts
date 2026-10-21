/** Region every function deploys to. */
export const functionRegion = 'europe-west3';

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
