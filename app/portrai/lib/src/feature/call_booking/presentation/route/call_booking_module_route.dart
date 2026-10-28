import 'package:portrai/src/feature/call_booking/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class CallBookingModuleRoute extends ModuleRoute {
  CallBookingModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  /// Takes an optional `topic` query parameter that fills in the topic.
  static final CallBookingModuleRoute bookCall = CallBookingModuleRoute._(
    name: 'book_call',
    path: '/book-call',
    builder: (_, _, _) => const BookCallScreen(),
  );
}
