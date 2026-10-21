const maxDescriptionLength = 5_000;

const namedEntities: Record<string, string> = {
  amp: '&',
  lt: '<',
  gt: '>',
  quot: '"',
  apos: "'",
  nbsp: ' ',
};

/**
 * Turns a feed's HTML description into plain text, keeping paragraph and
 * list breaks, and caps its length so documents stay small.
 */
export function htmlToText(html: string): string {
  const text = html
    .replace(/<\s*(script|style)[^>]*>[\s\S]*?<\s*\/\s*\1\s*>/gi, ' ')
    .replace(/<\s*br\s*\/?>/gi, '\n')
    .replace(/<\s*\/\s*(p|div|li|h[1-6]|ul|ol)\s*>/gi, '\n')
    .replace(/<\s*li[^>]*>/gi, '- ')
    // Inline formatting sits inside words and sentences, so it leaves no gap.
    .replace(
      /<\s*\/?\s*(a|abbr|b|code|em|i|mark|small|span|strong|sub|sup|u)\b[^>]*>/gi,
      '',
    )
    .replace(/<[^>]*>/g, ' ')
    .replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, decodeEntity)
    .replace(/[ \t\f\v]+/g, ' ')
    .replace(/ *\n */g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
  return text.length <= maxDescriptionLength
    ? text
    : `${text.slice(0, maxDescriptionLength).trimEnd()}…`;
}

function decodeEntity(entity: string, name: string): string {
  const lowerName = name.toLowerCase();
  if (lowerName.startsWith('#x')) {
    return fromCodePoint(Number.parseInt(lowerName.slice(2), 16), entity);
  }
  if (lowerName.startsWith('#')) {
    return fromCodePoint(Number.parseInt(lowerName.slice(1), 10), entity);
  }
  return namedEntities[lowerName] ?? entity;
}

function fromCodePoint(codePoint: number, fallback: string): string {
  return Number.isInteger(codePoint) && codePoint > 0 && codePoint <= 0x10ffff
    ? String.fromCodePoint(codePoint)
    : fallback;
}
