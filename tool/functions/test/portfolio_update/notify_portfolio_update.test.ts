import { describe, expect, it, vi } from 'vitest';

import {
  notifyPortfolioUpdates,
  type PortfolioChangeRecorder,
  type PortfolioUpdateNotifier,
  portfolioUpdateNotification,
  portfolioUpdateQuietMs,
  recordPortfolioChange,
} from '../../src/portfolio_update/notify_portfolio_update.js';

const now = new Date('2026-10-24T10:00:00Z');

function recorder(): PortfolioChangeRecorder {
  return { recordChange: vi.fn().mockResolvedValue(undefined) };
}

function notifier(
  overrides: Partial<PortfolioUpdateNotifier> = {},
): PortfolioUpdateNotifier {
  return {
    claimQuietBatches: vi.fn().mockResolvedValue([]),
    sender: {
      sendToTokens: vi.fn(),
      sendToTopic: vi.fn().mockResolvedValue(undefined),
    },
    ...overrides,
  };
}

describe('portfolioUpdateNotification', () => {
  it.each([
    ['en', 'Portfolio updated', 'Updated: Projects.'],
    ['es', 'Portfolio actualizado', 'Actualizado: Proyectos.'],
    ['nl', 'Portfolio bijgewerkt', 'Bijgewerkt: Projecten.'],
    ['fr', 'Portfolio updated', 'Updated: Projects.'],
  ])('should name one section in %s', (locale, title, body) => {
    expect(portfolioUpdateNotification(locale, ['projects'])).toEqual({
      title,
      body,
      data: { kind: 'portfolio_update', sections: 'projects' },
      group: 'portfolio_update',
    });
  });

  it.each([
    ['en', 'Updated: About Me, Projects, and Services.'],
    ['es', 'Actualizado: Sobre Mí, Proyectos y Servicios.'],
    ['nl', 'Bijgewerkt: Over Mij, Projecten en Diensten.'],
  ])('should list several sections in %s', (locale, body) => {
    const notification = portfolioUpdateNotification(locale, [
      'profile',
      'projects',
      'services',
    ]);

    expect(notification.body).toBe(body);
    expect(notification.data.sections).toBe('profile,projects,services');
  });
});

describe('recordPortfolioChange', () => {
  it('should record the change when the content changed', async () => {
    const deps = recorder();

    const outcome = await recordPortfolioChange(deps, {
      collection: 'projects',
      locale: 'es',
      before: { title: 'Old' },
      after: { title: 'New' },
      now,
    });

    expect(outcome).toBe('recorded');
    expect(deps.recordChange).toHaveBeenCalledWith('es', 'projects', now);
  });

  it('should record the change when a locale document is created', async () => {
    const outcome = await recordPortfolioChange(recorder(), {
      collection: 'profile',
      locale: 'nl',
      before: undefined,
      after: { title: 'New' },
      now,
    });

    expect(outcome).toBe('recorded');
  });

  it.each([
    ['deleted', { title: 'Old' }, undefined, 'en'],
    ['unchanged', { items: [{ name: 'A' }] }, { items: [{ name: 'A' }] }, 'en'],
    ['unknown_locale', undefined, { title: 'New' }, 'en/US'],
  ])(
    'should record nothing when the change is %s',
    async (expected, before, after, locale) => {
      const deps = recorder();

      const outcome = await recordPortfolioChange(deps, {
        collection: 'profile',
        locale,
        before,
        after,
        now,
      });

      expect(outcome).toBe(expected);
      expect(deps.recordChange).not.toHaveBeenCalled();
    },
  );
});

describe('notifyPortfolioUpdates', () => {
  it('should claim the batches that have been quiet long enough', async () => {
    const deps = notifier();

    await notifyPortfolioUpdates(deps, now);

    expect(deps.claimQuietBatches).toHaveBeenCalledWith(
      new Date(now.getTime() - portfolioUpdateQuietMs),
    );
  });

  it('should send one notification to each locale naming its sections in order', async () => {
    const deps = notifier({
      claimQuietBatches: vi.fn().mockResolvedValue([
        { locale: 'en', collections: ['services', 'profile'] },
        { locale: 'es', collections: ['projects'] },
      ]),
    });

    const sends = await notifyPortfolioUpdates(deps, now);

    expect(sends).toEqual([
      { locale: 'en', collections: ['profile', 'services'] },
      { locale: 'es', collections: ['projects'] },
    ]);
    expect(deps.sender.sendToTopic).toHaveBeenCalledWith(
      'portfolio_updates_en',
      portfolioUpdateNotification('en', ['profile', 'services']),
    );
    expect(deps.sender.sendToTopic).toHaveBeenCalledWith(
      'portfolio_updates_es',
      portfolioUpdateNotification('es', ['projects']),
    );
  });

  it('should leave out unknown sections and send nothing when none is known', async () => {
    const deps = notifier({
      claimQuietBatches: vi.fn().mockResolvedValue([
        { locale: 'en', collections: ['projects', 'blog'] },
        { locale: 'nl', collections: ['blog'] },
      ]),
    });

    const sends = await notifyPortfolioUpdates(deps, now);

    expect(sends).toEqual([{ locale: 'en', collections: ['projects'] }]);
    expect(deps.sender.sendToTopic).toHaveBeenCalledTimes(1);
  });

  it('should keep sending to the other locales when one send fails', async () => {
    const error = new Error('unavailable');
    const deps = notifier({
      claimQuietBatches: vi.fn().mockResolvedValue([
        { locale: 'en', collections: ['projects'] },
        { locale: 'nl', collections: ['services'] },
      ]),
      sender: {
        sendToTokens: vi.fn(),
        sendToTopic: vi
          .fn()
          .mockRejectedValueOnce(error)
          .mockResolvedValue(undefined),
      },
    });

    const sends = await notifyPortfolioUpdates(deps, now);

    expect(sends).toEqual([
      { locale: 'en', collections: ['projects'], error },
      { locale: 'nl', collections: ['services'] },
    ]);
  });
});
