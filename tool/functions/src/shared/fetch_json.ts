/** Fetches a URL and returns its parsed JSON body. */
export type FetchJson = (url: string) => Promise<unknown>;

const requestTimeoutMs = 30_000;

export const fetchJson: FetchJson = async (url) => {
  const response = await fetch(url, {
    headers: {
      Accept: 'application/json',
      'User-Agent': 'PortRai Cloud Functions',
    },
    signal: AbortSignal.timeout(requestTimeoutMs),
  });
  if (!response.ok) {
    throw new Error(`GET ${url} failed with HTTP ${response.status}`);
  }
  return response.json();
};
