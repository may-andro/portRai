# Firebase Module

A comprehensive Firebase integration layer for Flutter applications, providing centralized access to all Firebase services with proper initialization and configuration.

## Features

- **Complete Firebase Suite**: Integration with all major Firebase services
- **Centralized Configuration**: Single initialization point for all Firebase services
- **Type-Safe Access**: Strongly typed service instances
- **Dependency Injection**: Seamless integration with the module injector system
- **Cross-Platform**: Support for Android, iOS, macOS, and Web platforms

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

## Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```dart
import 'package:firebase/firebase.dart';
```

> **Note**: As a workspace module, `firebase` is automatically available to all other modules without manual dependency configuration.

### Configuration

1. **Add Firebase configuration files**:
   - **Android**: `android/app/google-services.json`
   - **iOS**: `ios/Runner/GoogleService-Info.plist`
   - **macOS**: `macos/Runner/GoogleService-Info.plist`
   - **Web**: Update `web/index.html` with Firebase config

2. **Initialize Firebase** in your app's main entry point:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase/firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure Firebase module (registers all services with DI)
  final configurator = FirebaseModuleConfigurator();
  await configurator.configure();
  
  runApp(MyApp());
}
```

## Usage

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
    return snapshot.docs
        .map((doc) => Project.fromJson(doc.data()))
        .toList();
  }
  
  Future<void> addProject(Project project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .set(project.toJson());
  }
  
  Stream<List<Project>> projectsStream() {
    return _firestore
        .collection('projects')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromJson(doc.data()))
            .toList());
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
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
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

## Module Configuration

The Firebase module automatically configures all Firebase services for dependency injection:

```dart
import 'package:firebase/firebase.dart';
import 'package:module_injector/module_injector.dart';

// In your app initialization
final configurator = FirebaseModuleConfigurator();
await configurator.configure();

// All services are now available via service locator
final auth = serviceLocator<FirebaseAuth>();
final firestore = serviceLocator<FirebaseFirestore>();
final analytics = serviceLocator<FirebaseAnalytics>();
// ... etc
```

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅ |
| iOS      | ✅ |
| macOS    | ✅ |
| Web      | ✅ |

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
| `module_injector` | Dependency injection |
| `core` | Core utilities |

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

## Testing

```bash
flutter test
```

For testing Firebase functionality, use mocking or Firebase Emulator Suite:

```dart
// Example with mocking
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
```

---

Part of the Port-Rai modular architecture.
