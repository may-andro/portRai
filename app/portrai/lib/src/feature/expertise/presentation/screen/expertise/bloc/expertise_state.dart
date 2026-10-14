import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/profile.dart';

@immutable
final class ExpertiseState extends Equatable {
  const ExpertiseState({this.profile});

  final ProfileEntity? profile;

  @override
  List<Object?> get props => [profile];
}
