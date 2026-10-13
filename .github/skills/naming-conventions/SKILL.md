---
name: naming-conventions
description: Code of conduct for naming variables, parameters and lambda arguments in this repo. Use when writing or reviewing any Dart code, to avoid single-letter or abbreviated names.
---

# Naming Conventions

Every variable, parameter, loop index and lambda argument must have a meaningful, full name that
states what it holds or does.

- Never use single-letter or cryptic short names such as `w`, `h`, `c`, `l`, `i`, `e`, `p`, `tmp`, `val`.
- Never use abbreviations or short forms (`ctrl`, `btn`, `idx`, `cnt`, `msg`); spell the word out.
- Lambda arguments follow the same rule: `.map((language) => ...)`, `onPlay: (controller) => ...`.
- Loop indices describe what they index: `slotIndex`, `placeIndex`, not `i`.
- Names include the unit or role when it isn't obvious: `photoWidth`, `photoHeight`, `animationDuration`.
- Unused callback parameters may stay `_`.
- Established domain acronyms (`id`, `url`, `uri`, `dto`) are fine; `context` is never shortened.

```dart
// Bad
final w = widget.width;
final h = w * 1.05;
profile.languages.map((l) => l.language);

// Good
final photoWidth = widget.width;
final photoHeight = photoWidth * 1.05;
profile.languages.map((language) => language.language);
```
