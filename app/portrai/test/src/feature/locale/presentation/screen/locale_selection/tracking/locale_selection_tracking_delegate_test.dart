import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
    registerFallbackValue(
      Tracking(
        name: 'fallback',
        action: const ClickAction(label: 'fallback'),
      ),
    );
  });

  group('LocaleSelectionTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late LocaleSelectionTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = LocaleSelectionTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a screen view event when the screen becomes visible', () {
      delegate.trackVisibleScreen(false);

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.parameters['event'], 'screen_view');
      expect(tracking.parameters['area'], 'locale_selection_screen');
    });

    test(
      'should send a popup view impression when the dialog becomes visible',
      () {
        delegate.trackVisibleScreen(true);

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.parameters['event'], 'view_impression');
        expect(tracking.parameters['label'], 'locale_selection_popup');
      },
    );

    test(
      'should send a locale selection click event when a locale is tapped',
      () {
        delegate.trackLocaleSelectionClick('nl');

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.name, 'selected_locale');
        expect(tracking.parameters['label'], 'nl');
      },
    );

    test('should send a language update event when the locale changes', () {
      delegate.trackLanguageUpdate(previousLanguage: 'en', newLanguage: 'es');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'language_update');
      expect(tracking.parameters['previous_language'], 'en');
      expect(tracking.parameters['new_language'], 'es');
    });
  });
}
