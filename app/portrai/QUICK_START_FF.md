# Feature Flags - Quick Start

## 🚀 Running the App

The feature flag behavior depends on which environment you run:

### Option 1: VS Code / Android Studio
Select from the dropdown:
- **portrai (staging)** ← Use this for testing feature flags
- **portrai (prod)** ← Production mode

### Option 2: Command Line

**Staging** (feature flags can be toggled & persist):
```bash
flutter run --dart-define=build_env=staging --flavor staging
```

**Production** (feature flags are read-only from Firebase):
```bash
flutter run --dart-define=build_env=prod --flavor prod
```

## ✅ Testing Feature Flag Persistence

1. Run staging build: `flutter run --dart-define=build_env=staging --flavor staging`
2. Go to Developer Menu → Feature Flags
3. Toggle any flag (e.g., "Dark Mode")
4. **Kill the app completely**
5. Restart the app
6. Go back to Feature Flags screen
7. ✅ Your toggle should still be there!

## 📱 What Happens in Each Environment

### Staging Build
- ✅ Can toggle flags via UI
- ✅ Toggles persist in local DB
- ✅ Survives app restarts and rebuilds
- ✅ "Reset All" button clears overrides
- 📦 App ID: `com.mayandro.portrai.staging`

### Production Build  
- ❌ Cannot toggle flags (remote only)
- ❌ No caching or persistence
- ✅ Always uses Firebase Remote Config values
- 📦 App ID: `com.mayandro.portrai`

## 🔧 Build APKs

**Staging APK:**
```bash
flutter build apk --dart-define=build_env=staging --flavor staging --release
```

**Production APK:**
```bash
flutter build apk --dart-define=build_env=prod --flavor prod --release
```

## ⚠️ Important Notes

1. **Must use `--dart-define=build_env=staging`** for caching to work
2. Both flavors can be installed side-by-side for testing
3. Cache persists across rebuilds (stored in SQLite DB)
4. Production builds are read-only (no toggle functionality)

## 📚 Full Documentation

See [FEATURE_FLAGS.md](./FEATURE_FLAGS.md) for complete architecture details.
