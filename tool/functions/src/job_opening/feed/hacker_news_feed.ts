import type { FetchJson } from '../../shared/fetch_json.js';
import { isRecord, stringOrNull } from '../../shared/json_value.js';
import { settleAll } from '../../shared/settle_all.js';
import type { JobPostExtractor } from '../extract/job_post_extractor.js';
import type { JobOpening } from '../job_opening.js';
import { termPattern } from '../match/skill_matcher.js';
import { htmlToText } from './html_text.js';
import type { JobFeed, JobSearchQuery } from './job_feed.js';

const threadTitlePrefix = 'ask hn: who is hiring?';
const remotePattern = /\bremote\b/i;

interface HackerNewsPost {
  id: string;
  text: string;
  postedAt: Date;
}

/**
 * Remote roles from the monthly Hacker News "Who is hiring?" threads.
 *
 * Posts there are free text, so only top-level posts published on or after
 * the query's `publishedAfter` that mention a search term and remote work are
 * read, and a [JobPostExtractor] lists their roles.
 * Every opening links to its post on Hacker News, which names Hacker News as
 * the source and holds the company's own application details; links inside
 * the text are never followed or stored.
 */
export class HackerNewsFeed implements JobFeed {
  static readonly threadsUrl =
    'https://hn.algolia.com/api/v1/search_by_date?tags=story,author_whoishiring&hitsPerPage=10';

  static itemUrl(id: string): string {
    return `https://hn.algolia.com/api/v1/items/${id}`;
  }

  static postUrl(id: string): string {
    return `https://news.ycombinator.com/item?id=${id}`;
  }

  readonly source = 'hackernews' as const;

  constructor(
    private readonly fetchJson: FetchJson,
    private readonly extractor: JobPostExtractor,
    private readonly options = { maxThreads: 2, maxPosts: 40, concurrency: 2 },
  ) {}

  async fetchJobs(query: JobSearchQuery): Promise<JobOpening[]> {
    if (query.terms.length === 0) return [];

    const termPatterns = query.terms.map((term) => termPattern(term));
    const posts = (await this.readPosts(query.publishedAfter))
      .filter((post) => isRelevant(post.text, termPatterns))
      .sort(
        (first, second) => second.postedAt.getTime() - first.postedAt.getTime(),
      )
      .slice(0, this.options.maxPosts);

    const results = await settleAll(posts, this.options.concurrency, (post) =>
      this.extractor.extractRoles(post.text, query.terms),
    );
    if (
      posts.length > 0 &&
      results.every((result) => result.status === 'rejected')
    ) {
      throw new Error(
        `Reading every Hacker News post failed (${posts.length})`,
      );
    }

    return results.flatMap((result, postIndex) => {
      if (result.status === 'rejected') return [];
      const post = posts[postIndex];
      return result.value
        .filter((role) => role.isRemote)
        .map((role, roleIndex): JobOpening => ({
          source: 'hackernews',
          sourceName: 'Hacker News',
          sourceId: `${post.id}-${roleIndex}`,
          title: role.title,
          company: role.company,
          url: HackerNewsFeed.postUrl(post.id),
          location: role.location,
          tags: [],
          jobTypes: [],
          description: post.text,
          publishedAt: post.postedAt,
        }));
    });
  }

  /** The top-level posts published on or after [publishedAfter]. */
  private async readPosts(publishedAfter: Date): Promise<HackerNewsPost[]> {
    const search = await this.fetchJson(HackerNewsFeed.threadsUrl);
    if (!isRecord(search) || !Array.isArray(search.hits)) {
      throw new Error('Hacker News search has no hits list');
    }
    const threadIds = search.hits
      .flatMap((hit) => {
        if (!isRecord(hit)) return [];
        const title = stringOrNull(hit.title)?.toLowerCase() ?? '';
        const id = stringOrNull(hit.objectID);
        return id && title.startsWith(threadTitlePrefix) ? [id] : [];
      })
      .slice(0, this.options.maxThreads);

    const threads = await Promise.all(
      threadIds.map((threadId) =>
        this.fetchJson(HackerNewsFeed.itemUrl(threadId)),
      ),
    );
    return threads.flatMap((thread, threadIndex) => {
      if (!isRecord(thread) || !Array.isArray(thread.children)) {
        throw new Error(
          `Hacker News thread ${threadIds[threadIndex]} has no posts`,
        );
      }
      return thread.children.flatMap((child) => {
        const post = toPost(child, publishedAfter);
        return post === null ? [] : [post];
      });
    });
  }
}

function toPost(child: unknown, publishedAfter: Date): HackerNewsPost | null {
  if (!isRecord(child)) return null;
  const id =
    typeof child.id === 'number' ? String(child.id) : stringOrNull(child.id);
  const html = stringOrNull(child.text);
  const postedAt = new Date(stringOrNull(child.created_at) ?? '');
  if (!id || !html || Number.isNaN(postedAt.getTime())) return null;
  if (postedAt < publishedAfter) return null;
  // Hacker News starts each paragraph with a bare <p> it never closes.
  const text = htmlToText(html.replace(/<p>/gi, '<br>'));
  return { id, text, postedAt };
}

function isRelevant(text: string, termPatterns: readonly RegExp[]): boolean {
  const lowerText = text.toLowerCase();
  return (
    remotePattern.test(text) &&
    termPatterns.some((pattern) => pattern.test(lowerText))
  );
}
