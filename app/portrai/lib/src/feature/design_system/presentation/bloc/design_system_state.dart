import 'package:design_system/design_system.dart';
import 'package:equatable/equatable.dart';
import 'package:use_case/use_case.dart';

class DesignSystemState extends Equatable {
  const DesignSystemState({
    this.isLoaded = false,
    this.designSystem,
    this.failure,
  });

  final bool isLoaded;

  /// `null` means the design system follows the current month.
  final DesignSystem? designSystem;
  final BasicFailure? failure;

  @override
  List<Object?> get props => [isLoaded, designSystem, failure];
}
