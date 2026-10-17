import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:use_case/use_case.dart';

@immutable
class OnboardingState extends Equatable {
  const OnboardingState({
    this.selectedRole,
    this.isCompleted = false,
    this.failure,
  });

  final UserRole? selectedRole;
  final bool isCompleted;
  final Failure? failure;

  bool get isSaving => selectedRole != null && !isCompleted && failure == null;

  @override
  List<Object?> get props => [selectedRole, isCompleted, failure];
}
