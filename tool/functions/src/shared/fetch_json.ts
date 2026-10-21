/** Fetches a URL and returns its parsed JSON body. */
export type FetchJson = (url: string) => Promise<unknown>;

const requestTimeoutMs = 30_000;

/** Statuses worth one more try: rate limits and server errors. */
const isRetryableStatus = (status: number) => status === 429 || status >= 500;

/**
 * A [FetchJson] that tries once more, after [retryDelayMs], when the
 * connection fails or the server answers with a retryable status. A dropped
 * connection to one source should not cost that source's jobs for the week.
 */
export function createFetchJson({
  fetchFunction = fetch,
  retryDelayMs = 2_000,
}: {
  fetchFunction?: typeof fetch;
  retryDelayMs?: number;
} = {}): FetchJson {
  const get = (url: string) =>
    fetchFunction(url, {
      headers: {
        Accept: 'application/json',
        'User-Agent': 'PortRai Cloud Functions',
      },
      signal: AbortSignal.timeout(requestTimeoutMs),
    });

  return async (url) => {
    let response: Response;
    try {
      response = await get(url);
      if (isRetryableStatus(response.status)) {
        await delay(retryDelayMs);
        response = await get(url);
      }
    } catch {
      await delay(retryDelayMs);
      response = await get(url);
    }
    if (!response.ok) {
      throw new Error(`GET ${url} failed with HTTP ${response.status}`);
    }
    return response.json();
  };
}

export const fetchJson: FetchJson = createFetchJson();

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}
