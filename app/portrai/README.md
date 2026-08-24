# Port-Rai Portfolio Application

A professional portfolio application built with Flutter, showcasing projects, experience, skills, and expertise. Built with clean architecture, modular design, and comprehensive theming support with 12 custom themes.

## 📋 Overview

Port-Rai is the main portfolio application for Mayank Rai, featuring:

- **Multi-theme Design System**: 12 beautifully designed themes with light and dark mode support
- **Responsive Design**: Optimized layouts for mobile, tablet, and desktop
- **Clean Architecture**: Modular, testable, and maintainable codebase
- **Firebase Integration**: Backend powered by Firebase (Firestore, Analytics, Remote Config)
- **Feature Flags**: Control features remotely without app updates
- **Offline Support**: Comprehensive caching for offline functionality
- **Analytics & Tracking**: User behavior insights with Firebase Analytics
- **Error Reporting**: Automatic error tracking and reporting
- **Localization**: Multi-language support with Flutter intl

## ✨ Features

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
- **Theming**: 12 custom themes (Beltane, Carnival, Diwali, Halloween, Sakura, Christmas, etc.)
- **Responsive Layout**: Adaptive UI for all screen sizes
- **Smooth Animations**: Polished transitions and micro-interactions
- **Offline Mode**: Full functionality without internet connection
- **Performance**: Optimized loading and caching strategies
- **Accessibility**: WCAG compliant with screen reader support

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.47.0
- Dart SDK ^3.11.0
- Firebase project with Firestore enabled
- Android Studio / VS Code / IntelliJ IDEA

### Installation

1. **Navigate to the app directory**:
   ```bash
   cd app/portrai
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Generate code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

## 🏗️ Architecture

The application follows clean architecture with clear separation of concerns:

```
lib/
├── core/                    # App-level configuration
│   ├── app/                # App initialization and routing
│   ├── config/             # Build configuration
│   └── route/              # Navigation setup
├── feature/                # Feature modules
│   ├── experience/         # Work experience feature
│   ├── expertise/          # Expertise showcase
│   ├── home/               # Landing page
│   ├── profile/            # User profile
│   ├── project/            # Projects portfolio
│   ├── service/            # Services offered
│   └── testimonial/        # Client testimonials
└── main.dart               # Application entry point
```

### Dependency Flow

```
Presentation Layer (BLoC/Cubit)
    ↓
Business Logic Layer (Use Cases)
    ↓
Data Layer (Repositories)
    ↓
Infrastructure (Firebase, Cache, Remote)
```

## 🎨 Theming

The app supports 12 custom themes, each with unique color palettes and styling:

### Available Themes

1. **Beltane** - Celtic spring festival inspired
2. **Carnival** - Brazilian carnival vibes
3. **Chuseok** - Korean harvest festival
4. **Diwali** - Hindu festival of lights
5. **Halloween** - Gothic and spooky
6. **Hogeras** - Mediterranean coastal
7. **Hogmanay** - Scottish New Year
8. **Holi** - Indian festival of colors
9. **Obon** - Japanese lantern festival
10. **Pachamama** - Andean earth festival
11. **Sakura** - Japanese cherry blossom
12. **Christmas** - Winter holiday theme

### Switching Themes

Themes can be switched at runtime through the app settings or controlled via Firebase Remote Config.

## 📱 Supported Platforms

| Platform | Support | Notes |
|----------|---------|-------|
| Android  | ✅      | API 21+ |
| iOS      | ✅      | iOS 12+ |
| Web      | ✅      | All modern browsers |
| macOS    | ✅      | macOS 10.14+ |

## 🛠️ Development

### Running in Different Modes

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

## 🔧 Configuration

### Build Variants

The app supports multiple build configurations:

- **Development**: Local testing with debug tools
- **Staging**: Pre-production testing environment
- **Production**: Live production environment

### Environment Variables

Configure environment-specific settings in:
- `lib/core/config/build_environment.dart`

### Feature Flags

Feature flags are managed through Firebase Remote Config:
- Configure in Firebase Console
- Keys defined in `lib/core/config/feature_flags.dart`

## 📦 Dependencies

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

## 🚀 Deployment

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

## 📊 Analytics

The app tracks user interactions using Firebase Analytics:

- **Screen Views**: Automatic tracking of page navigation
- **User Actions**: Button clicks, form submissions
- **Content Views**: Project views, service views
- **Custom Events**: Feature-specific interactions

View analytics in [Firebase Console](https://console.firebase.google.com).

## 🐛 Error Reporting

Errors are automatically reported to Firebase Crashlytics:

- **Crash Reports**: Unhandled exceptions
- **Non-Fatal Errors**: Handled errors with context
- **Custom Logs**: Debug information for investigation

## 🤝 Contributing

### Development Workflow

1. Create a feature branch from `main`
2. Make your changes following the code style
3. Write/update tests for your changes
4. Run tests and ensure they pass
5. Create a pull request with a clear description

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use the workspace `analysis_options.yaml`
- Run `dart format .` before committing
- Ensure `flutter analyze` passes with no issues

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Mayank Rai**
- Portfolio: [Your Website]
- GitHub: [@yourusername]
- LinkedIn: [Your LinkedIn]

## 🙏 Acknowledgments

- Design inspiration from modern portfolio websites
- Built with [Flutter](https://flutter.dev)
- Backend powered by [Firebase](https://firebase.google.com)
- Icons by [Font Awesome](https://fontawesome.com)

---

**Version**: 1.0.0  
**Last Updated**: August 2026  
**Flutter Version**: 3.47.0
