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

## Ambiguous names

A name must say *what the value is*, not just that it exists or where it came from.

- Never name a value `result`, `data`, `response`, `value`, `item`, `info` or `obj`, and never `override`/`default` etc. on their own.
- Don't put a mechanism word (`Override`, `Manager`, `Helper`) in a class or file name when the domain noun says it all: `DesignSystemCache`, not `DesignSystemOverrideCache`.
- Name the thing: `cachedDesignSystem`, `selectedDesignSystem`, `assetSourceEither`.
- Values of type `Either` (use case results) end in `Either`: `setDesignSystemEither`, `resetDesignSystemEither`. The unwrapped value gets the domain name: `cachedDesignSystemEither.right` → `designSystem`.
- Don't name a variable after the verb or mechanism that produced it (`overrideResult`); name the content.
- Nullable/optional values say what absence means when it is not obvious: `designSystem` (`null` = follow the month).

```dart
// Bad
final overrideResult = await getDesignSystemUseCase();
final result = await resetUseCase();
final override = state.designSystem;

// Good
final cachedDesignSystemEither = await getDesignSystemUseCase();
final resetDesignSystemEither = await resetDesignSystemUseCase();
final selectedDesignSystem = state.designSystem;
```
