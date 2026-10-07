import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

import '../../../../../mock/feature/testimonial/domain/repository/mock_testimonial_repository.dart';
import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  final testimonial = createTestimonialEntity();

  group('GetTestimonialsUseCase', () {
    late MockTestimonialRepository repository;
    late GetTestimonialsUseCase useCase;

    setUp(() {
      repository = MockTestimonialRepository();
      useCase = GetTestimonialsUseCase(repository);
    });

    test(
      'should return all testimonials when the repository succeeds',
      () async {
        repository.stubGetTestimonials([testimonial]);

        final result = await useCase();

        expect(result.isRight, isTrue);
        expect(result.right, [testimonial]);
      },
    );

    final failures = <(Object, Type)>[
      (const TestimonialNotFoundException(), TestimonialsNotFoundFailure),
      (const TestimonialNetworkException(), TestimonialsNetworkFailure),
      (const TestimonialParsingException(), TestimonialsDataFailure),
      (const TestimonialCacheException(), TestimonialsDataFailure),
      (
        const TestimonialUnauthorizedException(),
        TestimonialsUnauthorizedFailure,
      ),
      (Exception('unexpected'), TestimonialsUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubGetTestimonialsThrows(error);

          final result = await useCase();

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
