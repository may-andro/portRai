import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/app/restart_app.dart';
import 'package:portrai/src/feature/ai_image_gen/ai_image_gen.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/developer_menu_event.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/developer_menu_state.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class DeveloperMenuBloc extends Bloc<DeveloperMenuEvent, DeveloperMenuState>
    with ScreenTrackingBlocMixin<DeveloperMenuEvent, DeveloperMenuState> {
  DeveloperMenuBloc(
    this._trackingDelegate,
    this._getAssetSourceUseCase,
    this._updateAssetSourceUseCase,
    this._getAiImageSettingsUseCase,
    this._updateAiImageSettingsUseCase,
  ) : super(const DeveloperMenuInitialState()) {
    on<LoadDeveloperMenuEvent>(_mapLoadDeveloperMenuEventToState);
    on<AssetSourceClickEvent>(_mapAssetSourceClickEventToState);
    on<AiImageStyleClickEvent>(_mapAiImageStyleClickEventToState);
    on<AiImageModelClickEvent>(_mapAiImageModelClickEventToState);
    on<ForceFatalCrashEvent>(_mapForceFatalCrashEventToState);
    on<ForceNonFatalCrashEvent>(_mapForceNonFatalCrashEventToState);
    on<ForceBlacklistErrorEvent>(_mapForceBlacklistErrorEventToState);
    on<DeveloperMenuEntryClickEvent>(_mapDeveloperMenuEntryClickEventToState);
    trackScreenViewOn<ScreenVisibleEvent>();
    trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId);
  }

  final DeveloperMenuTrackingDelegate _trackingDelegate;
  final GetAssetSourceUseCase _getAssetSourceUseCase;
  final UpdateAssetSourceUseCase _updateAssetSourceUseCase;
  final GetAiImageSettingsUseCase _getAiImageSettingsUseCase;
  final UpdateAiImageSettingsUseCase _updateAiImageSettingsUseCase;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  DeveloperMenuLoadedState get _loadedState => switch (state) {
    final DeveloperMenuLoadedState loaded => loaded,
    _ => const DeveloperMenuLoadedState(),
  };

  Future<void> _mapLoadDeveloperMenuEventToState(
    LoadDeveloperMenuEvent event,
    Emitter<DeveloperMenuState> emit,
  ) async {
    final assetSourceEither = await _getAssetSourceUseCase();
    final aiImageSettingsEither = await _getAiImageSettingsUseCase();
    emit(
      DeveloperMenuLoadedState(
        assetSource: assetSourceEither.right,
        aiImageSettings: aiImageSettingsEither.right ?? const AiImageSettings(),
      ),
    );
  }

  Future<void> _mapAssetSourceClickEventToState(
    AssetSourceClickEvent event,
    Emitter<DeveloperMenuState> emit,
  ) async {
    final result = await _updateAssetSourceUseCase(event.source);
    if (result.isRight) {
      emit(_loadedState.withAssetSource(event.source));
    }
  }

  Future<void> _mapAiImageStyleClickEventToState(
    AiImageStyleClickEvent event,
    Emitter<DeveloperMenuState> emit,
  ) => _updateAiImageSettings(
    _loadedState.aiImageSettings.copyWith(style: event.style),
    emit,
  );

  Future<void> _mapAiImageModelClickEventToState(
    AiImageModelClickEvent event,
    Emitter<DeveloperMenuState> emit,
  ) => _updateAiImageSettings(
    _loadedState.aiImageSettings.copyWith(model: event.model),
    emit,
  );

  Future<void> _updateAiImageSettings(
    AiImageSettings settings,
    Emitter<DeveloperMenuState> emit,
  ) async {
    final result = await _updateAiImageSettingsUseCase(settings);
    if (result.isRight) {
      emit(_loadedState.withAiImageSettings(settings));
      // Last step: restarting tears the app, and with it this bloc, down.
      await restartApp();
    }
  }

  void _mapDeveloperMenuEntryClickEventToState(
    DeveloperMenuEntryClickEvent event,
    Emitter<DeveloperMenuState> emit,
  ) => _trackingDelegate.trackEntryClick(event.entryName);

  void _mapForceFatalCrashEventToState(
    ForceFatalCrashEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    // Handle fatal crash
  }

  void _mapForceNonFatalCrashEventToState(
    ForceNonFatalCrashEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    // Handle non-fatal crash
  }

  void _mapForceBlacklistErrorEventToState(
    ForceBlacklistErrorEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    // Handle blacklist error
  }
}
