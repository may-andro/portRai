import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/data/repository/asset_testimonial_repository_impl.dart';
import 'package:portrai/src/feature/testimonial/data/repository/remote_testimonial_repository_impl.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

@Register(as: TestimonialRepository)
class BuildConfigTestimonialRepositoryImpl implements TestimonialRepository {
  BuildConfigTestimonialRepositoryImpl(
    this._buildConfig,
    @Inject(RemoteTestimonialRepositoryImpl) this._remoteDelegateRepository,
    @Inject(AssetTestimonialRepositoryImpl) this._demoDelegateRepository,
  );

  final BuildConfig _buildConfig;
  final TestimonialRepository _remoteDelegateRepository;
  final TestimonialRepository _demoDelegateRepository;

  @override
  Future<void> cacheTestimonial(TestimonialEntity testimonial) {
    return _delegateRepository.cacheTestimonial(testimonial);
  }

  @override
  Future<TestimonialEntity> getTestimonial(String id) {
    return _delegateRepository.getTestimonial(id);
  }

  @override
  Future<List<TestimonialEntity>> getTestimonials() {
    return _delegateRepository.getTestimonials();
  }

  TestimonialRepository get _delegateRepository {
    switch (_buildConfig.buildEnvironment) {
      case BuildEnvironment.prod:
        return _remoteDelegateRepository;
      case BuildEnvironment.staging:
        return _demoDelegateRepository;
    }
  }
}
