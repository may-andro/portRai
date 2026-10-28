import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockIsCallBookingAvailableUseCase extends Mock
    implements IsCallBookingAvailableUseCase {}

extension MockIsCallBookingAvailableUseCaseStub
    on MockIsCallBookingAvailableUseCase {
  void stubCall(bool isAvailable) {
    when(() => this()).thenAnswer((_) => Right(isAvailable));
  }
}
