# Port-Rai Portfolio Application

A professional portfolio application built with Flutter, showcasing projects, experience, skills,
and expertise. Built with clean architecture, modular design, and comprehensive theming support
with 12 custom themes. Backend powered by Firebase (Firestore, Analytics, Remote Config), with
feature flags, offline caching, tracking, error reporting, and localization provided by the
workspace's shared `layer/*` packages (see the [root README](../../README.md) for the full
architecture).

## Features

### Portfolio Sections
- **Profile**: Professional introduction and contact information
- **Experience**: Work history and career progression
- **Projects**: Portfolio of completed projects with details and media
- **Skills**: Technical and soft skills showcase
- **Expertise**: Areas of specialization and proficiency
- **Services**: Professional services offered
- **Testimonials**: Client feedback and recommendations
- **On-device AI Assistant**: Ask questions about portfolio content using a local language model

### Technical Features
- **Dynamic Content**: Content fetched from Firebase Firestore
- **Multi-theme Design System**: 12 custom themes with light and dark mode support (Beltane,
  Carnival, Chuseok, Diwali, Halloween, Hogeras, Hogmanay, Holi, Obon, Pachamama, Sakura,
  Christmas)
- **Responsive Layout**: Adaptive UI for mobile, tablet, and desktop
- **Smooth Animations**: Polished transitions and micro-interactions
- **Offline Mode**: Comprehensive caching for full functionality without internet connection
- **On-device AI**: An opt-in assistant. Questions and portfolio context are processed locally,
  without sending them to a hosted AI service. It is off by default; the AI section in Settings
  explains that it runs on the device, then downloads the model (revision-pinned Gemma 4 E2B
  LiteRT-LM bundle, approximately 2.4 GiB, Apache-2.0) only after the user agrees, with download
  progress and a cancel button. Cancelling mid-download deletes the partial model. Turning the
  assistant off asks whether to delete the downloaded model or keep it for later. The "Ask AI"
  button appears on the portfolio only when the assistant is enabled and its model is ready. A
  successful local inference is required before the model counts as ready. Available on Android,
  iOS, and macOS; disabled on web.
  All portfolio fields are available to the assistant, including employment dates, responsibilities,
  achievements, education, testimonials, and project details. Question-focused local context
  selection keeps prompts bounded; employment entries carry a ready-written date range and duration.
- **Feature Flags**: Control features remotely without app updates
- **Analytics & Tracking**: User behavior insights with Firebase Analytics
- **Error Reporting**: Automatic error tracking and reporting via Firebase Crashlytics
- **Localization**: Multi-language support with Flutter intl
- **Accessibility**: WCAG compliant with screen reader support

## Getting Started

### Prerequisites
- Flutter SDK ^3.47.0
- Dart SDK ^3.12.0
- Firebase project with Firestore enabled
- Android Studio / VS Code / IntelliJ IDEA

### Installation
1. Navigate to the app directory:
   ```bash
   cd app/portrai
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Update Firebase configuration in `lib/firebase_options.dart`
4. Generate code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Architecture

The application follows clean architecture with clear separation of concerns:

```text
lib/
├── src/
│   ├── feature/             # Feature modules (data/domain/presentation per feature)
│   │   ├── experience/      # Work experience feature
│   │   ├── expertise/       # Expertise showcase
│   │   ├── assistant/       # Shared portfolio context and conversation UI
│   │   ├── local_assistant/ # On-device inference, model lifecycle and settings
│   │   ├── remote_assistant/ # Cloud inference, consent and independent chat session
│   │   ├── profile/         # User profile
│   │   ├── project/         # Projects portfolio
│   │   ├── service/         # Services offered
│   │   └── testimonial/     # Client testimonials
│   ├── module_configurator/ # App-wide dependency injection wiring
│   ├── route/               # Navigation setup
│   └── utility/             # App-level utilities
└── main.dart                # Application entry point
```

### Dependency Flow
```text
Presentation Layer (Bloc)
    -> Business Logic Layer (Use Cases)
    -> Data Layer (Repositories)
    -> Infrastructure (Firebase, Cache, Remote)
```

See the [creating-new-modules skill](../../.github/skills/creating-new-modules/SKILL.md) and
[architecture-conventions skill](../../.github/skills/flutter-architecture-conventions/SKILL.md)
for the conventions each feature module follows.

### Assistant Modules

`assistant` owns provider-neutral message/response entities, portfolio context generation, and
the callback-driven conversation widget. It has no dependency on either inference provider or bloc.
`local_assistant` consumes that public API and owns on-device inference, model downloads,
enablement preferences, failures, routes, tracking, and the Settings card.
`remote_assistant` owns Firebase AI generation, cloud consent, a separate enablement preference,
failures and a singleton in-memory chat session. All three configurators are registered in the
app, with the shared configurator first. Neither provider depends on the other.

The local assistant uses the `/assistant` route, `feature_ai_assistant` rollout key,
and `assistant_enabled_cache` preference key.
There is no automatic cloud fallback or transfer of conversation history between providers.

### Remote Assistant

The remote screen uses `/remote-assistant` and the independent, default-off
`feature_remote_assistant` flag. Route entry and generation both check rollout; enabling cloud
AI requires explicit consent to send questions, recent chat history and portfolio information
to Google through Firebase. Consent and enablement are stored separately from the on-device
preference. Turning remote AI off withdraws consent and clears its local conversation.
Clear chat resets only the remote session, retaining consent and enablement.

The shared conversation widget renders streamed text as provisional until generation finishes
successfully. Failed partial answers are discarded and never become future provider history.
Disable/reset invalidate pending output. They stop local consumption and close the owned
transport; they cannot guarantee that server generation or billing stops.
Question content and generated text are excluded from remote request/state logging and analytics.

The portfolio launcher offers providers based on rollout and platform support, before user
enablement. It is hidden when neither is offered, opens directly when only one is offered, and
shows a localized on-device/cloud choice when both are offered. The on-device option is hidden
on web; cloud is supported on the configured Firebase platforms (Android, iOS and web).
Selecting an unconfigured local assistant opens its existing download/enable controls.
Selecting cloud without consent opens the explicit consent screen; discovery never grants consent.

Settings has separate on-device model management and cloud consent/chat cards. Enabling cloud
from Settings opens the consent screen. Turning cloud off withdraws consent and clears its chat;
clear chat retains consent. Each provider's singleton bloc preserves its own in-memory conversation
across navigation. Dev flag updates notify both blocs without polling; flag-off clears pending
output and sessions. Every new request and enable action rechecks availability.
See the [assistant reference](lib/src/feature/assistant/README.md) for module boundaries.
Production use requires validated App Check enforcement, model availability, and quota/spending
controls, including a successful authorized smoke test. See the
[Firebase AI setup guide](../../layer/firebase/README.md#firebase-ai-logic-setup).
No live or billable AI request is required by the automated tests.

Generation uses `gemini-2.5-flash`, a 1,024-token output limit and temperature 0.3.
Requests are bounded to 2,000 question characters, 100,000 portfolio-context characters,
12 recent history messages / 24,000 history characters, and 12,000 response characters.
The absolute request deadline is 60 seconds, with no automatic retries. Oversized input is
rejected rather than silently truncated; older completed turns remain visible but are excluded
from the bounded provider history.

## Theming

The app supports 12 custom themes, each with unique color palettes and styling.

### Available Themes
1. Beltane - Celtic spring festival inspired
2. Carnival - Brazilian carnival vibes
3. Chuseok - Korean harvest festival
4. Diwali - Hindu festival of lights
5. Halloween - Gothic and spooky
6. Hogeras - Mediterranean coastal
7. Hogmanay - Scottish New Year
8. Holi - Indian festival of colors
9. Obon - Japanese lantern festival
10. Pachamama - Andean earth festival
11. Sakura - Japanese cherry blossom
12. Christmas - Winter holiday theme

### Switching Themes
Themes can be switched at runtime through the app settings or controlled via Firebase Remote
Config.

## Supported Platforms

| Platform | Support | Notes |
|----------|---------|-------|
| Android  | Yes     | API 30+ |
| iOS      | Yes     | iOS 15+ |
| Web      | Yes     | Modern browsers; on-device AI assistant disabled |
| macOS    | Yes     | Apple Silicon; macOS 12+ |

## Development

### Running the App
```bash
# Development mode
flutter run --debug

# Profile mode (performance profiling)
flutter run --profile

# Release mode
flutter run --release
```

### Code Generation
```bash
# Generate code (routes, JSON serialization, etc.)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/feature/profile/profile_test.dart
```

### Localization
```bash
# Generate localization files
flutter gen-l10n

# Supported languages: English (en), [add others]
```

## Configuration

### Build Variants
The app supports multiple build configurations:
- **Development**: Local testing with debug tools
- **Staging**: Pre-production testing environment
- **Production**: Live production environment

### Environment Variables
Select the build environment using `--dart-define=build_env=staging` or
`--dart-define=build_env=prod`. The shared
[`BuildEnvironment`](../../layer/core/lib/src/model/build_config.dart) defines
the environment-specific behavior. Release workflows select staging for previews
and prod for production; both currently use the same Firebase project.

### Firebase App Check

App Check activates before Firebase service requests. Debug builds use registered
debug tokens; public preview and production builds use Play Integrity on Android,
App Attest with DeviceCheck fallback on iOS, and reCAPTCHA Enterprise on web.

Set the repository Actions variable `FIREBASE_APP_CHECK_WEB_SITE_KEY` to your
public Enterprise website key before running preview or production web releases.
For local non-debug web builds, pass the same value through `--dart-define`.
Native builds do not need this key.

Register all providers in Firebase Console and update iOS provisioning profiles
for the App Attest entitlement before distributing builds. Leave enforcement
disabled until valid client traffic is confirmed. See the
[Firebase setup and rollout guide](../../layer/firebase/README.md#app-check-setup)
for signing, domains, local debug tokens, and enforcement steps.

### Feature Flags
Feature flags are managed through Firebase Remote Config:
- Configure in Firebase Console
- Keys defined in `lib/core/config/feature_flags.dart`
- `feature_ai_assistant` (default off) shows the on-device AI assistant in Settings and on the portfolio when turned on
- `feature_remote_assistant` (default off) permits the independent cloud assistant, subject to saved user consent and enablement

## Dependencies

### Core Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `go_router` | Navigation and routing |
| `firebase` | Backend services |
| `design_system` | UI components |
| `cache` | Offline caching |
| `error_reporter` | Error tracking |
| `log_reporter` | Logging |
| `feature_flag` | Feature flags |

### Development Dependencies

| Package | Purpose |
|---------|---------|
| `build_runner` | Code generation |
| `json_serializable` | JSON serialization |
| `flutter_gen_runner` | Asset generation |
| `mocktail` | Testing mocks |

## Deployment

The Settings and portfolio footer version labels use installed package metadata.
Release workflows pass the tag's version and build number through Flutter's
`--build-name` and `--build-number` options on all platforms, including web's
generated `version.json`. Local Melos web deployments use the app's `pubspec.yaml`
version unless build metadata is explicitly overridden.

### Web Deployment
Set `FIREBASE_APP_CHECK_WEB_SITE_KEY` in the ignored
`app/portrai/.env.production` file. Keep debug tokens in `.env` only.

```bash
# Run from the workspace root: build and deploy to Firebase Hosting
melos run deploy_portrai
```

The script loads `.env.production` automatically unless the site key is already
set in the environment. This trusted local file should contain only shell
assignments and comments; the debug-token `.env` is never loaded.

### Android Deployment
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS Deployment
```bash
# Build iOS app
flutter build ios --release

# Build IPA (for App Store)
flutter build ipa --release
```

## Analytics

The app tracks user interactions using Firebase Analytics:
- **Screen Views**: Automatic tracking of page navigation
- **User Actions**: Button clicks, form submissions
- **Content Views**: Project views, service views
- **Custom Events**: Feature-specific interactions

View analytics in [Firebase Console](https://console.firebase.google.com).

## Error Reporting

Errors are automatically reported to Firebase Crashlytics:
- **Crash Reports**: Unhandled exceptions
- **Non-Fatal Errors**: Handled errors with context
- **Custom Logs**: Debug information for investigation

## Contributing

See the root [Contributing](../../README.md#contributing) section for the development workflow,
code style, and branch/PR conventions (also documented in
[`.github/skills/pr-and-branch-conventions/SKILL.md`](../../.github/skills/pr-and-branch-conventions/SKILL.md)).

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Mayank Rai**
- Portfolio: [Your Website]
- GitHub: [@yourusername]
- LinkedIn: [Your LinkedIn]

## Acknowledgments

- Design inspiration from modern portfolio websites
- Built with [Flutter](https://flutter.dev)
- Backend powered by [Firebase](https://firebase.google.com)
- Icons by [Font Awesome](https://fontawesome.com)

---

**Version**: 1.0.0
**Last Updated**: August 2026
**Flutter Version**: 3.47.0
