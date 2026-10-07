import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/_bloc.dart';

import '../../../../../../../mock/feature/testimonial/presentation/screen/testimonial_detail/tracking/mock_testimonial_detail_tracking_delegate.dart';
import '../../../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  final testimonial = createTestimonialEntity();

  group('TestimonialDetailBloc', () {
    late MockTestimonialDetailTrackingDelegate tracking;

    TestimonialDetailBloc buildBloc() => TestimonialDetailBloc(tracking);

    setUp(() {
      tracking = MockTestimonialDetailTrackingDelegate();
    });

    test('should compare loading states equal when they are the same type', () {
      expect(const LoadingState(), const LoadingState());
    });

    test('should compare loaded states equal when the testimonial matches', () {
      expect(LoadedState(testimonial), LoadedState(testimonial));
    });

    test(
      'should compare screen visible events equal when they are the same type',
      () {
        expect(ScreenVisibleEvent(), ScreenVisibleEvent());
      },
    );

    blocTest<TestimonialDetailBloc, TestimonialDetailState>(
      'should track the screen view when the screen becomes visible',
      build: buildBloc,
      act: (bloc) => bloc.add(ScreenVisibleEvent()),
      expect: () => const <TestimonialDetailState>[],
      verify: (_) {
        verify(() => tracking.trackScreenView()).called(1);
      },
    );
  });
}
