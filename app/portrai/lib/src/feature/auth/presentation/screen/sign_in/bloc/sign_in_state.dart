import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:use_case/use_case.dart';

@immutable
class SignInState extends Equatable {
  const SignInState({
    this.isSigningIn = false,
    this.isSignedIn = false,
    this.failure,
  });

  final bool isSigningIn;
  final bool isSignedIn;
  final Failure? failure;

  @override
  List<Object?> get props => [isSigningIn, isSignedIn, failure];
}
