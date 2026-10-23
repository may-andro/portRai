import 'package:design_system/design_system.dart';
import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/_use_case.dart';

sealed class DesignSystemGalleryState extends Equatable {
  const DesignSystemGalleryState();

  @override
  List<Object?> get props => [];
}

class DesignSystemGalleryLoadingState extends DesignSystemGalleryState {
  const DesignSystemGalleryLoadingState();
}

class DesignSystemGalleryLoadedState extends DesignSystemGalleryState {
  const DesignSystemGalleryLoadedState({
    required this.designSystems,
    required this.appliedDesignSystem,
    required this.monthlyDesignSystem,
    required this.previewedDesignSystem,
    this.isApplying = false,
    this.failure,
  });

  /// Every design system in month order, January first.
  final List<DesignSystem> designSystems;

  /// The design system the app is running with.
  final DesignSystem appliedDesignSystem;

  /// The design system of the current month.
  final DesignSystem monthlyDesignSystem;

  /// The design system the screen is dressed in.
  final DesignSystem previewedDesignSystem;
  final bool isApplying;
  final ApplyDesignSystemFailure? failure;

  bool get isPreviewApplied => previewedDesignSystem == appliedDesignSystem;

  /// The month, from 1 to 12, that [designSystem] belongs to.
  int monthOf(DesignSystem designSystem) =>
      designSystems.indexOf(designSystem) + 1;

  /// Copies the state; [failure] is cleared unless given.
  DesignSystemGalleryLoadedState copyWith({
    DesignSystem? previewedDesignSystem,
    bool? isApplying,
    ApplyDesignSystemFailure? failure,
  }) {
    return DesignSystemGalleryLoadedState(
      designSystems: designSystems,
      appliedDesignSystem: appliedDesignSystem,
      monthlyDesignSystem: monthlyDesignSystem,
      previewedDesignSystem:
          previewedDesignSystem ?? this.previewedDesignSystem,
      isApplying: isApplying ?? this.isApplying,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    designSystems,
    appliedDesignSystem,
    monthlyDesignSystem,
    previewedDesignSystem,
    isApplying,
    failure,
  ];
}
