# Portfolio Assistant

The `assistant` feature provides provider-neutral message and response entities,
portfolio context generation, and the callback-driven conversation widget.
It does not import either provider, resolve their blocs, or select an inference engine.

## Features

- Portfolio-only context assembled by `GetAssistantContextUseCase`, including computed
  career overview, record digests, profile, experiences, projects, expertise, services
  and testimonials.
- Typed text responses and shared suggestions, message bubbles and chat input.
- Provisional streamed responses supplied by the caller, without provider-specific state.

## Getting Started

Register `AssistantModuleConfigurator` before the provider configurators. Import
`assistant.dart` from consumers, not private feature barrels.

The app registers independent `local_assistant` and `remote_assistant` modules.
Both consume this API; neither provider imports the other.

## Usage

The portfolio's `AssistantLauncherWidget` composes discovery:

| Local rollout | Cloud rollout | Offered |
|---------------|---------------|----------------------------------|
| Off | Off | No launcher |
| On | Off | On-device setup/chat directly |
| Off | On | Cloud chat directly |
| On | On | Cloud chat directly, never local fallback |

Offering a provider does not require local user enablement or model readiness.
The rollout enabler maintains mutually exclusive flags. If both are on, cloud takes
priority based on its flag alone, even if unsupported or in error.
The app never rewrites flags or preferences to enforce exclusivity. On-device is hidden
on web; cloud discovery depends only on its flag. Firebase generation supports configured
Android, iOS and web apps; unsupported platforms show an unavailable message inside cloud chat
rather than hiding its entry or exposing the other chat.

Settings exposes only the active feature's model management or a plain Ask AI button that opens
cloud chat. The button depends only on the cloud flag, not platform support, context retrieval
or session readiness. Clear-chat controls and cloud disclosure remain inside chat.
Conversations remain in independent singleton blocs across navigation. There is no
chooser, context switch, automatic fallback or transfer of history between features.

Provider blocs, events and states are module-internal. Routes and public cards own
`BlocProvider.value` for their module's retained singleton; there are no app-wide assistant
bloc providers. Portfolio and Settings blocs read rollout flags directly through
`IsFeatureEnabledUseCase` and use the public feature-owned
`IsLocalAssistantSupportedUseCase` boolean platform check for local discovery, refreshing on
visibility/return. Visiting Settings or the portfolio does not initialize remote chat or load
its context. The local provider-owned visibility widget still rechecks its retained session.
Remote chat rechecks rollout and platform support on chat visibility/return and before requests,
invalidating retained output when unavailable, without exposing its bloc to hosts.
Priority is a simple remote-first check in the portfolio and Settings composition.
A failed remote flag check hides both providers, rather than falling back to local.
The shared assistant module remains provider-neutral, and providers do not import siblings.

## Configuration

### On-device

- Default-off rollout key: `feature_ai_assistant`.
- Compatibility route: `/assistant`; preference cache key: `assistant_enabled_cache`.
- Gemma 4 E2B via `flutter_edge_ai` and LiteRT-LM; the pinned model ID, file and
  revision live in `FlutterEdgeAiLocalAssistantRepository`.
- Explicit model download confirmation, progress, cancellation, keep/delete and retry
  controls remain available from Settings and the setup screen.
- Installed models load lazily on a question. A readiness inference probes engine support.
- Questions use deterministic contact/career answers where applicable and otherwise
  bounded context selection. Missing portfolio facts are not guessed.
- Disable and reset invalidate late output and clear follow-up context. Reset retains
  enablement and downloaded files. Invalidating output does not guarantee cancellation
  of native generation; download cancellation waits for cleanup.
- If native generation is still finishing after reset, a new request reports a localized
  busy failure instead of starting a concurrent native request.

### Cloud

- Independent default-off rollout key: `feature_remote_assistant`.
- Route: `/remote-assistant`; its entry is flag-only. Runtime rollout and platform guards show
  unavailability inside chat.
- Questions, bounded recent completed history and portfolio context are sent to Google
  through Firebase. The disclosure warns against sensitive input and inaccurate answers.
- There is no saved remote consent, enablement preference or user activation toggle.
- Opening the screen loads portfolio context but never calls the model until a question.
- Clear chat resets only the remote in-memory session.
- Failed partial responses never enter future provider history.
- Flag-off rechecks/reset stop local consumption and close the owned transport, but cannot undo
  requests already sent or guarantee server cancellation or cessation of billing.
- Request/state logging and analytics exclude cloud prompts and generated content.

Both routes, enable actions and new requests check rollout and platform availability.
Flags are rechecked on screen visibility/return and before new requests, without notifications
or polling. The app-level local access policy also guards direct local routes and requests
for their own rollout. Explicit provider routes retain independent access; discovery and
Settings select remote first without a shared policy registry. Local disable and both providers' reset/flag-off rechecks
invalidate late output; they do not guarantee
native or server cancellation. Repository exceptions map to localized failures in use cases.

Production cloud use requires separately validated Firebase App Check enforcement, model
availability and spending controls, plus an authorized release smoke test. Automated tests
do not make live or billable requests or prove console enforcement.
See the [Firebase AI setup guide](../../../../../../layer/firebase/README.md#firebase-ai-logic-setup).

## Testing

From `app/portrai`:

```bash
flutter gen-l10n
dart run build_runner build
flutter analyze lib test
flutter test test/src/feature/assistant test/src/feature/local_assistant \
  test/src/feature/remote_assistant test/src/feature/setting test/src/feature/portfolio
```

Tests use deterministic fixtures and mocked inference. They cover discovery combinations,
unsupported platforms, flag-only cloud activation, direct-route guards, pending-request invalidation,
local download consent, and independent sessions. No model download or live AI generation is needed.

Portfolio information limitations are documented in [DATA_GAPS.md](DATA_GAPS.md).
