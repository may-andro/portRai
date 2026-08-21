import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:tracking/tracking.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.state});

  final ExperiencesState state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExperiencesBloc, ExperiencesState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          final LoadingState _ => const _LoadingWidget(),
          final LoadedState state => _SuccessWidget(
            experiences: state.experiences,
            profile: state.profile,
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
      impressionId: 'experiences_loading_content_view',
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
      impressionId: 'experiences_loading_content_view',
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
  const _SuccessWidget({required this.experiences, this.profile});

  final List<ExperienceEntity> experiences;
  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'experiences_success_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: CustomScrollView(
        scrollBehavior: ScrollConfiguration.of(
          context,
        ).copyWith(scrollbars: false, overscroll: false),
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (!context.isDesktop) const _AppBarWidget(),
          if (context.isDesktop)
            const SliverToBoxAdapter(child: _HeaderWidget()),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              vertical: context.space(factor: 3),
              horizontal: context.horizontalPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: ExperienceListWidget(
                experiences: experiences,
                isVisible: true,
              ),
            ),
          ),
          if (profile case final ProfileEntity profile)
            SliverPadding(
              padding: EdgeInsets.only(top: context.space(factor: 3)),
              sliver: SliverToBoxAdapter(child: FooterWidget(profile: profile)),
            ),
        ],
      ),
    );
  }
}

class _AppBarWidget extends StatelessWidget {
  const _AppBarWidget();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: context.dimen.elevationNone.value,
      scrolledUnderElevation: context.dimen.elevationNone.value,
      backgroundColor: context.colorPalette.background.color,
      surfaceTintColor: context.colorPalette.neutral.transparent.color,
      shadowColor: context.colorPalette.brand.tertiary.color,
      automaticallyImplyLeading: !kIsWeb,
      centerTitle: true,
      title: DSTextWidget(
        'Experiences',
        color: context.colorPalette.neutral.grey9,
        style: kIsWeb
            ? context.typography.emphasizedTitleLarge
            : context.typography.emphasizedTitleMedium,
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.space(factor: 7),
      padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Image.asset(
              DSImage.logoPath,
              package: 'design_system',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  double get horizontalPadding {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 3);
      case DSDeviceResolution.tablet:
        return space(factor: 5);
      case DSDeviceResolution.desktop:
        return width * 0.15;
    }
  }
}
