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
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
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
  IntroSectionWidget({super.key, required super.portfolio})
    : super(trackingId: 'portfolio_intro_section');

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
        return ProfessionalSummaryWidget(
          profile: portfolio.profile,
          isVisible: isVisible,
          height: possibleViewPortHeight,
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
    return SectionContainerWidget(
      builder: (context, isVisible) {
        return ExpertiseListWidget(
          allExpertise: portfolio.expertises,
          isVisible: isVisible,
        );
      },
      visibilityKey: trackingId,
      title: getTitle(context),
      horizontalPadding: 0,
      background: const InverseSectionBackground(),
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionExpertises;
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
        );
      },
      visibilityKey: trackingId,
      title: getTitle(context),
      background: const InverseSectionBackground(),
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
              label: 'See All',
              onPressed: () {
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
      horizontalPadding: 0,
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
      horizontalPadding: 0,
    );
  }

  @override
  String getTitle(BuildContext context) {
    return context.localizations.portfolioSectionTestimonials;
  }
}

extension PortfolioExtension on PortfolioEntity {
  List<SectionWidget> get scrollableSections {
    final sections = <SectionWidget>[IntroSectionWidget(portfolio: this)];
    if (expertises.isNotEmpty) {
      sections.add(ExpertiseSectionWidget(portfolio: this));
    }
    if (projects.isNotEmpty) {
      sections.add(ProjectsSectionWidget(portfolio: this));
    }
    if (services.isNotEmpty) {
      sections.add(ServicesSectionWidget(portfolio: this));
    }
    if (experiences.isNotEmpty) {
      sections.add(ExperienceSectionWidget(portfolio: this));
    }
    sections.add(AboutMeSectionWidget(portfolio: this));
    if (testimonials.isNotEmpty) {
      sections.add(TestimonialsSectionWidget(portfolio: this));
    }
    return sections;
  }
}

extension on BuildContext {
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
