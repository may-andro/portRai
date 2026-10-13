import 'dart:math';
import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/_widget.dart';
import 'package:tracking/tracking.dart';

part 'section_widget.dart';

part 'motion_widget.dart';

part 'hero_widget.dart';

part 'global_band_widget.dart';

part 'about_band_widget.dart';

part 'background_band_widget.dart';

part 'contact_band_widget.dart';

part 'body_widget.dart';

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
          final LoadedState state => _SuccessWidget(
            profile: state.profile,
            workPlaces: state.workPlaces,
          ),
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
  const _SuccessWidget({required this.profile, required this.workPlaces});

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'profile_success_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: _BodyWidget(profile: profile, workPlaces: workPlaces),
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
