import 'package:design_system/design_system.dart';
import 'package:equatable/equatable.dart';

sealed class DesignSystemGalleryEvent extends Equatable {
  const DesignSystemGalleryEvent();

  @override
  List<Object?> get props => [];
}

class LoadDesignSystemGalleryEvent extends DesignSystemGalleryEvent {
  const LoadDesignSystemGalleryEvent();
}

/// The user brought [designSystem] to the front of the deck.
class PreviewDesignSystemClickEvent extends DesignSystemGalleryEvent {
  const PreviewDesignSystemClickEvent(this.designSystem);

  final DesignSystem designSystem;

  @override
  List<Object?> get props => [designSystem];
}

class ApplyDesignSystemClickEvent extends DesignSystemGalleryEvent {
  const ApplyDesignSystemClickEvent();
}

class ScreenVisibleEvent extends DesignSystemGalleryEvent {
  const ScreenVisibleEvent();
}
