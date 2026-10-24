import { isRecord } from '../../shared/json_value.js';
import type { ReadDocument } from '../skill/portfolio_skills.js';

/** Broad regions a remote job can be limited to. */
export type Region =
  | 'europe'
  | 'north_america'
  | 'latin_america'
  | 'asia_pacific'
  | 'middle_east_africa';

const regions = new Set<string>([
  'europe',
  'north_america',
  'latin_america',
  'asia_pacific',
  'middle_east_africa',
]);

/** Where the region preference can be set; it wins over the portfolio country. */
export const jobSearchSettingsDocument = {
  collection: 'job_search',
  documentId: 'settings',
} as const;

/** Locations open to most of the world. */
const worldwidePattern =
  /\b(worldwide|anywhere|global|globally|world ?wide|international)\b/;

/**
 * Wording that limits a worldwide location to some places, such as
 * `Anywhere in the US` or `Worldwide (US time zones)`.
 */
const limitedWorldwidePattern =
  /\b(anywhere|worldwide|global|globally)\s+(in|within|from)\s+(?!the world\b)|\btime ?zones?\b/;

/** Job types that are not employment, such as `Contract` or `freelance`. */
const contractPattern = /contract|freelanc/i;

// A restriction's places follow these words, as in `must be based in the US`.
const followingRestrictionPatterns = [
  /\b(?:must|should|need to|required to)\s+(?:be\s+)?(?:currently\s+)?(?:based|located|living|residing|reside|live)\s+(?:in|within)\s+([^;!?\n]{1,60})/gi,
  /\b(?:authori[sz]ed|eligible|permitted|right)\s+to\s+work\s+(?:in|within|for)\s+([^;!?\n]{1,60})/gi,
  /\bwork\s+(?:authori[sz]ation|permit)\s+(?:in|within|for)\s+([^;!?\n]{1,60})/gi,
  /\b(?:open|available|limited|restricted)\s+(?:only\s+)?to\s+(?:candidates|applicants|residents|people)\s+(?:in|from|within|based in|located in|residing in)\s+([^;!?\n]{1,60})/gi,
  /\b(?:remote|anywhere|candidates|applicants)\s+within\s+([^;!?\n]{1,60})/gi,
];

// A restriction's places come before these words, as in `Remote (US only)`.
const precedingRestrictionPatterns = [
  /([^;:!?\n(]{1,30})\bonly\b(?=\s*(?:[)\].,;:!\n]|$))/gi,
  /\b(?:must|should)\s+(?:be|hold)\s+(?:an?\s+)?([^;!?\n]{1,30}?)\s*citizen/gi,
];

/** Lowercase names that place a location in a region, as whole words. */
const regionNames: Record<Region, string[]> = {
  europe: [
    'europe',
    'european',
    'emea',
    'eu',
    'eea',
    'uk',
    'united kingdom',
    'great britain',
    'england',
    'scotland',
    'wales',
    'ireland',
    'germany',
    'deutschland',
    'france',
    'spain',
    'españa',
    'portugal',
    'italy',
    'netherlands',
    'the netherlands',
    'holland',
    'belgium',
    'luxembourg',
    'switzerland',
    'austria',
    'poland',
    'czechia',
    'czech republic',
    'slovakia',
    'hungary',
    'romania',
    'bulgaria',
    'greece',
    'croatia',
    'slovenia',
    'serbia',
    'denmark',
    'sweden',
    'norway',
    'finland',
    'iceland',
    'estonia',
    'latvia',
    'lithuania',
    'ukraine',
    'cyprus',
    'malta',
    'albania',
    'andorra',
    'bosnia',
    'montenegro',
    'north macedonia',
    'moldova',
    'kosovo',
    'liechtenstein',
    'monaco',
    'san marino',
    'london',
    'berlin',
    'munich',
    'hamburg',
    'paris',
    'madrid',
    'barcelona',
    'lisbon',
    'porto',
    'amsterdam',
    'rotterdam',
    'brussels',
    'dublin',
    'zurich',
    'vienna',
    'warsaw',
    'krakow',
    'prague',
    'budapest',
    'bucharest',
    'athens',
    'copenhagen',
    'stockholm',
    'oslo',
    'helsinki',
    'tallinn',
    'riga',
    'vilnius',
    'milan',
    'rome',
    'cet',
    'cest',
  ],
  north_america: [
    'north america',
    'americas',
    'united states',
    'usa',
    'u.s.',
    'u.s.a.',
    'u.s',
    'canada',
    'alabama',
    'alaska',
    'arizona',
    'arkansas',
    'california',
    'colorado',
    'connecticut',
    'delaware',
    'florida',
    'hawaii',
    'idaho',
    'illinois',
    'indiana',
    'iowa',
    'kansas',
    'kentucky',
    'louisiana',
    'maine',
    'maryland',
    'massachusetts',
    'michigan',
    'minnesota',
    'mississippi',
    'missouri',
    'montana',
    'nebraska',
    'nevada',
    'new hampshire',
    'new jersey',
    'new york',
    'north carolina',
    'north dakota',
    'ohio',
    'oklahoma',
    'oregon',
    'pennsylvania',
    'rhode island',
    'south carolina',
    'south dakota',
    'tennessee',
    'texas',
    'utah',
    'vermont',
    'virginia',
    'washington',
    'west virginia',
    'wisconsin',
    'wyoming',
    'ontario',
    'quebec',
    'british columbia',
    'alberta',
    'nyc',
    'san francisco',
    'bay area',
    'seattle',
    'austin',
    'boston',
    'chicago',
    'los angeles',
    'denver',
    'atlanta',
    'miami',
    'philadelphia',
    'portland',
    'san diego',
    'san jose',
    'palo alto',
    'mountain view',
    'menlo park',
    'silicon valley',
    'dallas',
    'houston',
    'phoenix',
    'minneapolis',
    'detroit',
    'pittsburgh',
    'raleigh',
    'boulder',
    'salt lake city',
    'brooklyn',
    'toronto',
    'vancouver',
    'montreal',
    'ottawa',
    'calgary',
    'est',
    'edt',
    'pst',
    'pdt',
    'mst',
    'eastern time',
    'pacific time',
    'central time',
  ],
  latin_america: [
    'latin america',
    'latam',
    'south america',
    'americas',
    'mexico',
    'brazil',
    'brasil',
    'argentina',
    'chile',
    'colombia',
    'peru',
    'uruguay',
    'costa rica',
    'ecuador',
    'venezuela',
    'bolivia',
    'paraguay',
    'guatemala',
    'panama',
    'dominican republic',
    'são paulo',
    'sao paulo',
    'buenos aires',
    'bogotá',
    'bogota',
    'medellín',
    'medellin',
    'mexico city',
  ],
  asia_pacific: [
    'apac',
    'asia',
    'asia pacific',
    'australia',
    'new zealand',
    'india',
    'singapore',
    'japan',
    'china',
    'hong kong',
    'korea',
    'south korea',
    'philippines',
    'indonesia',
    'vietnam',
    'thailand',
    'malaysia',
    'pakistan',
    'bangladesh',
    'nepal',
    'sri lanka',
    'taiwan',
    'cambodia',
    'sydney',
    'melbourne',
    'bangalore',
    'bengaluru',
    'hyderabad',
    'pune',
    'mumbai',
    'delhi',
    'new delhi',
    'chennai',
    'gurgaon',
    'gurugram',
    'noida',
    'tokyo',
    'seoul',
    'shanghai',
    'beijing',
    'shenzhen',
    'manila',
    'jakarta',
    'kuala lumpur',
    'hanoi',
    'ho chi minh',
    'auckland',
    'brisbane',
  ],
  middle_east_africa: [
    'middle east',
    'africa',
    'emea',
    'israel',
    'tel aviv',
    'uae',
    'united arab emirates',
    'dubai',
    'saudi arabia',
    'egypt',
    'nigeria',
    'kenya',
    'south africa',
    'ghana',
    'morocco',
    'tunisia',
    'ethiopia',
    'uganda',
    'rwanda',
    'tanzania',
    'senegal',
    'turkey',
    'türkiye',
    'istanbul',
    'riyadh',
    'doha',
    'qatar',
    'cairo',
    'lagos',
    'nairobi',
    'cape town',
    'johannesburg',
  ],
};

/** Short codes matched case-sensitively, so `us` in a sentence is ignored. */
const regionCodes: Partial<Record<Region, string[]>> = {
  north_america: ['US', 'USA', 'CA'],
  europe: ['EU', 'UK', 'DE', 'NL', 'ES', 'FR', 'PT', 'IE'],
};

/** A US state code after a city, such as `Boulder, CO`. */
const stateCodePattern =
  /,\s*(AL|AK|AZ|AR|CO|CT|DC|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VT|VA|WA|WV|WI|WY)(?![A-Za-z])/;

const namePatterns = Object.entries(regionNames).map(
  ([region, names]) =>
    [
      region as Region,
      new RegExp(
        `(?<![\\p{L}\\p{N}])(${names.map(escapeRegExp).join('|')})(?![\\p{L}\\p{N}])`,
        'u',
      ),
    ] as const,
);
const codePatterns = Object.entries(regionCodes).map(
  ([region, codes]) =>
    [
      region as Region,
      new RegExp(`(?<![A-Za-z])(${(codes ?? []).join('|')})(?![A-Za-z])`),
    ] as const,
);

/** The regions [location] names; empty when it names none. */
export function regionsOf(location: string): Set<Region> {
  const lowerLocation = location.toLowerCase();
  const found = new Set<Region>();
  for (const [region, pattern] of namePatterns) {
    if (pattern.test(lowerLocation)) found.add(region);
  }
  for (const [region, pattern] of codePatterns) {
    if (pattern.test(location)) found.add(region);
  }
  if (stateCodePattern.test(location)) found.add('north_america');
  return found;
}

/**
 * Whether a job at [location] can be taken from one of [allowed]. A job is
 * kept when its location is unknown, worldwide, or names an allowed region;
 * it is dropped only when it names other regions alone, such as `Remote - US`
 * or `Anywhere in the US` for Europe.
 */
export function isLocationInRegions(
  location: string | null,
  allowed: ReadonlySet<Region>,
): boolean {
  if (!location || allowed.size === 0) return true;
  const lowerLocation = location.toLowerCase();
  if (
    worldwidePattern.test(lowerLocation) &&
    !limitedWorldwidePattern.test(lowerLocation)
  ) {
    return true;
  }
  const named = regionsOf(location);
  return named.size === 0 || [...named].some((region) => allowed.has(region));
}

/**
 * The regions [text] limits candidates to, in wording such as `US only`,
 * `must be based in the US` or `authorized to work in the United States`;
 * empty when it states no such limit.
 */
export function restrictedRegionsOf(text: string): Set<Region> {
  const found = new Set<Region>();
  const addRegions = (places: string) => {
    for (const region of regionsOf(places)) found.add(region);
  };
  for (const pattern of followingRestrictionPatterns) {
    for (const match of text.matchAll(pattern)) {
      // Up to the end of the sentence, keeping the dots of `U.S.`.
      addRegions(match[1].split(/\.\s/)[0]);
    }
  }
  for (const pattern of precedingRestrictionPatterns) {
    for (const match of text.matchAll(pattern)) {
      // From the start of the sentence.
      addRegions(match[1].trimEnd().split(/\.\s/).pop() ?? '');
    }
  }
  return found;
}

/** Whether [jobTypes] name a contract or freelance job. */
export function isContractWork(jobTypes: readonly string[]): boolean {
  return jobTypes.some((jobType) => contractPattern.test(jobType));
}

/** What a job says about where it can be done. */
export interface JobPlace {
  location: string | null;
  jobTypes?: readonly string[];
  description?: string;
}

/**
 * Whether a job can be taken from one of [allowed]. A job whose location or
 * description limits candidates to other regions alone is dropped. Otherwise
 * a contract or freelance job is kept wherever it is, and any other job is
 * kept when [isLocationInRegions] keeps its location.
 */
export function isOpenToRegions(
  job: JobPlace,
  allowed: ReadonlySet<Region>,
): boolean {
  if (allowed.size === 0) return true;
  const restricted = restrictedRegionsOf(
    `${job.location ?? ''}\n${job.description ?? ''}`,
  );
  if (
    restricted.size > 0 &&
    ![...restricted].some((region) => allowed.has(region))
  ) {
    return false;
  }
  return (
    isContractWork(job.jobTypes ?? []) ||
    isLocationInRegions(job.location, allowed)
  );
}

/** The region of a country name, such as `Spain`, or null when unknown. */
export function regionOfCountry(country: string | null): Region | null {
  if (!country) return null;
  const named = [...regionsOf(country)];
  return named.length === 1 ? named[0] : null;
}

/**
 * The regions to keep jobs for: the `regions` list of the settings document
 * when it has one, otherwise the region of the portfolio's country. Empty
 * means jobs from every region are kept.
 */
export async function loadRegions(
  readDocument: ReadDocument,
  portfolioCountry: string | null,
): Promise<Set<Region>> {
  const settings = await readDocument(
    jobSearchSettingsDocument.collection,
    jobSearchSettingsDocument.documentId,
  );
  if (isRecord(settings) && Array.isArray(settings.regions)) {
    return new Set(
      settings.regions.filter(
        (region): region is Region =>
          typeof region === 'string' && regions.has(region),
      ),
    );
  }
  const region = regionOfCountry(portfolioCountry);
  return new Set(region ? [region] : []);
}

function escapeRegExp(text: string): string {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
