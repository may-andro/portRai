import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@immutable
sealed class FooterEvent extends Equatable {
  const FooterEvent();

  @override
  List<Object?> get props => [];
}

final class LoadDataEvent extends FooterEvent {
  const LoadDataEvent({required this.profile});

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

final class OpenExternalUrlEvent extends FooterEvent {
  const OpenExternalUrlEvent({required this.url, required this.label});

  final String url;
  final String label;

  @override
  List<Object?> get props => [url, label];
}

final class OpenEmailClientEvent extends FooterEvent {
  const OpenEmailClientEvent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}
