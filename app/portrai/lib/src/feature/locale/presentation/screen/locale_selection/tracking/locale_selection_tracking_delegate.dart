import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('locale_selection_screen');
}

@register
class LocaleSelectionTrackingDelegate extends ScreenTrackingDelegate {
  LocaleSelectionTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackVisibleScreen(bool isDialog) {
    if (isDialog) {
      trackEvent(ViewTracking(label: 'locale_selection_popup'));
      return;
    }

    trackEvent(ScreenViewTracking(area: const _TrackingArea()));
  }

  void trackViewEvent(String label) {
    trackEvent(ViewTracking(label: label));
  }

  void trackLocaleSelectionClick(String localeCode) {
    trackEvent(
      Tracking(
        name: 'selected_locale',
        action: ClickAction(label: localeCode),
      ),
    );
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
