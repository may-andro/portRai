import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/app/restart_app.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/_use_case.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/design_system_gallery_event.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/design_system_gallery_state.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class DesignSystemGalleryBloc
    extends Bloc<DesignSystemGalleryEvent, DesignSystemGalleryState>
    with
        ScreenTrackingBlocMixin<
          DesignSystemGalleryEvent,
          DesignSystemGalleryState
        > {
  DesignSystemGalleryBloc(
    this._appliedDesignSystem,
    this._selectDesignSystemUseCase,
    this._applyDesignSystemUseCase,
    this._trackingDelegate,
  ) : super(const DesignSystemGalleryLoadingState()) {
    on<LoadDesignSystemGalleryEvent>(_mapLoadDesignSystemGalleryEventToState);
    on<PreviewDesignSystemClickEvent>(_mapPreviewDesignSystemClickEventToState);
    on<ApplyDesignSystemClickEvent>(_mapApplyDesignSystemClickEventToState);
    trackScreenViewOn<ScreenVisibleEvent>();
  }

  /// The design system the app was started with.
  final DesignSystem _appliedDesignSystem;
  final SelectDesignSystemUseCase _selectDesignSystemUseCase;
  final ApplyDesignSystemUseCase _applyDesignSystemUseCase;
  final DesignSystemGalleryTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  Future<void> _mapLoadDesignSystemGalleryEventToState(
    LoadDesignSystemGalleryEvent event,
    Emitter<DesignSystemGalleryState> emit,
  ) async {
    final monthlyDesignSystemEither = await _selectDesignSystemUseCase();
    const designSystemByMonth = SelectDesignSystemUseCase.designSystemByMonth;
    final months = designSystemByMonth.keys.toList()..sort();
    emit(
      DesignSystemGalleryLoadedState(
        designSystems: [
          for (final month in months) designSystemByMonth[month]!,
        ],
        appliedDesignSystem: _appliedDesignSystem,
        monthlyDesignSystem: monthlyDesignSystemEither.isRight
            ? monthlyDesignSystemEither.right
            : _appliedDesignSystem,
        previewedDesignSystem: _appliedDesignSystem,
      ),
    );
  }

  void _mapPreviewDesignSystemClickEventToState(
    PreviewDesignSystemClickEvent event,
    Emitter<DesignSystemGalleryState> emit,
  ) {
    final currentState = state;
    if (currentState is! DesignSystemGalleryLoadedState ||
        currentState.isApplying ||
        currentState.previewedDesignSystem == event.designSystem) {
      return;
    }
    _trackingDelegate.trackPreview(event.designSystem);
    emit(currentState.copyWith(previewedDesignSystem: event.designSystem));
  }

  Future<void> _mapApplyDesignSystemClickEventToState(
    ApplyDesignSystemClickEvent event,
    Emitter<DesignSystemGalleryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DesignSystemGalleryLoadedState ||
        currentState.isApplying ||
        currentState.isPreviewApplied) {
      return;
    }
    final designSystem = currentState.previewedDesignSystem;
    _trackingDelegate.trackApply(designSystem);
    emit(currentState.copyWith(isApplying: true));

    final applyDesignSystemEither = await _applyDesignSystemUseCase(
      designSystem,
    );
    if (applyDesignSystemEither.isLeft) {
      emit(
        currentState.copyWith(
          isApplying: false,
          failure: applyDesignSystemEither.left,
        ),
      );
      return;
    }
    await restartApp();
  }
}
