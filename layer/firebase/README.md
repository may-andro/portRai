# Firebase

Initializes Firebase, activates App Check, and registers Firebase SDK instances and wrapper controllers in the module injector. The controllers validate input and map SDK errors to typed exceptions that implement `AppException` from [core](../core/README.md).

## Features

- `FirebaseModuleConfigurator` that initializes Firebase, activates App Check before other services, and registers every service below
- App Check with debug providers in debug builds and Play Integrity, App Attest with DeviceCheck fallback, or reCAPTCHA Enterprise otherwise
- `FbAuthController`: email and password accounts, sign-in, password reset
- `FbFirestoreController`: collection queries, document reads and writes, merges and batch updates
- `FbFunctionController`: callable functions, for signed-in users or for anyone, optionally with a limited-use App Check token
- `FbStorageController`: upload, download and delete files in Cloud Storage
- `FbRemoteConfigController`, `FbAnalyticsController`, `FbCrashlyticsController`
- `FbMessagingController`: notification permission, device tokens, topics, foreground and opened messages
- `FbAiController`: Firebase AI Logic text models (single response or streamed) and single-image models

## Getting Started

### Installation

Add the workspace package as a dependency:

```yaml
dependencies:
  firebase: any
```

```dart
import 'package:firebase/firebase.dart';
```

The barrel also re-exports `cloud_firestore`, `firebase_analytics`, `firebase_core`, `firebase_remote_config`, `User` from `firebase_auth`, and these `firebase_ai` types: `Content`, `GenerationConfig`, `HarmBlockMethod`, `HarmBlockThreshold`, `HarmCategory`, `InlineDataPart`, `SafetySetting`, `Schema`, `TextPart`, `ThinkingConfig`, `ThinkingLevel`.

### Module Configuration

The app supplies the platform configuration files (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`) and the FlutterFire-generated `DefaultFirebaseOptions`. Add the configurator to the list passed to `ModuleInjectorController.setUpDIGraph`:

```dart
FirebaseModuleConfigurator(
  isFirebaseEnabled: buildConfig.buildEnvironment.isFirebaseEnabled,
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  appCheckWebSiteKey: const String.fromEnvironment(
    'FIREBASE_APP_CHECK_WEB_SITE_KEY',
  ),
  storageBucketUrl: '',
)
```

| Parameter | Default | Purpose |
| --- | --- | --- |
| `isFirebaseEnabled` | required | Enables Analytics and Crashlytics collection |
| `firebaseOptions` | required | Passed to `Firebase.initializeApp` |
| `appCheckWebSiteKey` | required | reCAPTCHA Enterprise site key for web profile and release builds |
| `storageBucketUrl` | required | Bucket URL that `FbStorageController` uploads to and deletes from |
| `aiBackend` | `FbAiBackend.googleAI` | `googleAI` (Gemini Developer API) or `agentPlatform` |
| `aiLocation` | `'global'` | Location for `FbAiBackend.agentPlatform`; ignored by `googleAI` |
| `aiUseLimitedUseAppCheckTokens` | `true` | Sends a fresh limited-use App Check token with every AI request |

Setup order:

1. `preDependenciesSetup` calls `Firebase.initializeApp`.
2. `registerDependencies` registers the SDK instances (`FirebaseAppCheck`, `FirebaseAuth`, `FirebaseCrashlytics`, `FirebaseRemoteConfig`, `FirebaseAnalytics`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseFunctions`, `FirebaseMessaging`, `FirebaseAI`) as singletons, and `FirebaseAnalyticsObserver` and the `Fb*Controller` classes as factories.
3. `postDependenciesSetup` activates App Check and waits for it, then enables Crashlytics collection and logs `App Started`, initializes Remote Config with empty defaults, and enables Analytics collection.

Dependency registration and module hooks that run before this `postDependenciesSetup` must not issue App Check protected Firebase requests. Do not initialize Firebase separately in an Apple `AppDelegate`, as this can bypass provider selection.

`isFirebaseEnabled` controls Analytics and Crashlytics collection only. It does not affect Firebase initialization, App Check activation, or AI requests; callers decide when to send AI requests.

With `aiUseLimitedUseAppCheckTokens` on, every AI request carries a fresh limited-use token instead of the cached one. Each request therefore costs one attestation (Play Integrity, App Attest or reCAPTCHA Enterprise call), which counts against those providers' quotas. The backend rejects missing or replayed tokens only once App Check enforcement is on for Firebase AI Logic.

### Firebase AI Logic Setup

1. Open **Firebase Console > Firebase AI Logic** in the Firebase project and complete the guided setup for the chosen Gemini API provider, which enables the required APIs. The default backend is the **Gemini Developer API** (`FbAiBackend.googleAI`). For the Agent Platform Gemini API (formerly Vertex AI), set `aiBackend: FbAiBackend.agentPlatform` and an `aiLocation`. Changing that location does not relocate other Firebase services.
2. Choose a model for that provider and pass its name to `createTextModel` or `createImageModel`. The layer does not hardcode a model or prompt. Check model availability, supported settings, quotas, pricing and regional support in the provider documentation.
3. Register the production attestation providers as described in [App Check Setup](#app-check-setup) and verify **App Check > APIs > Firebase AI Logic** is **Enforced** before exposing AI requests to public clients. New AI Logic setups may enable enforcement automatically; verify existing projects. Activating App Check in Flutter is not the same as enforcing it in the console. Register debug tokens for local development and never distribute them.
4. Keep the Gemini API key managed by Firebase's proxy, not in client code, assets, Remote Config or compile-time definitions. The Firebase app configuration is still required; its public Firebase API key is not a Gemini credential.
5. Review billing for the project and selected model. Firebase AI Logic has no separate usage fee, but model calls can be billable. The Gemini Developer API free tier depends on project billing status and model eligibility. Configure provider quotas, AI Logic request limits, budget alerts and available spend caps; budget alerts alone do not stop spending.
6. Registering `FbAiController` and creating a model send no generation requests.

See [AI Logic setup](https://firebase.google.com/docs/ai-logic/get-started),
[App Check enforcement](https://firebase.google.com/docs/ai-logic/app-check),
[models](https://firebase.google.com/docs/ai-logic/models),
[quotas](https://firebase.google.com/docs/ai-logic/quotas), and
[pricing](https://firebase.google.com/docs/ai-logic/pricing).

### App Check Setup

The internal `FbAppCheckController.initialiseAppCheck` selects providers with `useDebugProviders`, which defaults to `kDebugMode`:

| Platform | Debug builds | Profile and release builds |
| --- | --- | --- |
| Android | `AndroidDebugProvider` | `AndroidPlayIntegrityProvider` |
| iOS, macOS | `AppleDebugProvider` | `AppleAppAttestWithDeviceCheckFallbackProvider` |
| Web | `WebDebugProvider` | `ReCaptchaEnterpriseProvider(appCheckWebSiteKey)` |

Token auto-refresh is enabled after activation. On web profile and release builds an empty `appCheckWebSiteKey` throws. Activation failures are rethrown as `AppCheckException`. Native builds need no web key.

Before deploying, register all clients under **Firebase Console > Security > App Check > Apps**, leaving service enforcement disabled:

1. **Android:** link the Play Integrity API to the Firebase project and register the signing certificate SHA-256 fingerprints, including Play App Signing. Configure app recognition, licensing and device integrity requirements for both Play Store and Firebase App Distribution installations. Defaults requiring `PLAY_RECOGNIZED` do not suit apps distributed only outside Google Play.
2. **iOS:** register App Attest with the Apple team and bundle ID, and DeviceCheck credentials for the fallback. Enable the App Attest capability in the Apple developer account and regenerate the development, distribution and Ad Hoc provisioning profiles. Set the App Attest environment in the Runner entitlements.
3. **Web:** create a reCAPTCHA Enterprise score-based website key in the same Google Cloud project, enable the API, list the permitted production and preview hostnames, and register that key for the Firebase web app. Review quotas, billing and privacy requirements. Do not authorize `localhost` on a production key; use the debug provider for local development.

Pass the public site key to web builds as the `FIREBASE_APP_CHECK_WEB_SITE_KEY` compile-time define, as in the configurator example above.

### Local Development

Run the app in debug mode. On first Firebase access, copy the SDK-generated App Check debug token from the device log or browser console and register it under the matching Firebase app's **Manage debug tokens** menu. The web debug provider sets the SDK debug configuration itself; no edit to `web/index.html` is required. Restart after registration if requests still fail.

To reuse tokens across reinstalls or devices, pass registered debug tokens as compile-time defines. Empty values let the SDK generate a token.

| Define | Platform |
| --- | --- |
| `FIREBASE_APP_CHECK_ANDROID_DEBUG_TOKEN` | Android |
| `FIREBASE_APP_CHECK_APPLE_DEBUG_TOKEN` | iOS, macOS |
| `FIREBASE_APP_CHECK_WEB_DEBUG_TOKEN` | Web |

Keep them in a git-ignored file and pass it at run time:

```bash
flutter run --dart-define-from-file=.env
```

After changing tokens, stop and rerun the app; hot reload does not update compile-time values. Profile and release builds use real providers even if debug tokens are supplied, but never pass the file to distributed builds: compile-time definitions are not secret storage.

Debug tokens bypass attestation: do not commit them, log them in shared CI output, or include them in public artifacts. Give each developer a separate token and revoke unused ones. Unit tests with mocks need no registered token.

### Enforcement Rollout

Deploy clients with App Check active while enforcement remains off. Verify token validity and Firebase reads on real devices, App Distribution builds, and production and preview web hostnames. Monitor valid, invalid and missing-token traffic before enforcing a service such as **Cloud Firestore**. Account for older mobile clients and cached web clients; enforcement rejects their unverified requests too.

Inventory other active Firebase clients before enforcing additional services. Keep Firestore Security Rules and IAM protections: App Check supplements them and does not protect Hosting pages. Roll back by disabling the affected service's enforcement in Firebase Console. Do not use Remote Config to gate activation, because it is itself fetched during startup.

See the official [Flutter setup](https://firebase.google.com/docs/app-check/flutter/default-providers),
[Play Integrity settings](https://firebase.google.com/docs/app-check/android/play-integrity-provider),
and [enforcement guide](https://firebase.google.com/docs/app-check/enable-enforcement).

## Usage

Resolve controllers from the `ServiceLocator` in another module's `registerDependencies`:

```dart
serviceLocator.registerFactory<ItemRepository>(
  () => ItemRepositoryImpl(serviceLocator.get<FbFirestoreController>()),
);
```

### Firebase AI Logic

Create a model only after App Check activation, not from dependency registration.

```dart
Future<String> generateAnswer(
  FbAiController controller, {
  required String modelName,
  required String prompt,
}) async {
  final model = controller.createTextModel(
    model: modelName,
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

`createTextModel` throws `AiInvalidInputException` for an empty model name, a missing or non-positive `maxOutputTokens`, or a `candidateCount` other than 1.

`generateTextStream(contents)` emits text deltas, including whitespace, not accumulated text. Treat the answer as complete only when the stream completes normally; on an error after partial output, discard the partial text. Both methods reject empty prompts, blocked output, empty or whitespace-only answers, and responses that end without a `stop` finish reason (including token-limit truncation).

`createImageModel(model:, systemInstruction:, safetySettings:)` returns an `FbAiImageModel` that requests one candidate with text and image modalities. `generateImage(contents)` returns the first image part as an `FbAiImage` with `bytes` and `mimeType`. It rejects empty prompts, blocked responses, finish reasons other than `stop`, and responses without image data.

Each model owns its HTTP client. Cancel active subscriptions and call `close()` when the model is no longer needed. `close()` is idempotent and later requests throw `StateError`. Neither cancelling a subscription nor closing stops backend generation or billing. There are no automatic retries.

Models keep no chat history: pass prior turns as `Content` items.

Errors are thrown as `AiException` subclasses, which keep the `cause` and `stackTrace`:

| SDK error | Exception |
| --- | --- |
| `InvalidApiKey`, `ServiceApiNotEnabled` | `AiConfigurationException` |
| `QuotaExceeded` | `AiQuotaExceededException` |
| `UnsupportedUserLocation` | `AiUnsupportedLocationException` |
| other `FirebaseAIException` | `AiServerException` |
| `FirebaseAISdkException` | `AiSdkException` |
| `http` `ClientException` | `AiNetworkException` |
| `TimeoutException` | `AiTimeoutException` |

`AiInvalidInputException`, `AiBlockedResponseException`, `AiEmptyResponseException` and `AiIncompleteResponseException` come from the layer's own checks. For `FirebaseAIException`-based errors, `serviceMessage` holds the SDK's `message` for display; it is null for every other error. `toString()` prints only the generic `message`, never `serviceMessage` or the cause. Other error types propagate unchanged.

### Firebase Auth

`FbAuthController` exposes `currentUser`, `isSignedIn`, `authStateChanges`, `createAccount`, `signIn`, `signOut`, `deleteAccount`, `updatePassword`, `resetPassword`, `confirmPasswordReset`, `verifyPasswordResetCode`, and the static `extractResetCodeFromUrl`. Failures are thrown as `AuthException` subclasses, whose `message` is user-readable.

```dart
Future<String?> signInAndGetUserId(
  FbAuthController controller, {
  required String email,
  required String password,
}) async {
  await controller.signIn(email: email, password: password);
  // The first event is the restored session; `currentUser` can still be null
  // right after app start.
  final User? user = await controller.authStateChanges.first;
  return user?.uid;
}
```

### Cloud Firestore

`FbFirestoreController` throws `ArgumentError` (wrapped as a `FirestoreException`) for empty paths or data, and `FirestoreException` subclasses for SDK errors. Collection paths may point at subcollections, such as `parents/{parentId}/children`.

- `getCollectionQuerySnapshot(path, documentIdField: 'id')` adds each document's ID to its map under the given key. It also accepts one `field` with `isEqualTo`, `isLessThan`, `isGreaterThan`, `isGreaterThanOrEqualTo` or `isNotEqualTo` filters, plus `orderBy`, `descending`, `limit` and `startAfterDocumentId`.
- `getDocumentFromCollection` throws `FirestoreDocumentNotFoundException` when the document is missing.
- `addToCollection` adds a document with a generated ID. `addDocumentToCollection` replaces the whole document. `mergeDocumentInCollection` creates the document or merges fields into it, keeping fields that are not written, nested maps included.
- `updateDocumentFromCollection`, `deleteDocumentFromCollection` and `batchUpdateDocuments` throw `FirestoreDocumentNotFoundException` if a target document does not exist. Each `batchUpdateDocuments` entry is `{'documentPath': String, 'data': Map<String, dynamic>}`.

```dart
Future<List<Map<String, dynamic>>> getChildren(
  FbFirestoreController controller, {
  required String parentId,
}) => controller.getCollectionQuerySnapshot(
  'parents/$parentId/children',
  documentIdField: 'id',
);

Future<void> setPreference(
  FbFirestoreController controller, {
  required String documentId,
  required bool enabled,
}) => controller.mergeDocumentInCollection(
  collectionPath: 'preferences',
  documentPath: documentId,
  data: {
    'settings': {
      'enabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    },
  },
);
```

### Cloud Functions

`FbFunctionController.callFunction(name, parameters: {...})` calls an HTTPS callable function in the `europe-west3` region and returns its `data`. It throws `FunctionAuthenticationException` when no user is signed in, `FunctionEmptyResponseException` when the function returns null, and other `FunctionException` subclasses mapped from `FirebaseFunctionsException.code`.

```dart
Future<dynamic> runTask(FbFunctionController controller, String itemId) =>
    controller.callFunction('runTask', parameters: {'itemId': itemId});
```

Two options change how a call is made:

| Option | Default | Effect |
| --- | --- | --- |
| `requiresSignIn` | `true` | With `false`, the call goes ahead without a signed-in user. The function must then check its caller itself, for example by enforcing App Check |
| `limitedUseAppCheckToken` | `false` | Sends a fresh limited-use App Check token instead of the cached one, so a function that consumes its token can reject a replayed call. Each call costs one attestation |

```dart
Future<dynamic> listItems(FbFunctionController controller) =>
    controller.callFunction(
      'listItems',
      requiresSignIn: false,
      limitedUseAppCheckToken: true,
    );
```

Every `FunctionException` has a `details` getter with the details the function sent with its error, such as a map saying why it refused the call, or null when there are none.

App Check tokens reach a function only after `postDependenciesSetup` has activated App Check. A function rejects calls without a valid token only when it enforces App Check itself (`enforceAppCheck` in the Cloud Functions SDK); the console's App Check enforcement settings do not cover callable functions.

### Cloud Storage

`FbStorageController` methods return the download URL after upload and throw `FireStorageException` subclasses on failure.

- `uploadRawDocument(fileName, Uint8List data)`, `uploadStringUrlDocument(fileName, dataUrl)` and `uploadFileDocument(fileName, File file)` upload under `storageBucketUrl`.
- `deleteFileDocument(fileName)` deletes under `storageBucketUrl`.
- `downloadFileDocument(fileName:, storageFolder:)` writes `storageFolder/fileName` to the app documents directory and returns the `File`. It throws `StorageDownloadErrorException` on web.

### Remote Config

`postDependenciesSetup` already calls `initialiseRemoteConfig(defaultConfigsMap: const {})`, with a 5 second fetch timeout and a 12 hour minimum fetch interval. On the first launch it waits for `fetchAndActivate`; afterwards it activates the values fetched earlier and fetches in the background, so new values apply on the next launch.

```dart
final controller = serviceLocator.get<FbRemoteConfigController>();
final bool isEnabled = controller.getValueForKey('enabled_key').asBool();
final Map<String, RemoteConfigValue> all = controller.getAllConfigsValue();
```

### Analytics and Crashlytics

```dart
final analytics = serviceLocator.get<FbAnalyticsController>();
await analytics.sendLogEvent('item_opened', parameters: {'id': 'item-1'});
await analytics.sendUserEvent('user-1', additionalProps: {'plan': 'free'});

final crashlytics = serviceLocator.get<FbCrashlyticsController>();
await crashlytics.logMessage('Item opened');
try {
  await openItem();
} catch (error, stackTrace) {
  await crashlytics.reportError(error, stackTrace);
}
```

`FbCrashlyticsController` also provides `isCrashlyticsEnabled`, `setCrashlyticsEnabled`, `setUser`, `reportFlutterError` and `forceCrash`. Its calls do nothing unless the platform is Android or iOS and collection is enabled.

### Cloud Messaging

`FbMessagingController` throws `MessagingException` subclasses (`MessagingPermissionException`, `MessagingTokenException`, `MessagingTopicException`) that keep the original cause and stack trace.

```dart
final messaging = serviceLocator.get<FbMessagingController>();

if (await messaging.requestPermission()) {
  final token = await messaging.getToken();
  await messaging.subscribeToTopic('updates');
}

// The system does not display notifications while the app is in the foreground.
messaging.foregroundMessages.listen((message) => showBanner(message.title));

// A notification tapped while the app was in the background.
messaging.openedMessages.listen((message) => openRoute(message.data['route']));

// The notification that opened the app from a terminated state, if any.
final FbPushMessage? initialMessage = await messaging.getInitialMessage();
```

- Messages arrive as `FbPushMessage` with the notification's `title` and `body`, and its `data` as `Map<String, String>`.
- `requestPermission` and `isPermissionGranted` return true for authorized and provisional permission.
- On iOS and macOS, `getToken` first waits for the APNs token, checking `apnsTokenAttempts` times (default 5) every `apnsTokenRetryDelay` (default 1 second), and throws `MessagingTokenException` if none arrives.
- `onTokenRefresh` emits new tokens; `deleteToken` invalidates the current one.

iOS needs an APNs key uploaded to the Firebase project and the Push Notifications capability. Android 13 and later needs the `POST_NOTIFICATIONS` permission declared in the app manifest; `requestPermission` asks the user for it.

## Platform Support

Platform-specific behavior in this layer:

| Area | Behavior |
| --- | --- |
| App Check | Providers per platform as listed in [App Check Setup](#app-check-setup); web release builds require `appCheckWebSiteKey` |
| Crashlytics | Android and iOS only; other platforms are no-ops and `isCrashlyticsEnabled` is false |
| Messaging | `getToken` waits for the APNs token on iOS and macOS; topics are not supported on web |
| Storage | `downloadFileDocument` is not supported on web |

## Dependencies

| Package | Purpose |
| --- | --- |
| `firebase_core` | Firebase initialization |
| `firebase_app_check` | App Check providers |
| `firebase_auth` | `FbAuthController` |
| `cloud_firestore` | `FbFirestoreController` |
| `cloud_functions` | `FbFunctionController` |
| `firebase_storage` | `FbStorageController` |
| `path_provider` | Download location for `downloadFileDocument` |
| `firebase_remote_config` | `FbRemoteConfigController` |
| `firebase_analytics` | `FbAnalyticsController`, `FirebaseAnalyticsObserver` |
| `firebase_crashlytics` | `FbCrashlyticsController` |
| `firebase_messaging` | `FbMessagingController` |
| `firebase_ai` | `FbAiController` and models |
| `http` | HTTP client owned by each AI model; `ClientException` mapping |
| `equatable` | Value equality for `FbPushMessage` |
| `core` | `AppException` base type |
| `module_injector` | `ModuleConfigurator` and `ServiceLocator` |

## Testing

```bash
melos run test --scope=firebase
```

Or from `layer/firebase`:

```bash
flutter test
```

Tests use `mocktail` mocks of the SDK classes and `fake_cloud_firestore` for Firestore. AI tests run the real `firebase_ai` request and response handling against an `http` `MockClient`, so they need no Firebase project, API key, App Check debug token or billable request. They do not verify console enforcement, model availability or billing settings. The layer exports no test helpers.
