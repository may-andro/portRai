import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

import '../../../../../mock/feature/testimonial/domain/repository/mock_testimonial_repository.dart';

void main() {
  group('RefreshTestimonialsUseCase', () {
    late MockTestimonialRepository repository;
    late RefreshTestimonialsUseCase useCase;

    setUp(() {
      repository = MockTestimonialRepository();
      useCase = RefreshTestimonialsUseCase(repository);
    });

    test(
      'should succeed when the repository refreshes the testimonials',
      () async {
        repository.stubRefreshTestimonials();

        final result = await useCase();

        expect(result.isRight, isTrue);
      },
    );

    final failures = <(Object, Type)>[
      (const TestimonialNetworkException(), RefreshTestimonialsNetworkFailure),
      (
        const TestimonialUnauthorizedException(),
        RefreshTestimonialsNetworkFailure,
      ),
      (const TestimonialNotFoundException(), RefreshTestimonialsDataFailure),
      (const TestimonialParsingException(), RefreshTestimonialsDataFailure),
      (const TestimonialCacheException(), RefreshTestimonialsDataFailure),
      (Exception('unexpected'), RefreshTestimonialsUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubRefreshTestimonialsThrows(error);

          final result = await useCase();

          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
