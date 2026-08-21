import 'dart:math';
import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/_widget.dart';
import 'package:tracking/tracking.dart';

part 'mobile_tablet_content_widget.dart';

part 'desktop_content_widget.dart';

part 'name_title_widget.dart';

part 'section_widget.dart';

part 'profile_image_widget.dart';

part 'social_links_section_widget.dart';

part 'education_section_widget.dart';

part 'about_me_section_widget.dart';

part 'contact_section_widget.dart';

part 'availability_section_widget.dart';

part 'language_section_widget.dart';

part 'intro_section_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          final LoadingState _ => const _LoadingWidget(),
          final LoadedState state => _SuccessWidget(profile: state.profile),
          final ErrorState state => _ErrorWidget(
            message: FailureTranslator.translate(context, state.failure),
          ),
        };
      },
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'profile_loading_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.loading()),
      child: DSLoadingWidget(
        size: max(context.shortestSide * 0.1, context.space(factor: 2)),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'profile_error_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.error()),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: DSErrorCardWidget(message: message),
        ),
      ),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'profile_success_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: DSResponsiveContainerWidget(
        mobileBuilder: (_) => _MobileTabletContentWidget(profile),
        tabletBuilder: (_) => _MobileTabletContentWidget(profile),
        desktopBuilder: (_) => _DesktopContentWidget(profile),
      ),
    );
  }
}

extension on BuildContext {
  EdgeInsets get horizontalScreenPadding {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return EdgeInsets.symmetric(horizontal: space(factor: 3));
      case DSDeviceResolution.tablet:
        return EdgeInsets.symmetric(horizontal: space(factor: 5));
      case DSDeviceResolution.desktop:
        return EdgeInsets.zero;
    }
  }
}
