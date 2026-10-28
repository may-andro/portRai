import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `call_booking` feature.
abstract final class CallBookingFeatureFlags {
  static const callBooking = AppFeatureFlagDefinition(
    key: 'feature_call_booking',
    defaultValue: false,
    displayName: 'Call Booking',
    description:
        'Shows Book a Call buttons, which let visitors pick a free time and '
        'request a call with the owner',
  );

  static const all = [callBooking];
}
