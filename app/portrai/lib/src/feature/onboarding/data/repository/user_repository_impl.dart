import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/data/cache/_cache.dart';
import 'package:portrai/src/feature/onboarding/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';
import 'package:portrai/src/feature/onboarding/domain/repository/_repository.dart';

@Register(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._cache, this._mapper);

  final UserCache _cache;
  final UserMapper _mapper;

  @override
  Future<UserEntity?> getUser() async {
    try {
      final userModel = await _cache.get();
      return userModel == null ? null : _mapper.to(userModel);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    await _cache.put(_mapper.from(user));
  }
}
