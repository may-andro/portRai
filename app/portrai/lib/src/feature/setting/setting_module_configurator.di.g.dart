// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:core/src/model/build_config.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/use_case/is_feature_enabled_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/get_local_assistant_availability_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/get_remote_assistant_availability_use_case.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_bloc.dart';

void $registerSettingDependencies(ServiceLocator sl) {
  sl.registerFactory<SettingBloc>(
    () => SettingBloc(
      sl.get<IsFeatureEnabledUseCase>(),
      sl.get<BuildConfig>(),
      sl.get<GetLocalAssistantAvailabilityUseCase>(),
      sl.get<GetRemoteAssistantAvailabilityUseCase>(),
    ),
  );
}
