import { describe, expect, it } from 'vitest';

import {
  isRecord,
  stringList,
  stringOrNull,
} from '../../src/shared/json_value.js';

describe('isRecord', () => {
  it('should return true when the value is a plain object', () => {
    expect(isRecord({ a: 1 })).toBe(true);
  });

  it('should return false when the value is null, an array or a primitive', () => {
    expect(isRecord(null)).toBe(false);
    expect(isRecord([])).toBe(false);
    expect(isRecord('a')).toBe(false);
  });
});

describe('stringOrNull', () => {
  it('should return the trimmed string when the value has text', () => {
    expect(stringOrNull('  Flutter ')).toBe('Flutter');
  });

  it('should return null when the value is blank or not a string', () => {
    expect(stringOrNull('  ')).toBeNull();
    expect(stringOrNull(42)).toBeNull();
  });
});

describe('stringList', () => {
  it('should keep trimmed non-blank strings when the value is an array', () => {
    expect(stringList([' Dart ', '', 3, 'Kotlin'])).toEqual(['Dart', 'Kotlin']);
  });

  it('should return an empty list when the value is not an array', () => {
    expect(stringList('Dart')).toEqual([]);
  });
});
