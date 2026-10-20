import 'package:equatable/equatable.dart';

/// Someone using the app. Each kind of user, such as a guest or a signed-in
/// account, extends this and holds only the attributes it actually has.
abstract class UserEntity extends Equatable {
  const UserEntity();
}
