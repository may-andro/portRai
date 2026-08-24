# Tracking Module

A comprehensive analytics and event tracking solution for Flutter applications with automatic screen tracking, custom event logging, and Firebase Analytics integration.

## Features

- **Screen Tracking**: Automatic screen view tracking with visibility detection
- **Custom Event Tracking**: Flexible event tracking with custom parameters
- **Firebase Analytics Integration**: Built-in Firebase Analytics support
- **Type-Safe Events**: JSON-serializable event models for consistent tracking
- **Dependency Injection**: Seamless integration with the module injection system
- **Automatic Tracking**: Widget-based automatic screen tracking
- **Cross-Platform**: Works on Android, iOS, macOS, and Web platforms

## Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```dart
import 'package:tracking/tracking.dart';
```

> **Note**: As a workspace module, `tracking` is automatically available to all other modules without manual dependency configuration.

## Usage

### Module Configuration

Configure the tracking module in your application:

```dart
import 'package:tracking/tracking.dart';

// Add to your module configurators
final configurator = TrackingModuleConfigurator();
```

### Basic Event Tracking

```dart
import 'package:tracking/tracking.dart';
import 'package:module_injector/module_injector.dart';

class UserService {
  final EventTracker _tracker = serviceLocator<EventTracker>();
  
  Future<void> login(String userId) async {
    // Perform login
    await performLogin(userId);
    
    // Track login event
    await _tracker.track(
      LoginEvent(
        userId: userId,
        method: 'email',
        timestamp: DateTime.now(),
      ),
    );
  }
  
  Future<void> purchaseItem(String itemId, double price) async {
    // Process purchase
    await processPurchase(itemId);
    
    // Track purchase event
    await _tracker.track(
      PurchaseEvent(
        itemId: itemId,
        price: price,
        currency: 'USD',
        timestamp: DateTime.now(),
      ),
    );
  }
}
```

### Automatic Screen Tracking

Use the `ScreenTrackerWidget` to automatically track screen views:

```dart
import 'package:tracking/tracking.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenTrackerWidget(
      screenName: 'profile_screen',
      additionalParams: {
        'user_id': currentUserId,
        'tab': 'overview',
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: ProfileContent(),
      ),
    );
  }
}
```

The `ScreenTrackerWidget` uses `VisibilityDetector` to automatically track when the screen becomes visible and logs the screen view event.

### Custom Events

Define custom event classes with JSON serialization:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'custom_events.g.dart';

@JsonSerializable()
class ButtonTapEvent {
  ButtonTapEvent({
    required this.buttonId,
    required this.screenName,
    this.additionalData,
  });

  final String buttonId;
  final String screenName;
  final Map<String, dynamic>? additionalData;

  factory ButtonTapEvent.fromJson(Map<String, dynamic> json) =>
      _$ButtonTapEventFromJson(json);
  
  Map<String, dynamic> toJson() => _$ButtonTapEventToJson(this);
}

@JsonSerializable()
class SearchEvent {
  SearchEvent({
    required this.query,
    required this.resultsCount,
    required this.timestamp,
  });

  final String query;
  final int resultsCount;
  final DateTime timestamp;

  factory SearchEvent.fromJson(Map<String, dynamic> json) =>
      _$SearchEventFromJson(json);
  
  Map<String, dynamic> toJson() => _$SearchEventToJson(this);
}
```

Track custom events:

```dart
// Track button tap
await _tracker.track(
  ButtonTapEvent(
    buttonId: 'submit_button',
    screenName: 'profile_screen',
    additionalData: {'form_valid': true},
  ),
);

// Track search
await _tracker.track(
  SearchEvent(
    query: 'flutter development',
    resultsCount: 42,
    timestamp: DateTime.now(),
  ),
);
```

### User Properties

Set user properties for analytics segmentation:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = serviceLocator<FirebaseAnalytics>();
  
  Future<void> setUserProperties({
    required String userId,
    required String userType,
    String? subscriptionTier,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(
      name: 'user_type',
      value: userType,
    );
    if (subscriptionTier != null) {
      await _analytics.setUserProperty(
        name: 'subscription_tier',
        value: subscriptionTier,
      );
    }
  }
}
```

## Key Components

### EventTracker

Abstract interface for event tracking:

```dart
abstract class EventTracker {
  /// Track a custom event
  Future<void> track(dynamic event);
  
  /// Track a screen view
  Future<void> trackScreen(String screenName, {Map<String, dynamic>? params});
}
```

### ScreenTrackerWidget

Widget that automatically tracks screen views using visibility detection:

```dart
ScreenTrackerWidget({
  required String screenName,
  Map<String, dynamic>? additionalParams,
  required Widget child,
})
```

**Parameters:**
- `screenName`: Unique identifier for the screen
- `additionalParams`: Optional parameters to include with screen view event
- `child`: The screen content widget

### Firebase Analytics Integration

The module automatically integrates with Firebase Analytics when configured:

```dart
// Get Firebase Analytics instance
final analytics = serviceLocator<FirebaseAnalytics>();

// Log custom events directly
await analytics.logEvent(
  name: 'custom_event',
  parameters: {
    'param1': 'value1',
    'param2': 42,
  },
);
```

## Common Event Types

### User Events

```dart
// User signup
await _tracker.track(SignupEvent(
  method: 'google',
  timestamp: DateTime.now(),
));

// User login
await _tracker.track(LoginEvent(
  userId: user.id,
  method: 'email',
  timestamp: DateTime.now(),
));
```

### Navigation Events

```dart
// Screen view (automatic with ScreenTrackerWidget)
await _tracker.trackScreen('home_screen', params: {
  'referrer': 'splash_screen',
});

// Tab switch
await _tracker.track(TabSwitchEvent(
  fromTab: 'home',
  toTab: 'profile',
  timestamp: DateTime.now(),
));
```

### User Interaction Events

```dart
// Button tap
await _tracker.track(ButtonTapEvent(
  buttonId: 'subscribe_button',
  screenName: 'subscription_screen',
));

// Content view
await _tracker.track(ContentViewEvent(
  contentType: 'article',
  contentId: '12345',
  title: 'Flutter Best Practices',
));
```

### E-commerce Events

```dart
// Product view
await _tracker.track(ProductViewEvent(
  productId: 'SKU123',
  productName: 'Premium Plan',
  price: 9.99,
));

// Add to cart
await _tracker.track(AddToCartEvent(
  productId: 'SKU123',
  quantity: 1,
  price: 9.99,
));

// Purchase
await _tracker.track(PurchaseEvent(
  transactionId: 'TXN789',
  value: 9.99,
  currency: 'USD',
  items: ['SKU123'],
));
```

## Platform Support

| Platform | Event Tracking | Screen Tracking | Firebase Analytics |
|----------|----------------|-----------------|-------------------|
| Android  | ✅             | ✅              | ✅                |
| iOS      | ✅             | ✅              | ✅                |
| macOS    | ✅             | ✅              | ✅                |
| Web      | ✅             | ✅              | ✅                |

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase` | Firebase Analytics integration |
| `visibility_detector` | Automatic screen view tracking |
| `json_annotation` | JSON serialization for events |
| `module_injector` | Dependency injection |

## Best Practices

1. **Event Naming**:
   - Use descriptive, consistent names (e.g., `user_signup`, `product_view`)
   - Use snake_case for event names and parameters
   - Keep names under 40 characters for Firebase compatibility

2. **Event Parameters**:
   - Limit to 25 custom parameters per event
   - Use consistent parameter names across events
   - Include timestamp for time-based analysis

3. **Screen Tracking**:
   - Use unique, descriptive screen names
   - Include relevant context in `additionalParams`
   - Track screen transitions consistently

4. **User Privacy**:
   - Never track personally identifiable information (PII)
   - Anonymize or hash sensitive data
   - Respect user privacy preferences and consent

5. **Testing**:
   - Test tracking in debug mode before production
   - Verify events appear in Firebase Analytics DebugView
   - Mock the `EventTracker` in unit tests

6. **Performance**:
   - Batch events when possible
   - Avoid tracking in performance-critical code paths
   - Use `VisibilityDetector` for automatic tracking to reduce manual calls

## Testing

```bash
flutter test
```

### Mock Event Tracker for Testing

```dart
import 'package:tracking/tracking.dart';
import 'package:mocktail/mocktail.dart';

class MockEventTracker extends Mock implements EventTracker {}

void main() {
  late MockEventTracker mockTracker;
  late MyService service;

  setUp(() {
    mockTracker = MockEventTracker();
    service = MyService(mockTracker);
  });

  test('should track login event on successful login', () async {
    when(() => mockTracker.track(any())).thenAnswer((_) async => {});
    
    await service.login('user123');
    
    verify(() => mockTracker.track(any<LoginEvent>())).called(1);
  });
}
```

## Debugging

### Firebase Analytics DebugView

Enable debug mode to see events in real-time:

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app <package_name>
```

**iOS:**
```bash
# Add to Xcode scheme: -FIRAnalyticsDebugEnabled
```

**Web:**
```dart
// Enable analytics debug mode in main.dart
FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
```

### Logging Events

All tracked events are automatically logged in debug mode for verification.

---

Part of the Port-Rai modular architecture.
