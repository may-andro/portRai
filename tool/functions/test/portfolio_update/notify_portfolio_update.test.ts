import { describe, expect, it, vi } from 'vitest';

import {
  notifyPortfolioUpdate,
  type PortfolioUpdateNotifier,
  portfolioUpdateCooldownMs,
  portfolioUpdateNotification,
} from '../../src/portfolio_update/notify_portfolio_update.js';

const now = new Date('2026-10-24T10:00:00Z');

function notifier(
  overrides: Partial<PortfolioUpdateNotifier> = {},
): PortfolioUpdateNotifier {
  return {
    recordChange: vi.fn().mockResolvedValue(undefined),
    claimSend: vi.fn().mockResolvedValue(true),
    sender: {
      sendToTokens: vi.fn(),
      sendToTopic: vi.fn().mockResolvedValue(undefined),
    },
    ...overrides,
  };
}

describe('portfolioUpdateNotification', () => {
  it.each([
    ['en', 'Portfolio updated'],
    ['es', 'Portfolio actualizado'],
    ['nl', 'Portfolio bijgewerkt'],
    ['fr', 'Portfolio updated'],
  ])('should title %s as %s', (locale, title) => {
    expect(portfolioUpdateNotification(locale)).toMatchObject({
      title,
      data: { kind: 'portfolio_update' },
      group: 'portfolio_update',
    });
  });
});

describe('notifyPortfolioUpdate', () => {
  it('should send to the topic of the locale when the content changed', async () => {
    const deps = notifier();

    const outcome = await notifyPortfolioUpdate(deps, {
      collection: 'projects',
      locale: 'es',
      before: { title: 'Old' },
      after: { title: 'New' },
      now,
    });

    expect(outcome).toBe('sent');
    expect(deps.recordChange).toHaveBeenCalledWith('es', 'projects', now);
    expect(deps.claimSend).toHaveBeenCalledWith(
      'portfolio_updates_es',
      now,
      portfolioUpdateCooldownMs,
    );
    expect(deps.sender.sendToTopic).toHaveBeenCalledWith(
      'portfolio_updates_es',
      portfolioUpdateNotification('es'),
    );
  });

  it('should send when a locale document is created', async () => {
    const outcome = await notifyPortfolioUpdate(notifier(), {
      collection: 'profile',
      locale: 'nl',
      before: undefined,
      after: { title: 'New' },
      now,
    });

    expect(outcome).toBe('sent');
  });

  it.each([
    ['deleted', { title: 'Old' }, undefined, 'en'],
    ['unchanged', { items: [{ name: 'A' }] }, { items: [{ name: 'A' }] }, 'en'],
    ['unknown_locale', undefined, { title: 'New' }, 'en/US'],
  ])(
    'should send nothing when the change is %s',
    async (expected, before, after, locale) => {
      const deps = notifier();

      const outcome = await notifyPortfolioUpdate(deps, {
        collection: 'profile',
        locale,
        before,
        after,
        now,
      });

      expect(outcome).toBe(expected);
      expect(deps.recordChange).not.toHaveBeenCalled();
      expect(deps.claimSend).not.toHaveBeenCalled();
      expect(deps.sender.sendToTopic).not.toHaveBeenCalled();
    },
  );

  it('should record the change but send nothing when the topic was sent to recently', async () => {
    const deps = notifier({ claimSend: vi.fn().mockResolvedValue(false) });

    const outcome = await notifyPortfolioUpdate(deps, {
      collection: 'services',
      locale: 'en',
      before: { title: 'Old' },
      after: { title: 'New' },
      now,
    });

    expect(outcome).toBe('cooling_down');
    expect(deps.recordChange).toHaveBeenCalledWith('en', 'services', now);
    expect(deps.sender.sendToTopic).not.toHaveBeenCalled();
  });
});
