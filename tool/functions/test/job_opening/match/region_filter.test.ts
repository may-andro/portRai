import { describe, expect, it, vi } from 'vitest';

import {
  isContractWork,
  isLocationInRegions,
  isOpenToRegions,
  loadRegions,
  type Region,
  regionOfCountry,
  regionsOf,
  restrictedRegionsOf,
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
    ['Boulder, CO', ['north_america']],
    ['Lagos', ['middle_east_africa']],
    ['the U.S', ['north_america']],
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
    ['United States, Canada, Mexico +4 more', false],
    ['Worldwide (US time zones)', false],
    ['Remote; Anywhere in US', false],
    ['Anywhere in Europe', true],
    ['Remote - US or Europe', true],
    ['Boulder, CO', false],
    ['Nepal', false],
  ])('should keep %s for Europe: %s', (location, expected) => {
    expect(isLocationInRegions(location, europe)).toBe(expected);
  });

  it('should keep every location without preferred regions', () => {
    expect(isLocationInRegions('Remote - USA', new Set())).toBe(true);
  });
});

describe('restrictedRegionsOf', () => {
  it.each([
    ['Remote (US only)', ['north_america']],
    [
      'You must be based in the U.S. We also have a Berlin office.',
      ['north_america'],
    ],
    [
      'Candidates must be authorized to work in the United States.',
      ['north_america'],
    ],
    ['This role is open to candidates in Spain or Portugal.', ['europe']],
    ['You must be a US citizen.', ['north_america']],
    ['Remote within Canada.', ['north_america']],
    ['Our offices are in New York. Senior engineers only.', []],
    ['We are a company based in San Francisco.', []],
    ['Build Flutter apps.', []],
  ])('should read the limit of %s as %j', (text, expected) => {
    expect([...restrictedRegionsOf(text)].sort()).toEqual([...expected].sort());
  });
});

describe('isContractWork', () => {
  it.each([
    [['Contract'], true],
    [['freelance'], true],
    [['Contractor'], true],
    [['contract_to_hire'], true],
    [['Full Time'], false],
    [[], false],
  ])('should read %j as contract work: %s', (jobTypes, expected) => {
    expect(isContractWork(jobTypes)).toBe(expected);
  });
});

describe('isOpenToRegions', () => {
  it('should keep a contract job from another region', () => {
    expect(
      isOpenToRegions(
        { location: 'Remote - USA', jobTypes: ['Contract'] },
        europe,
      ),
    ).toBe(true);
  });

  it('should drop a contract job that limits candidates to another region', () => {
    expect(
      isOpenToRegions(
        { location: 'Remote (US only)', jobTypes: ['Freelance'] },
        europe,
      ),
    ).toBe(false);
  });

  it('should drop a job whose description limits candidates to another region', () => {
    expect(
      isOpenToRegions(
        {
          location: 'Remote',
          description: 'You must be authorized to work in the United States.',
        },
        europe,
      ),
    ).toBe(false);
  });

  it('should keep a job whose limit includes a preferred region', () => {
    expect(
      isOpenToRegions(
        {
          location: 'Remote',
          description: 'You must be based in the US or the EU.',
        },
        europe,
      ),
    ).toBe(true);
  });

  it('should drop a full-time job located in another region alone', () => {
    expect(
      isOpenToRegions(
        { location: 'Remote - USA', jobTypes: ['Full Time'] },
        europe,
      ),
    ).toBe(false);
  });

  it('should keep every job without preferred regions', () => {
    expect(isOpenToRegions({ location: 'Remote (US only)' }, new Set())).toBe(
      true,
    );
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
