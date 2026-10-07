import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/use_case/get_locale_stream_use_case.dart';

class MockGetLocaleStreamUseCase extends Mock
    implements GetLocaleStreamUseCase {}

extension MockGetLocaleStreamUseCaseStub on MockGetLocaleStreamUseCase {
  void stubCall(Stream<AppLocale> stream) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
