import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object?> get props => [];
}

final class SignInStartedEvent extends SignInEvent {
  const SignInStartedEvent();
}

final class SignInClickEvent extends SignInEvent {
  const SignInClickEvent({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];

  /// Bloc events can end up in logs, so this never prints the credentials.
  @override
  String toString() => 'SignInClickEvent';
}
