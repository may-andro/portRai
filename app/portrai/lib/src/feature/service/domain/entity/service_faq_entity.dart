import 'package:equatable/equatable.dart';

class ServiceFaqEntity extends Equatable {
  const ServiceFaqEntity({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  List<Object?> get props => [question, answer];
}
