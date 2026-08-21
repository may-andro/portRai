import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart' as meta;
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@meta.immutable
sealed class ProfessionalSummaryState extends Equatable {
  const ProfessionalSummaryState();

  @override
  List<Object> get props => [];
}

final class LoadingState extends ProfessionalSummaryState {
  const LoadingState();
}

final class LoadedState extends ProfessionalSummaryState {
  const LoadedState({required this.profile});

  final ProfileEntity profile;

  @override
  List<Object> get props => [profile];

  List<SocialLinkEntity> get appSocialLinks {
    final socialHandles = List<SocialLinkEntity>.from(profile.socialLinks);
    if (kIsWeb) {
      socialHandles.removeWhere(
        (socialHandle) => socialHandle.name == 'Portfolio',
      );
    }
    socialHandles.add(
      SocialLinkEntity(
        name: 'Resume',
        url: profile.resume.url,
        image: profile.resume.image,
      ),
    );

    return socialHandles;
  }
}
