// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:core/src/model/app_locale.dart';
import 'package:log_reporter/src/log/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/data/cache/app_locale_cache.dart';
import 'package:portrai/src/feature/locale/data/repository/locale_repository_impl.dart';
import 'package:portrai/src/feature/locale/domain/repository/locale_repository.dart';
import 'package:portrai/src/feature/locale/domain/use_case/get_locale_stream_use_case.dart';
import 'package:portrai/src/feature/locale/domain/use_case/get_locale_use_case.dart';
import 'package:portrai/src/feature/locale/domain/use_case/update_locale_use_case.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/tracking/locale_selection_tracking_delegate.dart';
import 'package:portrai/src/feature/profile/domain/use_case/get_profile_use_case.dart';
import 'package:tracking/src/reporter/tracking_reporter.dart';

void $registerLocaleDependencies(ServiceLocator sl) {
  sl.registerSingleton<AppLocaleCache>(
    () => AppLocaleCache(),
  );
  sl.registerSingleton<LocaleRepository>(
    () => LocaleRepositoryImpl(sl.get<AppLocale>(), sl.get<AppLocaleCache>()),
  );
  sl.registerFactory<GetLocaleStreamUseCase>(
    () => GetLocaleStreamUseCase(sl.get<LocaleRepository>()),
  );
  sl.registerFactory<GetLocaleUseCase>(
    () => GetLocaleUseCase(sl.get<LocaleRepository>()),
  );
  sl.registerFactory<UpdateLocaleUseCase>(
    () => UpdateLocaleUseCase(sl.get<LocaleRepository>()),
  );
  sl.registerFactory<LocaleSelectionBloc>(
    () => LocaleSelectionBloc(sl.get<GetLocaleUseCase>(), sl.get<UpdateLocaleUseCase>(), sl.get<GetProfileUseCase>(), sl.get<LogReporter>(), sl.get<LocaleSelectionTrackingDelegate>()),
  );
  sl.registerFactory<LocaleSelectionTrackingDelegate>(
    () => LocaleSelectionTrackingDelegate(sl.get<TrackingReporter>()),
  );
}
