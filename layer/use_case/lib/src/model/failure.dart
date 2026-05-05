import 'package:equatable/equatable.dart';

abstract class Failure {}

class NoFailure implements Failure {}

abstract class BasicFailure extends Equatable implements Failure {
  const BasicFailure({this.cause});

  final Object? cause;

  String get _typeString => runtimeType.toString();

  @override
  String toString() {
    final cause = this.cause;
    return <String>[
      _typeString,
      if (cause != null) '. Caused by: $cause',
    ].join();
  }

  @override
  List<Object?> get props => [cause];

  @override
  bool? get stringify => null;
}

class UnknownFailure extends BasicFailure {
  const UnknownFailure({super.cause});
}
