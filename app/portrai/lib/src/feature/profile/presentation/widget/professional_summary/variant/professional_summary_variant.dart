part of '../professional_summary_widget.dart';

/// What a variant needs to know about where and how it is being rendered.
class ProfessionalSummaryScope {
  const ProfessionalSummaryScope({
    required this.profile,
    required this.isVisible,
    required this.resolution,
  });

  final ProfileEntity profile;
  final bool isVisible;
  final DSDeviceResolution resolution;

  bool get isMobile => resolution == DSDeviceResolution.mobile;

  bool get isTablet => resolution == DSDeviceResolution.tablet;

  bool get isDesktop => resolution == DSDeviceResolution.desktop;

  /// Whether the full-width header has to add the screen padding itself.
  bool get headerHasHorizontalPadding => !isDesktop;

  /// Whether the body has to add the screen padding itself. On tablet and
  /// desktop the layout already insets it.
  bool get bodyHasHorizontalPadding => isMobile;
}

/// One way of presenting the professional summary to a kind of visitor.
///
/// The surrounding layout owns the size of the section and the profile image;
/// a variant only designs what goes in the text area. To support a new
/// audience, add a subclass and map the role to it where the summary is built.
abstract class ProfessionalSummaryVariant {
  const ProfessionalSummaryVariant();

  String headline(ProfileEntity profile);

  String pitch(ProfileEntity profile);

  /// Full-width area on top: eyebrow, headline and, beyond mobile, the pitch.
  Widget buildHeader(BuildContext context, ProfessionalSummaryScope scope) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _EyebrowWidget(
          profile: scope.profile,
          isVisible: scope.isVisible,
          hasHorizontalPadding: scope.headerHasHorizontalPadding,
        ),
        DSVerticalSpacerWidget(scope.isMobile ? 1 : 2),
        _UniquePropositionWidget(
          label: headline(scope.profile),
          isVisible: scope.isVisible,
          hasHorizontalPadding: scope.headerHasHorizontalPadding,
        ),
        if (!scope.isMobile) ...[
          const DSVerticalSpacerWidget(3),
          _ElevatorPitchWidget(
            label: pitch(scope.profile),
            isVisible: scope.isVisible,
            hasHorizontalPadding: scope.headerHasHorizontalPadding,
          ),
        ],
      ],
    );
  }

  /// Whether the tablet layout sizes itself to the body instead of using a
  /// fixed height, for bodies that can outgrow it.
  bool get hasFlexibleTabletHeight => false;

  /// Actions shown under the body and the visual in the flexible tablet
  /// layout. Variants that show their actions inside the body leave it empty.
  Widget buildTabletActions(
    BuildContext context,
    ProfessionalSummaryScope scope,
  ) => const SizedBox.shrink();

  /// What fills the area next to the body. The profile image by default.
  Widget buildVisual(BuildContext context, ProfessionalSummaryScope scope) {
    return _ProfileImageWidget(
      profile: scope.profile,
      isVisible: scope.isVisible,
    );
  }

  /// What fills the section background. The project collage by default.
  Widget buildBackdrop(
    BuildContext context, {
    required bool isVisible,
    required List<String> projectImages,
  }) {
    return _ProjectBackdropWidget(
      imageUrls: projectImages,
      isVisible: isVisible,
    );
  }

  /// Area below the header, next to the profile image beyond mobile.
  Widget buildBody(BuildContext context, ProfessionalSummaryScope scope);
}
