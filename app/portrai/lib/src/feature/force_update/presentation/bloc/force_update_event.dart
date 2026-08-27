import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ForceUpdateEvent extends Equatable {
  const ForceUpdateEvent();

  @override
  List<Object> get props => [];
}

class CheckForceUpdateEvent extends ForceUpdateEvent {
  const CheckForceUpdateEvent();
}

class UpdateNowClickEvent extends ForceUpdateEvent {
  const UpdateNowClickEvent();
}
