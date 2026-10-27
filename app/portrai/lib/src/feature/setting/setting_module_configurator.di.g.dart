// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:core/src/model/build_config.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/use_case/is_feature_enabled_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:portrai/src/feature/permission/domain/use_case/is_permission_supported_use_case.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/tracking/setting_tracking_delegate.dart';
import 'package:portrai/src/feature/user/domain/use_case/get_guest_user_use_case.dart';
import 'package:tracking/src/reporter/tracking_reporter.dart';

void $registerSettingDependencies(ServiceLocator sl) {
  sl.registerFactory<SettingBloc>(
    () => SettingBloc(
      sl.get<IsFeatureEnabledUseCase>(),
      sl.get<BuildConfig>(),
      sl.get<IsLocalAssistantSupportedUseCase>(),
      sl.get<GetGuestUserUseCase>(),
      sl.get<IsPermissionSupportedUseCase>(),
      sl.get<SettingTrackingDelegate>(),
    ),
  );
  sl.registerFactory<SettingTrackingDelegate>(
    () => SettingTrackingDelegate(sl.get<TrackingReporter>()),
  );
}
