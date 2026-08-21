import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('locale_selection_screen');
}

@register
class LocaleSelectionTrackingDelegate extends TrackingDelegate {
  LocaleSelectionTrackingDelegate(super.trackingReporter);

  final TrackingArea _area = const _TrackingArea();

  void trackScreenView(bool isDialog) {
    if (isDialog) {
      trackEvent(ViewTracking(label: 'locale_selection_popup'));
      return;
    }

    trackEvent(ScreenViewTracking(area: _area));
  }

  void trackViewEvent(String label) {
    trackEvent(ViewTracking(label: label));
  }

  void trackLocaleSelectionClick(String localeCode) {
    trackEvent(ClickTracking(label: 'selected_locale', value: localeCode));
  }

  void trackLanguageUpdate({
    required String previousLanguage,
    required String newLanguage,
  }) {
    trackEvent(
      LanguageUpdateTracking(
        previousLanguage: previousLanguage,
        newLanguage: newLanguage,
      ),
    );
  }
}
