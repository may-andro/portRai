import 'package:portrai/src/feature/user/user.dart';

/// A user signed in with an account. [id] is the account's uid, which keys
/// that user's own data.
class AuthUserEntity extends UserEntity {
  const AuthUserEntity({required this.id, required this.email});

  final String id;
  final String? email;

  @override
  List<Object?> get props => [id, email];
}
