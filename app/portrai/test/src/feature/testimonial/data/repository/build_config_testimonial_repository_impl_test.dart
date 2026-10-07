import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/data/repository/build_config_testimonial_repository_impl.dart';

import '../../../../../mock/feature/testimonial/domain/repository/mock_testimonial_repository.dart';
import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  final testimonial = createTestimonialEntity();

  for (final environment in BuildEnvironment.values) {
    group('BuildConfigTestimonialRepositoryImpl ($environment)', () {
      late MockTestimonialRepository remote;
      late MockTestimonialRepository asset;
      late BuildConfigTestimonialRepositoryImpl repository;
      late MockTestimonialRepository selected;
      late MockTestimonialRepository unselected;

      setUp(() {
        remote = MockTestimonialRepository();
        asset = MockTestimonialRepository();
        repository = BuildConfigTestimonialRepositoryImpl(
          BuildConfig(buildEnvironment: environment),
          remote,
          asset,
        );
        selected = environment == BuildEnvironment.prod ? remote : asset;
        unselected = environment == BuildEnvironment.prod ? asset : remote;
      });

      test(
        'should delegate testimonial reads to the selected source when requested',
        () async {
          selected.stubGetTestimonial(
            id: testimonial.id,
            testimonial: testimonial,
          );

          expect(await repository.getTestimonial(testimonial.id), testimonial);
          verify(() => selected.getTestimonial(testimonial.id)).called(1);
          verifyNever(() => unselected.getTestimonial(testimonial.id));
        },
      );

      test(
        'should delegate testimonial list reads to the selected source when requested',
        () async {
          selected.stubGetTestimonials([testimonial]);

          expect(await repository.getTestimonials(), [testimonial]);
          verify(() => selected.getTestimonials()).called(1);
          verifyNever(() => unselected.getTestimonials());
        },
      );

      test(
        'should delegate testimonial cache writes to the selected source when requested',
        () async {
          selected.stubCacheTestimonial(testimonial);

          await repository.cacheTestimonial(testimonial);

          verify(() => selected.cacheTestimonial(testimonial)).called(1);
          verifyNever(() => unselected.cacheTestimonial(testimonial));
        },
      );
    });
  }
}
