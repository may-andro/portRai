import { describe, expect, it, vi } from 'vitest';

import { createFetchJson } from '../../src/shared/fetch_json.js';

const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status });

describe('createFetchJson', () => {
  it('should return the parsed body when the request succeeds', async () => {
    const fetchFunction = vi.fn().mockResolvedValue(jsonResponse({ ok: 1 }));
    const fetchJson = createFetchJson({ fetchFunction, retryDelayMs: 0 });

    expect(await fetchJson('https://example.com/api')).toEqual({ ok: 1 });
    expect(fetchFunction).toHaveBeenCalledTimes(1);
  });

  it('should try once more when the connection fails', async () => {
    const fetchFunction = vi
      .fn()
      .mockRejectedValueOnce(new TypeError('fetch failed'))
      .mockResolvedValue(jsonResponse({ ok: 1 }));
    const fetchJson = createFetchJson({ fetchFunction, retryDelayMs: 0 });

    expect(await fetchJson('https://example.com/api')).toEqual({ ok: 1 });
    expect(fetchFunction).toHaveBeenCalledTimes(2);
  });

  for (const status of [429, 503]) {
    it(`should try once more when the server answers ${status}`, async () => {
      const fetchFunction = vi
        .fn()
        .mockResolvedValueOnce(jsonResponse({}, status))
        .mockResolvedValue(jsonResponse({ ok: 1 }));
      const fetchJson = createFetchJson({ fetchFunction, retryDelayMs: 0 });

      expect(await fetchJson('https://example.com/api')).toEqual({ ok: 1 });
      expect(fetchFunction).toHaveBeenCalledTimes(2);
    });
  }

  it('should not retry and should throw when the server answers 404', async () => {
    const fetchFunction = vi.fn().mockResolvedValue(jsonResponse({}, 404));
    const fetchJson = createFetchJson({ fetchFunction, retryDelayMs: 0 });

    await expect(fetchJson('https://example.com/api')).rejects.toThrow(
      'GET https://example.com/api failed with HTTP 404',
    );
    expect(fetchFunction).toHaveBeenCalledTimes(1);
  });

  it('should throw when the retry fails too', async () => {
    const fetchFunction = vi
      .fn()
      .mockRejectedValue(new TypeError('fetch failed'));
    const fetchJson = createFetchJson({ fetchFunction, retryDelayMs: 0 });

    await expect(fetchJson('https://example.com/api')).rejects.toThrow(
      'fetch failed',
    );
    expect(fetchFunction).toHaveBeenCalledTimes(2);
  });
});
