import 'package:tracking/src/area_controller/area_controller.dart';
import 'package:tracking/src/model/action/action.dart';
import 'package:tracking/src/model/area/area.dart';

export 'app_initialization_tracking.dart';
export 'app_start_tracking.dart';
export 'click_tracking.dart';
export 'screen_view_tracking.dart';
export 'view_tracking.dart';

class Tracking {
  /// An event sent from the current area.
  Tracking({required this.name, required this.action})
    : area = TrackingAreaController().currentArea.name;

  /// An event that sets the current area to [area] and is sent from it.
  Tracking.settingCurrentArea({
    required this.name,
    required this.action,
    required TrackingArea area,
  }) : area = _enter(area);

  final String name;
  final TrackingAction? action;
  final String area;

  static String _enter(TrackingArea area) {
    TrackingAreaController().currentArea = area;
    return area.name;
  }

  Map<String, Object> get parameters {
    final parameters = <String, Object>{'event': name, 'area': area};
    if (action case final TrackingAction action) {
      if (action.action != null) {
        parameters['action'] = action.action!;
      }
      parameters.addAll(action.parameters);
    }
    return parameters;
  }
}
