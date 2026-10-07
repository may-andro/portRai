import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/_bloc.dart';

class MockTestimonialDetailBloc
    extends MockBloc<TestimonialDetailEvent, TestimonialDetailState>
    implements TestimonialDetailBloc {}

extension MockTestimonialDetailBlocStub on MockTestimonialDetailBloc {
  void stubState(TestimonialDetailState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<TestimonialDetailState>.empty(),
      initialState: state,
    );
  }
}
