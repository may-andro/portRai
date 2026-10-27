import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('portfolio');
}

@register
class PortfolioTrackingDelegate extends ScreenTrackingDelegate {
  PortfolioTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackAssistantLaunch({required bool isLocal}) {
    trackEvent(
      Tracking(
        name: 'assistant_launch',
        action: ClickAction(label: isLocal ? 'local' : 'cloud'),
      ),
    );
  }

  void trackDrawerOpen() {
    trackEvent(
      Tracking(
        name: 'drawer_menu',
        action: const ViewAction(label: 'open'),
      ),
    );
  }

  void trackDrawerClose() {
    trackEvent(
      Tracking(
        name: 'drawer_menu',
        action: const ViewAction(label: 'close'),
      ),
    );
  }

  void trackDrawerItemSelection(String drawerItemName) {
    trackEvent(
      Tracking(
        name: 'drawer_menu',
        action: ClickAction(label: drawerItemName),
      ),
    );
  }

  void trackTabItemSelection(String drawerItemName) {
    trackEvent(
      Tracking(
        name: 'header_tab',
        action: ClickAction(label: drawerItemName),
      ),
    );
  }

  void trackSeeAllClick(String sectionName) {
    trackEvent(
      Tracking(
        name: 'see_all',
        action: ClickAction(label: sectionName),
      ),
    );
  }

  void trackSettingClick() {
    trackEvent(
      Tracking(
        name: 'setting',
        action: const ClickAction(label: 'open'),
      ),
    );
  }

  void trackExperienceClick(String experienceId) {
    trackEvent(
      Tracking(
        name: 'experience',
        action: ClickAction(label: experienceId),
      ),
    );
  }

  void trackExpertiseClick(String expertiseTitle) {
    trackEvent(
      Tracking(
        name: 'expertise',
        action: ClickAction(label: expertiseTitle),
      ),
    );
  }

  void trackServiceClick(String serviceTitle) {
    trackEvent(
      Tracking(
        name: 'service',
        action: ClickAction(label: serviceTitle),
      ),
    );
  }

  void trackProjectClick(String projectId) {
    trackEvent(
      Tracking(
        name: 'project',
        action: ClickAction(label: projectId),
      ),
    );
  }

  void trackProfileClick() {
    trackEvent(
      Tracking(
        name: 'profile',
        action: const ClickAction(label: 'open'),
      ),
    );
  }
}
