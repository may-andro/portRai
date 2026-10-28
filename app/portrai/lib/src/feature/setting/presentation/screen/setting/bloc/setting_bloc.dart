import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/job_opening/job_opening.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/schedule_appointment/schedule_appointment.dart';
import 'package:portrai/src/feature/setting/domain/_domain.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_event.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/tracking/_tracking.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class SettingBloc extends Bloc<SettingEvent, SettingState>
    with ScreenTrackingBlocMixin<SettingEvent, SettingState> {
  SettingBloc(
    this._isFeatureEnabledUseCase,
    this._buildConfig,
    this._isLocalAssistantSupportedUseCase,
    this._getGuestUserUseCase,
    this._isPermissionSupportedUseCase,
    this._trackingDelegate,
  ) : super(const SettingInitialState()) {
    on<LoadSettingsEvent>(_mapLoadSettingsEventToState);
    on<SettingEntryClickEvent>(_mapSettingEntryClickEventToState);
    trackScreenViewOn<ScreenVisibleEvent>();
  }

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final BuildConfig _buildConfig;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;
  final GetGuestUserUseCase _getGuestUserUseCase;
  final IsPermissionSupportedUseCase _isPermissionSupportedUseCase;
  final SettingTrackingDelegate _trackingDelegate;
  int _loadRevision = 0;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  void _mapSettingEntryClickEventToState(
    SettingEntryClickEvent event,
    Emitter<SettingState> emit,
  ) => _trackingDelegate.trackEntryClick(event.label);

  Future<void> _mapLoadSettingsEventToState(
    LoadSettingsEvent event,
    Emitter<SettingState> emit,
  ) async {
    final revision = ++_loadRevision;
    emit(const SettingLoadingState());

    final languageSelectorResult = await _isFeatureEnabledUseCase(
      SettingFeatureFlags.languageSelector,
    );

    var isLanguageSelectorEnabled =
        SettingFeatureFlags.languageSelector.defaultValue;
    if (languageSelectorResult.isRight) {
      isLanguageSelectorEnabled = languageSelectorResult.right;
    }

    final remote = await _isFeatureEnabledUseCase(
      RemoteAssistantFeatureFlags.remoteAssistant,
    );
    var isLocalAssistantAvailable = false;
    if (remote.isRight && !remote.right) {
      final local = await _isFeatureEnabledUseCase(
        LocalAssistantFeatureFlags.aiAssistant,
      );
      if (local.isRight && local.right) {
        final localSupported = await _isLocalAssistantSupportedUseCase();
        isLocalAssistantAvailable =
            localSupported.isRight && localSupported.right;
      }
    }

    final jobOpenings = await _isFeatureEnabledUseCase(
      JobOpeningFeatureFlags.jobOpenings,
    );
    final isJobOpeningsEnabled = jobOpenings.isRight && jobOpenings.right;

    final appointmentRequests = await _isFeatureEnabledUseCase(
      ScheduleAppointmentFeatureFlags.appointmentRequests,
    );
    final isAppointmentRequestsEnabled =
        appointmentRequests.isRight && appointmentRequests.right;

    UserRole? userRole;
    final onboarding = await _isFeatureEnabledUseCase(
      OnboardingFeatureFlags.roleOnboarding,
    );
    if (onboarding.isRight && onboarding.right) {
      final user = await _getGuestUserUseCase();
      userRole = user.isRight ? user.right?.role : null;
    }
    final notificationSupported = await _isPermissionSupportedUseCase(
      AppPermission.notifications,
    );
    if (emit.isDone || revision != _loadRevision) return;
    emit(
      SettingLoadedState(
        isLanguageSelectorEnabled: isLanguageSelectorEnabled,
        isDevMenuEnabled: _buildConfig.buildEnvironment.isDevMenuEnabled,
        isLocalAssistantAvailable: isLocalAssistantAvailable,
        isJobOpeningsEnabled: isJobOpeningsEnabled,
        isAppointmentRequestsEnabled: isAppointmentRequestsEnabled,
        isNotificationSettingAvailable:
            notificationSupported.isRight && notificationSupported.right,
        userRole: userRole,
      ),
    );
  }
}
