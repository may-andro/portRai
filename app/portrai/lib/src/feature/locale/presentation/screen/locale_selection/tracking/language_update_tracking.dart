import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/tracking/language_update_action.dart';
import 'package:tracking/tracking.dart';

class LanguageUpdateTracking extends Tracking {
  LanguageUpdateTracking({
    required String previousLanguage,
    required String newLanguage,
  }) : super(
         name: 'language_update',
         action: LanguageUpdateAction(
           previousLanguage: previousLanguage,
           newLanguage: newLanguage,
         ),
       );
}
