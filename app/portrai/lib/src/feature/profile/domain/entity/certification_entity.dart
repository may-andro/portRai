import 'package:equatable/equatable.dart';

class CertificationEntity extends Equatable {
  const CertificationEntity({
    required this.name,
    required this.issuer,
    required this.date,
    this.url,
  });

  final String name;
  final String issuer;
  final String date;
  final String? url;

  @override
  List<Object?> get props => [name, issuer, date, url];
}
