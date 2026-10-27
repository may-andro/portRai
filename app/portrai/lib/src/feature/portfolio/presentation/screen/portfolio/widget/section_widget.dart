import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/header/header_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_container_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/setting_button_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/user_role_summary_extension.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:tracking/tracking.dart';

sealed class SectionWidget extends StatelessWidget {
  SectionWidget({super.key, required this.trackingId, required this.portfolio})
    : sectionKey = GlobalKey();

  final String trackingId;
  final GlobalKey sectionKey;
  final PortfolioEntity portfolio;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: trackingId,
      onImpression: () => context.bloc.add(SectionVisibleEvent(trackingId)),
      child: KeyedSubtree(key: sectionKey, child: buildContent(context)),
    );
  }

  String getTitle(BuildContext context);

  @protected
  Widget buildContent(BuildContext context);
}

// 1. Intro Section - Hero section with catchy phrase, pitch, social links
class IntroSectionWidget extends SectionWidget {
  IntroSectionWidget({super.key, required super.portfolio, this.userRole})
    : super(trackingId: 'portfolio_intro_section');

  final UserRole? userRole;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    double possibleViewPortHeight =
        context.height -
        HeaderWidget.getHeight(context) -
        context.viewPadding.top;
    if (kIsWeb) {
      possibleViewPortHeight = max(
        context.height -
            HeaderWidget.getHeight(context) -
            context.viewPadding.top,
        context.space(factor: 100),
      );
    }

    return SectionContainerWidget(
      builder: (context, isVisible) {
        return Stack(
          children: [
            ProfessionalSummaryWidget(
              profile: portfolio.profile,
              isVisible: isVisible,
              height: possibleViewPortHeight,
              variant: userRole.summaryVariant(portfolio),
              projectImages: portfolio.projects
                  .map((project) => project.image)
                  .where((image) => image.isNotEmpty)
                  .toSet()
                  .toList(),
            ),
            if (context.isDesktop)
              Positioned(
                top: context.space(factor: 2),
                right: context.space(factor: 2),
                child: const SettingButtonWidget(),
              ),
          ],
        );
      },
      visibilityKey: trackingId,
      horizontalPadding: 0,
      hasBottomPadding: false,
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionIntroduction;
  }
}

// 2. Expertise Section - Skills and technical expertise
class ExpertiseSectionWidget extends SectionWidget {
  ExpertiseSectionWidget({super.key, required super.portfolio})
    : super(trackingId: 'portfolio_expertises_section');

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return _ExpertiseSectionBodyWidget(
      expertises: portfolio.expertises,
      visibilityKey: trackingId,
      title: getTitle(context),
      action: context.isDesktop
          ? null
          : SectionAction(
              label: context.localizations.portfolioSectionSeeAll,
              onPressed: () {
                context.bloc.add(
                  const SeeAllClickEvent(
                    label: 'see_all_button',
                    sectionName: 'expertises',
                  ),
                );
                ExpertisesScreen.navigate(context);
              },
            ),
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionExpertises;
  }
}

/// Keeps the selected expertise so the orbit and the section background detail
/// stay in sync.
class _ExpertiseSectionBodyWidget extends StatefulWidget {
  const _ExpertiseSectionBodyWidget({
    required this.expertises,
    required this.visibilityKey,
    required this.title,
    required this.action,
  });

  final List<ExpertiseEntity> expertises;
  final String visibilityKey;
  final String title;
  final SectionAction? action;

  @override
  State<_ExpertiseSectionBodyWidget> createState() =>
      _ExpertiseSectionBodyWidgetState();
}

class _ExpertiseSectionBodyWidgetState
    extends State<_ExpertiseSectionBodyWidget> {
  final _selection = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionContainerWidget(
      builder: (context, isVisible) {
        return ExpertiseOrbitWidget(
          expertises: widget.expertises,
          isVisible: isVisible,
          selection: _selection,
        );
      },
      backgroundDetail: (context, isVisible) {
        return ExpertiseOrbitBackdropWidget(
          expertises: widget.expertises,
          selection: _selection,
          isVisible: isVisible,
        );
      },
      visibilityKey: widget.visibilityKey,
      title: widget.title,
      // The orbit's mobile dial reaches the screen edges and pads itself.
      horizontalPadding: context.isMobile ? 0 : null,
      background: const InverseSectionBackground(),
      action: widget.action,
    );
  }
}

// 3. Projects Section - Showcase of projects
class ProjectsSectionWidget extends SectionWidget {
  ProjectsSectionWidget({super.key, required super.portfolio})
    : super(trackingId: 'portfolio_projects_section');

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return SectionContainerWidget(
      builder: (context, isVisible) {
        return ProjectListWidget(
          projects: portfolio.projects,
          isVisible: isVisible,
        );
      },
      visibilityKey: trackingId,
      title: getTitle(context),
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionProjects;
  }
}

// 4. Services Section - What services can be provided
class ServicesSectionWidget extends SectionWidget {
  ServicesSectionWidget({super.key, required super.portfolio})
    : super(trackingId: 'portfolio_services_section');

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return SectionContainerWidget(
      builder: (context, isVisible) {
        return ServiceListWidget(
          services: portfolio.services,
          isVisible: isVisible,
          visibleItemsCount: context.allowedServiceCount,
        );
      },
      visibilityKey: trackingId,
      title: getTitle(context),
      background: const InverseSectionBackground(),
      action: context.isDesktop
          ? null
          : SectionAction(
              label: context.localizations.portfolioSectionSeeAll,
              onPressed: () {
                context.bloc.add(
                  const SeeAllClickEvent(
                    label: 'see_all_button',
                    sectionName: 'services',
                  ),
                );
                ServicesScreen.navigate(context);
              },
            ),
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionServices;
  }
}

// 5. Experience Section - Professional experience
class ExperienceSectionWidget extends SectionWidget {
  ExperienceSectionWidget({super.key, required super.portfolio})
    : super(trackingId: 'portfolio_experience_section');

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return SectionContainerWidget(
      builder: (context, isVisible) {
        return ExperienceListWidget(
          experiences: portfolio.experiences,
          isVisible: isVisible,
          visibleItemsCount: context.allowedExperienceCount,
        );
      },
      visibilityKey: trackingId,
      title: getTitle(context),
      action: context.isDesktop
          ? null
          : SectionAction(
              label: context.localizations.portfolioSectionSeeAll,
              onPressed: () {
                context.bloc.add(
                  const SeeAllClickEvent(
                    label: 'see_all_button',
                    sectionName: 'experiences',
                  ),
                );
                ExperiencesScreen.navigate(context);
              },
            ),
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionExperience;
  }
}

// 6. About Me Section - Detailed personal information
class AboutMeSectionWidget extends SectionWidget {
  AboutMeSectionWidget({super.key, required super.portfolio})
    : super(trackingId: 'portfolio_about_section');

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return SectionContainerWidget(
      builder: (context, isVisible) {
        return PersonalSummaryWidget(
          profile: portfolio.profile,
          isVisible: isVisible,
        );
      },
      visibilityKey: trackingId,
      hasBottomPadding: false,
      title: getTitle(context),
      background: const InverseSectionBackground(),
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionAboutMe;
  }
}

// 7. Testimonials Section
class TestimonialsSectionWidget extends SectionWidget {
  TestimonialsSectionWidget({super.key, required super.portfolio})
    : super(trackingId: 'portfolio_testimonials_section');

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return SectionContainerWidget(
      builder: (context, isVisible) {
        return TestimonialListWidget(
          testimonials: portfolio.testimonials,
          isVisible: isVisible,
        );
      },
      visibilityKey: trackingId,
      title: getTitle(context),
      action: portfolio.testimonials.length > maxPreviewTestimonials
          ? SectionAction(
              label: context.localizations.portfolioSectionSeeAll,
              onPressed: () {
                context.bloc.add(
                  const SeeAllClickEvent(
                    label: 'see_all_button',
                    sectionName: 'testimonials',
                  ),
                );
                TestimonialListWidget.showAll(context, portfolio.testimonials);
              },
            )
          : null,
      horizontalPadding: 0,
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionTestimonials;
  }
}

extension PortfolioExtension on PortfolioEntity {
  List<SectionWidget> get scrollableSections => sectionsFor(null);

  /// Static, free personalization: the intro stays first and the remaining
  /// sections are ordered by what the role cares about. Expertise, services and
  /// about use the inverse background and the others the surface one, so every
  /// order must alternate between the two groups, starting with an inverse
  /// section. Empty sections are skipped.
  List<SectionWidget> sectionsFor(UserRole? userRole) {
    final order = switch (userRole) {
      UserRole.developer => _SectionKind.developerOrder,
      UserRole.recruiter => _SectionKind.recruiterOrder,
      UserRole.other || null => _SectionKind.defaultOrder,
    };
    return [
      IntroSectionWidget(portfolio: this, userRole: userRole),
      for (final kind in order)
        if (_buildSection(kind) case final SectionWidget section) section,
    ];
  }

  SectionWidget? _buildSection(_SectionKind kind) => switch (kind) {
    _SectionKind.expertise when expertises.isNotEmpty => ExpertiseSectionWidget(
      portfolio: this,
    ),
    _SectionKind.projects when projects.isNotEmpty => ProjectsSectionWidget(
      portfolio: this,
    ),
    _SectionKind.services when services.isNotEmpty => ServicesSectionWidget(
      portfolio: this,
    ),
    _SectionKind.experience when experiences.isNotEmpty =>
      ExperienceSectionWidget(portfolio: this),
    _SectionKind.about => AboutMeSectionWidget(portfolio: this),
    _SectionKind.testimonials when testimonials.isNotEmpty =>
      TestimonialsSectionWidget(portfolio: this),
    _ => null,
  };
}

enum _SectionKind {
  expertise,
  projects,
  services,
  experience,
  about,
  testimonials;

  static const defaultOrder = [
    expertise,
    projects,
    services,
    experience,
    about,
    testimonials,
  ];

  static const developerOrder = [
    expertise,
    projects,
    about,
    experience,
    services,
    testimonials,
  ];

  static const recruiterOrder = [
    expertise,
    experience,
    about,
    projects,
    services,
    testimonials,
  ];
}

extension on BuildContext {
  int? get allowedServiceCount {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return 3;
      case DSDeviceResolution.tablet:
        return 4;
      case DSDeviceResolution.desktop:
        return null;
    }
  }

  int? get allowedExperienceCount {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return 3;
      case DSDeviceResolution.tablet:
        return 4;
      case DSDeviceResolution.desktop:
        return null;
    }
  }
}
