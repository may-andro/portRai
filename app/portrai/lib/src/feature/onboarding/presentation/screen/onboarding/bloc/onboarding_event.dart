import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/user/user.dart';

@immutable
sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

final class OnboardingStartedEvent extends OnboardingEvent {
  const OnboardingStartedEvent();
}

final class RoleSelectedClickEvent extends OnboardingEvent {
  const RoleSelectedClickEvent(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}
