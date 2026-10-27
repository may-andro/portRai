import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_event.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_state.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/tracking/_tracking.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';
import 'package:use_case/use_case.dart';

@register
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState>
    with ScreenTrackingBlocMixin<PortfolioEvent, PortfolioState> {
  PortfolioBloc(
    this._getPortfolioUseCase,
    this._trackingDelegate,
    this._isFeatureEnabledUseCase,
    this._isLocalAssistantSupportedUseCase,
    this._getGuestUserUseCase,
    this._watchRefreshedPortfolioSectionsUseCase,
  ) : super(const LoadingState()) {
    on<LoadPortfolioEvent>(_mapLoadPortfolioEventToState);
    on<PortfolioSectionsRefreshedEvent>(
      _mapPortfolioSectionsRefreshedEventToState,
    );
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<DrawerClickEvent>(_mapDrawerClickEventToState);
    on<SectionNavigationEvent>(_mapSectionNavigationEventToState);
    trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId);
    trackViewEventOn<SectionVisibleEvent>((event) => event.trackingId);
    on<AssistantLaunchClickEvent>(_mapAssistantLaunchClickEventToState);
    on<SeeAllClickEvent>(_mapSeeAllClickEventToState);
    on<SettingClickEvent>(_mapSettingClickEventToState);
    on<ExperienceClickEvent>(_mapExperienceClickEventToState);
    on<ExpertiseClickEvent>(_mapExpertiseClickEventToState);
    on<ServiceClickEvent>(_mapServiceClickEventToState);
    on<ProjectClickEvent>(_mapProjectClickEventToState);
  }

  final GetPortfolioUseCase _getPortfolioUseCase;
  final PortfolioTrackingDelegate _trackingDelegate;
  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;
  final GetGuestUserUseCase _getGuestUserUseCase;
  final WatchRefreshedPortfolioSectionsUseCase
  _watchRefreshedPortfolioSectionsUseCase;
  StreamSubscription<Object?>? _refreshedSectionsSubscription;
  int _availabilityRevision = 0;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  Future<void> _mapLoadPortfolioEventToState(
    LoadPortfolioEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    // A failed update is ignored, and the stream keeps listening.
    _refreshedSectionsSubscription ??= _watchRefreshedPortfolioSectionsUseCase()
        .listen((sectionsEither) {
          if (sectionsEither.isRight) {
            add(const PortfolioSectionsRefreshedEvent());
          }
        });
    emit(const LoadingState());
    try {
      final result = await _getPortfolioUseCase();
      if (result.isRight) {
        final userEither = await _getGuestUserUseCase();
        emit(
          LoadedState(
            portfolio: result.right,
            userRole: userEither.isRight ? userEither.right?.role : null,
          ),
        );
        await _refreshAssistantAvailability(emit);
        return;
      }
      emit(ErrorState(result.left));
    } catch (e) {
      emit(const ErrorState(UnknownFailure()));
    }
  }

  // Reloads in place, keeping the shown portfolio when reloading fails.
  Future<void> _mapPortfolioSectionsRefreshedEventToState(
    PortfolioSectionsRefreshedEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    if (state is! LoadedState) return;
    final portfolioEither = await _getPortfolioUseCase();
    if (portfolioEither.isLeft || state is! LoadedState) return;
    emit((state as LoadedState).copyWith(portfolio: portfolioEither.right));
  }

  FutureOr<void> _mapSectionNavigationEventToState(
    SectionNavigationEvent event,
    Emitter<PortfolioState> emit,
  ) {
    switch (event.source) {
      case NavigationSource.drawer:
        _trackingDelegate.trackDrawerItemSelection(event.sectionId);
      case NavigationSource.header:
        _trackingDelegate.trackTabItemSelection(event.sectionId);
      case NavigationSource.scroll:
        break;
    }

    if (state is LoadedState) {
      final loadedState = state as LoadedState;
      emit(
        loadedState.copyWith(
          selectedSectionIndex: event.sectionIndex,
          lastNavigationSource: event.source,
        ),
      );
    }
  }

  // Tracking Event Handlers
  Future<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    await _refreshAssistantAvailability(emit);
  }

  void _mapAssistantLaunchClickEventToState(
    AssistantLaunchClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackAssistantLaunch(isLocal: event.isLocal);

  void _mapSeeAllClickEventToState(
    SeeAllClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackSeeAllClick(event.section.name);

  void _mapSettingClickEventToState(
    SettingClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackSettingClick();

  void _mapExperienceClickEventToState(
    ExperienceClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackExperienceClick(event.experienceId);

  void _mapExpertiseClickEventToState(
    ExpertiseClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackExpertiseClick(event.expertiseTitle);

  void _mapServiceClickEventToState(
    ServiceClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackServiceClick(event.serviceTitle);

  void _mapProjectClickEventToState(
    ProjectClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackProjectClick(event.projectId);

  Future<void> _refreshAssistantAvailability(
    Emitter<PortfolioState> emit,
  ) async {
    final revision = ++_availabilityRevision;
    final remote = await _isFeatureEnabledUseCase(
      RemoteAssistantFeatureFlags.remoteAssistant,
    );
    final isRemoteAssistantAvailable = remote.isRight && remote.right;
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
    if (emit.isDone ||
        revision != _availabilityRevision ||
        state is! LoadedState) {
      return;
    }
    emit(
      (state as LoadedState).copyWith(
        isRemoteAssistantAvailable: isRemoteAssistantAvailable,
        isLocalAssistantAvailable: isLocalAssistantAvailable,
      ),
    );
  }

  FutureOr<void> _mapDrawerClickEventToState(
    DrawerClickEvent event,
    Emitter<PortfolioState> emit,
  ) {
    if (event.isOpened) {
      _trackingDelegate.trackDrawerOpen();
    } else {
      _trackingDelegate.trackDrawerClose();
    }
  }

  @override
  Future<void> close() async {
    await _refreshedSectionsSubscription?.cancel();
    await super.close();
  }
}
