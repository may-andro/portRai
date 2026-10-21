import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['test/**/*.test.ts'],
    // Every test file shares one emulator, so they run one at a time.
    fileParallelism: false,
  },
});
