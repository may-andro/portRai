import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

@immutable
class SignInState extends Equatable {
  const SignInState({
    this.isSigningIn = false,
    this.isSignedIn = false,
    this.failure,
    this.profile,
  });

  final bool isSigningIn;
  final bool isSignedIn;
  final Failure? failure;

  /// For the page footer; null until loaded or when it could not be read.
  final ProfileEntity? profile;

  SignInState copyWith({
    bool? isSigningIn,
    bool? isSignedIn,
    Failure? failure,
    bool clearFailure = false,
    ProfileEntity? profile,
  }) {
    return SignInState(
      isSigningIn: isSigningIn ?? this.isSigningIn,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      failure: clearFailure ? null : failure ?? this.failure,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [isSigningIn, isSignedIn, failure, profile];
}
