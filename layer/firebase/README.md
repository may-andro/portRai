# Firebase Module

A comprehensive Firebase integration layer for Flutter applications, providing centralized access
to all Firebase services with proper initialization and configuration.

## Features

- **Complete Firebase Suite**: Integration with all major Firebase services
- **Centralized Configuration**: Single initialization point for all Firebase services
- **Type-Safe Access**: Strongly typed service instances
- **Dependency Injection**: Seamless integration with the module injector system
- **Cross-Platform**: Support for Android, iOS, macOS, and Web platforms
- **Firebase AI Logic**: Configurable Gemini text generation and streaming with typed errors

## Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```yaml
dependencies:
  firebase:
    path: layer/firebase
```

```dart
import 'package:firebase/firebase.dart';
```

> **Note**: As a workspace module, `firebase` is automatically available to all other modules
> without manual dependency configuration.

### Module Configuration

1. **Add Firebase configuration files**:
   - **Android**: `android/app/google-services.json`
   - **iOS**: `ios/Runner/GoogleService-Info.plist`
   - **macOS**: `macos/Runner/GoogleService-Info.plist`
   - **Web**: Update `web/index.html` with Firebase config

2. **Configure the module** in your application's module configurator list:

```dart
import 'package:firebase/firebase.dart';
final configurator = FirebaseModuleConfigurator(
  isFirebaseEnabled: buildConfig.buildEnvironment.isFirebaseEnabled,
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  appCheckWebSiteKey: const String.fromEnvironment(
    'FIREBASE_APP_CHECK_WEB_SITE_KEY',
  ),
  storageBucketUrl: '',
);
```

Pass this configurator to `ModuleInjectorController.setUpDIGraph`. Its
`preDependenciesSetup` initializes Firebase. After dependency registration,
`postDependenciesSetup` resolves the App Check controller through DI and awaits
activation before initializing the other Firebase services. Dependency registration
and earlier module hooks must not issue protected Firebase requests. Do not initialize
Firebase separately in an Apple `AppDelegate`, as this can bypass provider selection.

`isFirebaseEnabled` controls Analytics and Crashlytics collection, not Firebase
initialization or App Check. Both staging and production activate App Check.
It also does not gate AI requests: the owning app feature must enforce its rollout
flag, user preference, and cloud-processing consent before calling the AI controller.

### Firebase AI Logic Setup

1. Open **Firebase Console > Firebase AI Logic** in the existing Firebase project
   and complete the guided setup for the chosen Gemini API provider. Enable the
   required APIs through that workflow. The default module backend is the
   **Gemini Developer API** (`FbAiBackend.googleAI`). Alternatively configure
   `aiBackend: FbAiBackend.agentPlatform` and an appropriate `aiLocation`
   (default `global`) for the Agent Platform Gemini API, formerly Vertex AI.
   Changing that location does not relocate other Firebase services.
2. Choose an available text-capable model for that provider and pass its name
   when creating a text model. Model availability, supported settings, quotas,
   pricing, and regional support must be checked in the provider documentation.
   The layer deliberately does not hardcode a model or portfolio prompt.
3. Register the app's production attestation providers as described below and
   verify **App Check > APIs > Firebase AI Logic** is **Enforced** before exposing
   cloud AI to public clients. New AI Logic setup may enable enforcement automatically;
   verify existing projects rather than assuming enforcement is on. Activating App
   Check in Flutter is not the same as enforcing it in the console. Register debug
   tokens for local development; never distribute those tokens.
4. Keep the Gemini API key managed by Firebase's proxy, not in client code,
   assets, Remote Config, or compile-time definitions. The existing Firebase app
   configuration is still required; its public Firebase API key is not a Gemini
   service credential.
5. Review billing for the actual project and selected model. Firebase AI Logic
   has no separate usage fee, but model calls can be billable. The Gemini
   Developer API free tier depends on project billing status and model eligibility;
   do not assume a Blaze project's low-volume requests are free. Configure
   provider quotas, AI Logic request limits, budget alerts, and available spend
   caps. Budget alerts alone do not stop spending.
6. Keep the app's remote feature disabled until consent, request-size limits,
   timeout handling, and production App Check verification are implemented.
   Registering `FbAiController` and creating a model issue no generation requests.

See [AI Logic setup](https://firebase.google.com/docs/ai-logic/get-started),
[App Check enforcement](https://firebase.google.com/docs/ai-logic/app-check),
[models](https://firebase.google.com/docs/ai-logic/models),
[quotas](https://firebase.google.com/docs/ai-logic/quotas), and
[pricing](https://firebase.google.com/docs/ai-logic/pricing).

### App Check Setup

Debug builds use the SDK debug providers on Android, Apple platforms, and web.
Profile and release builds use Play Integrity, App Attest with DeviceCheck fallback,
and reCAPTCHA Enterprise respectively. Public previews use real attestation.

Before deploying, register all clients under **Firebase Console > Security > App Check > Apps**,
leaving service enforcement disabled:

1. **Android:** link the Play Integrity API to the existing Firebase project and
   register the signing certificate SHA-256 fingerprints, including Play App Signing.
   Configure app recognition, licensing, and device integrity requirements for both
   Play Store and Firebase App Distribution installations. Defaults requiring
   `PLAY_RECOGNIZED` do not suit apps distributed exclusively outside Google Play.
2. **iOS:** register App Attest with the Apple team and bundle ID. Configure DeviceCheck
   credentials as well for the fallback. Enable the App Attest capability in the Apple
   developer account and regenerate development and distribution provisioning profiles,
   including the Ad Hoc profile used by previews. Portrai's Runner entitlement uses
   the `production` App Attest environment for Firebase.
3. **Web:** create a reCAPTCHA Enterprise score-based website key in the same Google
   Cloud project, enable the API, configure permitted production and actual preview
   hostnames, and register that key for the Firebase web app. Review quotas, billing,
   and privacy requirements. Do not authorize `localhost` on a production key;
   use the debug provider for local development.

For Portrai CI, set the repository Actions **variable**
`FIREBASE_APP_CHECK_WEB_SITE_KEY` to the public Enterprise site key. Both preview
and production workflows pass it to the reusable web build. Firebase web builds
fail before compilation if it is missing; the application also rejects missing
keys during non-debug web startup. No web key is needed by native builds.

For local production configuration, put your public Enterprise site key in
the ignored `app/portrai/.env.production` file:

```dotenv
FIREBASE_APP_CHECK_WEB_SITE_KEY=YOUR_PUBLIC_ENTERPRISE_SITE_KEY
```

Keep this file separate from the debug-token `.env`. To build and deploy to
Hosting, run from the workspace root:

```bash
melos run deploy_portrai
```

The script loads the trusted local `.env.production` file automatically if
the site key is not already supplied through the environment. An exported key
takes precedence. The file is sourced as shell configuration; use only simple
assignments and comments, and never source configuration from untrusted sources.
The Melos script requires the public site key before cleaning or building,
passes it to the production release build, and deploys to `hosting:portrai`.
It does not load the debug-token `.env` file.

### Local Development

Run `flutter run` normally in debug mode. On first Firebase access, copy the
SDK-generated App Check debug token from the device log or browser console and
register it under the matching Firebase app's **Manage debug tokens** menu.
The web debug provider sets the SDK debug configuration itself; no edit to
`web/index.html` is required. Restart after registration if requests still fail.

To reuse tokens across reinstalls or devices, copy `app/portrai/.env.example` to
`app/portrai/.env` and enter each platform's registered debug token. The local
`.env` is git-ignored and is not bundled as an asset. Empty values let the SDK
generate a token as usual.

```bash
cd app/portrai
flutter run --dart-define-from-file=.env
```

In Android Studio, add `--dart-define-from-file=.env` to the Flutter run
configuration's additional arguments (relative to the app working directory).
After changing tokens, stop and rerun the app; hot reload does not update
compile-time environment values.

Only use this file for debug runs. Profile/release builds select real providers
even if debug-token values are supplied, but never pass this file to distributed
builds: compile-time definitions are not a secret-storage mechanism.

Debug tokens bypass attestation: do not commit them, log them in shared CI output,
or include them in public artifacts. Give each developer a separate token and
revoke unused tokens. Mocked unit tests and ordinary builds need no registered
token. Trusted live-Firebase integration tests require separately managed debug
tokens; the release workflows do not inject any.

### Enforcement Rollout

Deploy clients with App Check active while enforcement remains off. Verify token
validity and Firebase reads on real devices, App Distribution builds, and production
and preview web hostnames. Monitor valid, invalid, and missing-token traffic before
enforcing **Cloud Firestore**, which serves Portrai's portfolio and app configuration.
Account for older mobile clients and cached web clients; enforcement rejects their
unverified requests too.

Inventory other active Firebase clients before enforcing additional supported
services. Keep Firestore Security Rules and IAM protections: App Check supplements
them and does not protect Hosting pages. Roll back by disabling the affected
service's enforcement in Firebase Console. Do not use Remote Config to gate
activation because it is itself fetched during startup.

See the official [Flutter setup](https://firebase.google.com/docs/app-check/flutter/default-providers),
[Play Integrity settings](https://firebase.google.com/docs/app-check/android/play-integrity-provider),
and [enforcement guide](https://firebase.google.com/docs/app-check/enable-enforcement).

## Usage

### Firebase AI Logic

Inject `FbAiController` from the module's service locator into the app feature's
repository. Create a text model only after Firebase initialization and App Check
activation; do not generate from registration or earlier module hooks.

```dart
import 'package:firebase/firebase.dart';

Future<String> generateAnswer(
  FbAiController controller, {
  required String configuredModelName,
  required String prompt,
}) async {
  final model = controller.createTextModel(
    model: configuredModelName,
    generationConfig: GenerationConfig(
      maxOutputTokens: 1024,
      temperature: 0.2,
    ),
    systemInstruction: 'Answer using the facts supplied by the caller.',
  );
  try {
    return await model.generateText([Content.text(prompt)]);
  } finally {
    model.close();
  }
}
```

For incremental output, use `model.generateTextStream(contents)`, which emits
**deltas**, including whitespace, rather than accumulated text. Commit an answer
only after the stream completes normally. On an error after partial output,
discard that partial answer and show the owning feature's failure state. The
wrapper rejects blocked output, empty/whitespace-only answers, token-limit
truncation, and streams that end without a normal stop reason.

The model owns its HTTP client. Stop active subscriptions and call `close()` when
the owning feature disposes or replaces it. Closing is idempotent; requests on a
closed model fail explicitly. Cancelling a subscription stops local consumption;
neither cancellation nor closing guarantees that backend generation or billing
stops. There are no automatic retries or local/cloud fallbacks.

The caller supplies history explicitly as `Content` items. The Firebase layer
does not keep a chat session, read portfolio data, grant consent, render UI, or
execute generated actions. `GenerationConfig` supports structured text/JSON
settings for a later generative UI feature; that feature must validate the result
and resolve references against authoritative app data.

`AiException` subclasses preserve the cause and stack trace.
`FirebaseAIException.message` details are also retained in the optional `serviceMessage`
for request/configuration/quota/location errors, allowing callers to display actionable
service errors. `toString()` remains generic and sanitized: neither those details nor the
raw cause are printed. SDK parsing messages, HTTP client URI/body details, arbitrary errors,
and blocked/empty/incomplete responses never populate `serviceMessage`.
Concrete SDK
exceptions map to configuration, quota, location, server, or SDK errors; typed
HTTP client and timeout exceptions map to network and timeout errors. Generic
server exceptions remain server errors rather than guessing their meaning from
message text. Unexpected programming errors propagate unchanged. The owning
app use cases should map these exceptions to their domain `Failure` types.

### Firebase Auth

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:module_injector/module_injector.dart';

class AuthService {
  final FirebaseAuth _auth = serviceLocator<FirebaseAuth>();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

### Cloud Firestore

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:module_injector/module_injector.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = serviceLocator<FirebaseFirestore>();

  Future<List<Project>> getProjects() async {
    final snapshot = await _firestore.collection('projects').get();
    return snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList();
  }

  Future<void> addProject(Project project) async {
    await _firestore.collection('projects').doc(project.id).set(project.toJson());
  }

  Stream<List<Project>> projectsStream() {
    return _firestore.collection('projects').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList(),
        );
  }
}
```

### Firebase Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:module_injector/module_injector.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = serviceLocator<FirebaseAnalytics>();

  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(
      name: name,
      value: value,
    );
  }
}
```

### Firebase Crashlytics

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:module_injector/module_injector.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = serviceLocator<FirebaseCrashlytics>();

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
}
```

### Remote Config

```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:module_injector/module_injector.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = serviceLocator<FirebaseRemoteConfig>();

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }

  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  String getString(String key) => _remoteConfig.getString(key);
}
```

### Cloud Storage

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:module_injector/module_injector.dart';

class StorageService {
  final FirebaseStorage _storage = serviceLocator<FirebaseStorage>();

  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }
}
```

### App Check

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> initializeAppCheck() async {
  await FirebaseAppCheck.instance.activate(
    // For debug builds
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
}
```

## Services

This module provides access to the following Firebase services:

| Service | Description |
|---------|-------------|
| **Firebase Core** | Core Firebase SDK initialization |
| **Firebase Auth** | User authentication and management |
| **Cloud Firestore** | NoSQL cloud database |
| **Cloud Functions** | Serverless cloud functions |
| **Firebase Analytics** | User behavior analytics and reporting |
| **Firebase Crashlytics** | Crash reporting and analysis |
| **Remote Config** | Feature flags and remote configuration |
| **Firebase Storage** | Cloud file storage |
| **App Check** | App attestation and security |
| **Firebase AI Logic** | Gemini text generation and streamed responses |

## Best Practices

1. **Initialize Early**: Call `Firebase.initializeApp()` before accessing any Firebase service
2. **Single Instance**: Firebase services are singletons; use the service locator to access them
3. **Error Handling**: Always wrap Firebase operations in try-catch blocks
4. **Offline Support**: Firestore supports offline persistence; enable it for better UX
5. **Security Rules**: Configure proper security rules in Firebase Console
6. **Cost Management**: Monitor usage and set up budget alerts in Firebase Console

## Security

- Store Firebase configuration files securely
- Never commit service account keys to version control
- Use Firebase Security Rules to protect data
- Enable App Check for production apps
- Regularly rotate authentication tokens and API keys

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | Yes |
| iOS      | Yes |
| macOS    | Yes |
| Web      | Yes |

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Core Firebase SDK |
| `firebase_auth` | Authentication |
| `cloud_firestore` | NoSQL database |
| `cloud_functions` | Cloud functions |
| `firebase_analytics` | Analytics |
| `firebase_crashlytics` | Crash reporting |
| `firebase_remote_config` | Remote configuration |
| `firebase_storage` | File storage |
| `firebase_app_check` | App security |
| `firebase_ai` | Firebase AI Logic SDK |
| `http` | Owned AI transport and typed network failures |
| `module_injector` | Dependency injection |
| `core` | Core utilities |

## Testing

```bash
flutter test
```

AI tests use mocked SDK boundaries and a mock HTTP transport with the real SDK
serializer/parser. They require no live project, API key, App Check debug token,
or billable request. A separate trusted live smoke test on configured clients is
required before enabling the remote feature; unit tests do not verify console
enforcement, model availability, or billing settings.

For testing Firebase functionality, use mocking or Firebase Emulator Suite:

```dart
// Example with mocking
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
```

Part of the Port-Rai modular architecture.
