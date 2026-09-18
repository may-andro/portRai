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

### Technical Features
- **Dynamic Content**: Content fetched from Firebase Firestore
- **Multi-theme Design System**: 12 custom themes with light and dark mode support (Beltane,
  Carnival, Chuseok, Diwali, Halloween, Hogeras, Hogmanay, Holi, Obon, Pachamama, Sakura,
  Christmas)
- **Responsive Layout**: Adaptive UI for mobile, tablet, and desktop
- **Smooth Animations**: Polished transitions and micro-interactions
- **Offline Mode**: Comprehensive caching for full functionality without internet connection
- **Feature Flags**: Control features remotely without app updates
- **Analytics & Tracking**: User behavior insights with Firebase Analytics
- **Error Reporting**: Automatic error tracking and reporting via Firebase Crashlytics
- **Localization**: Multi-language support with Flutter intl
- **Accessibility**: WCAG compliant with screen reader support

## Getting Started

### Prerequisites
- Flutter SDK ^3.47.0
- Dart SDK ^3.11.0
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
| Android  | Yes     | API 21+ |
| iOS      | Yes     | iOS 12+ |
| Web      | Yes     | All modern browsers |
| macOS    | Yes     | macOS 10.14+ |

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
Configure environment-specific settings in `lib/core/config/build_environment.dart`.

### Feature Flags
Feature flags are managed through Firebase Remote Config:
- Configure in Firebase Console
- Keys defined in `lib/core/config/feature_flags.dart`

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

### Web Deployment
```bash
# Build web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

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
