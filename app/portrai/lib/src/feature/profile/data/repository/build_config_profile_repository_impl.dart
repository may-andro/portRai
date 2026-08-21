import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/repository/asset_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/data/repository/remote_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@Register(as: ProfileRepository)
class BuildConfigProfileRepositoryImpl implements ProfileRepository {
  BuildConfigProfileRepositoryImpl(
    this._buildConfig,
    @Inject(RemoteProfileRepositoryImpl) this._remoteDelegateRepository,
    @Inject(AssetProfileRepositoryImpl) this._demoDelegateRepository,
  );

  final BuildConfig _buildConfig;
  final ProfileRepository _remoteDelegateRepository;
  final ProfileRepository _demoDelegateRepository;

  @override
  Future<void> cacheProfile(ProfileEntity profile) {
    return _delegateRepository.cacheProfile(profile);
  }

  @override
  Future<ProfileEntity> getProfile() {
    return _delegateRepository.getProfile();
  }

  ProfileRepository get _delegateRepository {
    switch (_buildConfig.buildEnvironment) {
      case BuildEnvironment.prod:
        return _remoteDelegateRepository;
      case BuildEnvironment.staging:
        return _demoDelegateRepository;
    }
  }
}
