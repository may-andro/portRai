import { describe, expect, it } from 'vitest';

import { settleAll } from '../../src/shared/settle_all.js';

describe('settleAll', () => {
  it('should return every outcome in input order when some tasks fail', async () => {
    const results = await settleAll([1, 2, 3], 2, async (n) => {
      if (n === 2) throw new Error('two');
      return n * 10;
    });

    expect(results).toEqual([
      { status: 'fulfilled', value: 10 },
      { status: 'rejected', reason: new Error('two') },
      { status: 'fulfilled', value: 30 },
    ]);
  });

  it('should run at most the given number of tasks at once', async () => {
    let running = 0;
    let peak = 0;
    await settleAll([1, 2, 3, 4, 5], 2, async () => {
      running++;
      peak = Math.max(peak, running);
      await new Promise((resolve) => setTimeout(resolve, 5));
      running--;
    });

    expect(peak).toBe(2);
  });

  it('should return an empty list when there are no items', async () => {
    expect(await settleAll([], 4, async () => 1)).toEqual([]);
  });
});
