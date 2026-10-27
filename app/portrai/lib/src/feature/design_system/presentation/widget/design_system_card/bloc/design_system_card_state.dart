import 'package:equatable/equatable.dart';

/// The card shows the theme in use from the context, so its bloc only handles
/// the tap and keeps no state of its own.
final class DesignSystemCardState extends Equatable {
  const DesignSystemCardState();

  @override
  List<Object?> get props => [];
}
