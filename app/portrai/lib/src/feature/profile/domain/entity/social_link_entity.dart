import 'package:equatable/equatable.dart';

class SocialLinkEntity extends Equatable {
  const SocialLinkEntity({
    required this.name,
    required this.url,
    required this.image,
  });

  final String name;
  final String url;
  final String image;

  @override
  List<Object?> get props => [name, url, image];
}
