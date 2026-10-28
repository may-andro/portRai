part of '../professional_summary_widget.dart';

/// For recruiters: availability, logistics and the numbers up front, with the
/// resume as the main action and scheduling an appointment, while scheduling is on.
class HiringProfessionalSummary extends ProfessionalSummaryVariant {
  const HiringProfessionalSummary();

  @override
  String headline(ProfileEntity profile) => profile.title;

  @override
  String pitch(ProfileEntity profile) => profile.elevatorPitch;

  @override
  Widget buildBody(BuildContext context, ProfessionalSummaryScope scope) {
    final padding = scope.bodyHasHorizontalPadding;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _AvailabilityCardWidget(
          profile: scope.profile,
          isVisible: scope.isVisible,
          hasHorizontalPadding: padding,
        ),
        const DSVerticalSpacerWidget(2),
        Padding(
          padding: padding ? context.horizontalScreenPadding : EdgeInsets.zero,
          child: Wrap(
            spacing: context.space(factor: 2),
            runSpacing: context.space(factor: 1.5),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _HireButtonWidget(
                isVisible: scope.isVisible,
                hasHorizontalPadding: false,
                resumeFirst: true,
                offerScheduleAppointment: true,
              ),
              _SocialLinksWidget(
                names: const {'linkedin'},
                socialLinkSize: context.space(factor: scope.isMobile ? 6 : 4),
                isVisible: scope.isVisible,
                hasHorizontalPadding: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
