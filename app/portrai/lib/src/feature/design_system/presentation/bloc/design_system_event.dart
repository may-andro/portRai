import 'package:design_system/design_system.dart';
import 'package:equatable/equatable.dart';

sealed class DesignSystemEvent extends Equatable {
  const DesignSystemEvent();

  @override
  List<Object?> get props => [];
}

class LoadDesignSystemEvent extends DesignSystemEvent {
  const LoadDesignSystemEvent();
}

class DesignSystemClickEvent extends DesignSystemEvent {
  const DesignSystemClickEvent(this.designSystem);

  final DesignSystem designSystem;

  @override
  List<Object?> get props => [designSystem];
}

class DesignSystemResetClickEvent extends DesignSystemEvent {
  const DesignSystemResetClickEvent();
}
