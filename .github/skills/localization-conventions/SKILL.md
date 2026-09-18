---
description: Use when adding user-facing text, a new translation key, or a new supported language in this Flutter workspace, to follow the ARB/gen-l10n setup instead of hardcoding strings.
---

# Localization Conventions

Config: `app/portrai/l10n.yaml`. Source of truth: ARB files in
`app/portrai/lib/l10n/arb/`. Generated output (`app_localizations*.dart`,
`AppLocalizations`) lives in `app/portrai/lib/l10n/generated/` — **never
edit generated files by hand**, they're rebuilt by `flutter gen-l10n`
(driven by `l10n.yaml`: `arb-dir: lib/l10n/arb`,
`template-arb-file: app_en.arb`, `output-class: AppLocalizations`).

## Supported languages

Three ARB files exist today: `app_en.arb` (template/source of truth),
`app_es.arb`, `app_nl.arb`. Every key added to `app_en.arb` must be added
to `app_es.arb` and `app_nl.arb` too — `gen-l10n` will otherwise fall back
silently or fail depending on config; don't ship a key in only one locale.

## Adding a new key

```json
{
  "copyright": "© {year} All rights reserved by PortRai",
  "@copyright": {
    "description": "Copyright text",
    "placeholders": {
      "year": { "type": "String", "example": "2026" }
    }
  }
}
```

- Key names are `camelCase`.
- Every key must have a matching `"@key"` metadata block with at least a
  `description` — this is what shows up as doc comments on the generated
  getter, and is the only source of context for other translators.
- Declare `placeholders` (with `type` and an `example`) for any
  interpolated value — don't use raw string concatenation for dynamic
  text.
- After editing ARB files, regenerate with `flutter gen-l10n` (or just run
  `flutter test`/`flutter run` — Flutter runs `gen-l10n` automatically
  whenever `l10n.yaml` is present) before using the new getter.

## Using a translated string

```dart
Text(context.localizations.companyName);
```

Access via `context.localizations` (a `BuildContext` extension), not by
constructing `AppLocalizations.of(context)` directly at call sites.

## Failure messages

Domain `Failure`s that need a user-facing message are annotated
`@Localizable('<arbKey>')` and resolved through the generated
`FailureTranslator.translate(context, failure)` — the `<arbKey>` must
exist in every locale ARB file. See `error-handling-conventions` for the
full pattern; don't add a raw string message field to a `Failure` instead
of an ARB key.

## Don't invent

Don't hardcode any user-visible string in a widget — every string the user
can see goes through an ARB key, even short/one-off text (button labels,
snackbar messages). Don't add a language ARB file without also updating
`AppLocalizations.supportedLocales`/`l10n.yaml` config as needed and
filling in every existing key.

## Related skills

- `error-handling-conventions` — `@Localizable` failure-to-message
  mapping.
