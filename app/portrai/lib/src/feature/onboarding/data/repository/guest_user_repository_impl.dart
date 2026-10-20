import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/data/cache/_cache.dart';
import 'package:portrai/src/feature/onboarding/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';
import 'package:portrai/src/feature/onboarding/domain/repository/_repository.dart';

@Register(as: GuestUserRepository)
class GuestUserRepositoryImpl implements GuestUserRepository {
  GuestUserRepositoryImpl(this._cache, this._mapper);

  final GuestUserCache _cache;
  final GuestUserMapper _mapper;

  @override
  Future<GuestUserEntity?> getGuestUser() async {
    try {
      final userModel = await _cache.get();
      return userModel == null ? null : _mapper.to(userModel);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGuestUser(GuestUserEntity user) async {
    await _cache.put(_mapper.from(user));
  }
}
