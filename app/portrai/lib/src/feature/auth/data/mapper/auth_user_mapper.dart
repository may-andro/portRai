import 'package:core/core.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/user/user.dart';

@register
class AuthUserMapper implements Mapper<firebase.User, AuthUserEntity> {
  const AuthUserMapper();

  @override
  AuthUserEntity map(firebase.User from) =>
      AuthUserEntity(id: from.uid, email: from.email);
}
