import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

import '../../../../../mock/feature/testimonial/domain/repository/mock_testimonial_repository.dart';
import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  final testimonial = createTestimonialEntity();

  group('GetTestimonialUseCase', () {
    late MockTestimonialRepository repository;
    late GetTestimonialUseCase useCase;

    setUp(() {
      repository = MockTestimonialRepository();
      useCase = GetTestimonialUseCase(repository);
    });

    test(
      'should return the requested testimonial when the repository succeeds',
      () async {
        repository.stubGetTestimonial(
          id: testimonial.id,
          testimonial: testimonial,
        );

        final result = await useCase(testimonial.id);

        expect(result.isRight, isTrue);
        expect(result.right, testimonial);
      },
    );

    final failures = <(Object, Type)>[
      (const TestimonialNotFoundException(), TestimonialNotFoundFailure),
      (const TestimonialNetworkException(), TestimonialNetworkFailure),
      (const TestimonialParsingException(), TestimonialDataFailure),
      (const TestimonialCacheException(), TestimonialDataFailure),
      (
        const TestimonialUnauthorizedException(),
        TestimonialUnauthorizedFailure,
      ),
      (Exception('unexpected'), TestimonialUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubGetTestimonialThrows(id: testimonial.id, error: error);

          final result = await useCase(testimonial.id);

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
