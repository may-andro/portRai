import { afterEach, describe, expect, it, vi } from 'vitest';

import {
  projectId,
  serviceAccountEmail,
} from '../../src/shared/function_options.js';

describe('projectId', () => {
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it('should read GCLOUD_PROJECT when it is set', () => {
    vi.stubEnv('GCLOUD_PROJECT', 'demo-project');
    vi.stubEnv('GOOGLE_CLOUD_PROJECT', 'other-project');

    expect(projectId()).toBe('demo-project');
  });

  it('should fall back to GOOGLE_CLOUD_PROJECT when GCLOUD_PROJECT is unset', () => {
    vi.stubEnv('GCLOUD_PROJECT', undefined);
    vi.stubEnv('GOOGLE_CLOUD_PROJECT', 'other-project');

    expect(projectId()).toBe('other-project');
  });

  it('should throw when no project is set', () => {
    vi.stubEnv('GCLOUD_PROJECT', undefined);
    vi.stubEnv('GOOGLE_CLOUD_PROJECT', undefined);

    expect(() => projectId()).toThrow('The Google Cloud project is not set');
  });
});

describe('serviceAccountEmail', () => {
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it('should build the email in the current project', () => {
    vi.stubEnv('GCLOUD_PROJECT', 'demo-project');

    expect(serviceAccountEmail('job-openings')).toBe(
      'job-openings@demo-project.iam.gserviceaccount.com',
    );
  });
});
