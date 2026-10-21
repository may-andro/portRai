import { describe, expect, it, vi } from 'vitest';

import {
  isLocationInRegions,
  loadRegions,
  type Region,
  regionOfCountry,
  regionsOf,
} from '../../../src/job_opening/match/region_filter.js';

const europe = new Set<Region>(['europe']);

describe('regionsOf', () => {
  it.each([
    ['Remote - USA', ['north_america']],
    ['San Francisco, CA', ['north_america']],
    ['Remote (EST)', ['north_america']],
    ['Remote Netherlands', ['europe']],
    ['Berlin', ['europe']],
    ['Remote (CET)', ['europe']],
    ['LATAM', ['latin_america']],
    ['Bengaluru, India', ['asia_pacific']],
    ['EMEA', ['europe', 'middle_east_africa']],
    ['Remote', []],
  ])('should place %s in %j', (location, expected) => {
    expect([...regionsOf(location)].sort()).toEqual([...expected].sort());
  });

  it('should not read words inside other words', () => {
    expect([...regionsOf('Indianapolis campus')]).toEqual([]);
  });
});

describe('isLocationInRegions', () => {
  it.each([
    ['Remote - United States', false],
    ['New York, NY (HQ), Remote (Canada), Remote (US)', false],
    ['Remote Germany · Remote Canada', true],
    ['Remote', true],
    ['Worldwide', true],
    ['Anywhere in the world, US preferred', true],
    [null, true],
    ['Remote (Spain)', true],
    ['Albania, Andorra, Argentina +70 more', true],
    ['Nepal', false],
  ])('should keep %s for Europe: %s', (location, expected) => {
    expect(isLocationInRegions(location, europe)).toBe(expected);
  });

  it('should keep every location without preferred regions', () => {
    expect(isLocationInRegions('Remote - USA', new Set())).toBe(true);
  });
});

describe('regionOfCountry', () => {
  it.each([
    ['Spain', 'europe'],
    ['United States', 'north_america'],
    ['Atlantis', null],
    [null, null],
  ])('should place %s in %s', (country, region) => {
    expect(regionOfCountry(country)).toBe(region);
  });
});

describe('loadRegions', () => {
  it('should use the regions of the settings document', async () => {
    const readDocument = vi.fn().mockResolvedValue({
      regions: ['europe', 'north_america', 'moon'],
    });

    const regions = await loadRegions(readDocument, 'Spain');

    expect(readDocument).toHaveBeenCalledWith('job_search', 'settings');
    expect([...regions]).toEqual(['europe', 'north_america']);
  });

  it('should use the region of the portfolio country without settings', async () => {
    const regions = await loadRegions(vi.fn().mockResolvedValue(null), 'Spain');

    expect([...regions]).toEqual(['europe']);
  });

  it('should keep every region when the country is unknown', async () => {
    const regions = await loadRegions(vi.fn().mockResolvedValue(null), null);

    expect(regions.size).toBe(0);
  });
});
