import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@immutable
sealed class ProfessionalSummaryEvent extends Equatable {
  const ProfessionalSummaryEvent();

  @override
  List<Object> get props => [];
}

class LoadDataEvent extends ProfessionalSummaryEvent {
  const LoadDataEvent(this.profile);

  final ProfileEntity profile;

  @override
  List<Object> get props => [profile];
}

final class OpenEmailClientEvent extends ProfessionalSummaryEvent {
  const OpenEmailClientEvent(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class OpenExternalUrlEvent extends ProfessionalSummaryEvent {
  const OpenExternalUrlEvent(this.url, this.label);

  final String url;
  final String label;

  @override
  List<Object> get props => [url, label];
}
