import { describe, expect, it } from 'vitest';

import { htmlToText } from '../../../src/job_opening/feed/html_text.js';

describe('htmlToText', () => {
  it('should keep paragraph and list breaks when the description has HTML', () => {
    const text = htmlToText(
      '<h2>Role</h2><p>Build apps.</p><ul><li>Flutter</li><li>Dart</li></ul>',
    );

    expect(text).toBe('Role\nBuild apps.\n- Flutter\n- Dart');
  });

  it('should decode entities when the description escapes characters', () => {
    expect(
      htmlToText('<p>R&amp;D &lt;team&gt; &#8211; caf&#xe9;&nbsp;</p>'),
    ).toBe('R&D <team> – café');
  });

  it('should drop scripts and styles when the description contains them', () => {
    expect(
      htmlToText('<style>p{}</style><p>Hi</p><script>alert(1)</script>'),
    ).toBe('Hi');
  });

  it('should cap the length when the description is very long', () => {
    const text = htmlToText(`<p>${'a'.repeat(6_000)}</p>`);

    expect(text).toHaveLength(5_001);
    expect(text.endsWith('…')).toBe(true);
  });

  it('should not add spaces where inline tags close next to punctuation', () => {
    expect(
      htmlToText(
        '<p>Use <b>Flutter</b>, <em>Dart</em>. See <a href="x">docs</a>!</p>',
      ),
    ).toBe('Use Flutter, Dart. See docs!');
  });
});
