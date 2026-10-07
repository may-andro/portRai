part of 'content_widget.dart';

class _ContactSectionWidget extends StatelessWidget {
  const _ContactSectionWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return _SectionWidget(
      label: isDesktop
          ? context.localizations.profileContact
          : context.localizations.profileContactInformation,
      isDesktop: isDesktop,
      children: [
        DSLabeledInfoRowWidget(
          icon: Icons.email_rounded,
          label: context.localizations.profileEmail,
          value: profile.email,
          onTap: () {
            context.bloc.add(
              OpenExternalUrlEvent(
                url: 'mailto:${profile.email}',
                label: 'Email',
              ),
            );
          },
        ),
        DSLabeledInfoRowWidget(
          icon: Icons.location_on_rounded,
          label: context.localizations.profileLocation,
          value: '${profile.location.city}, ${profile.location.country}',
        ),
        DSLabeledInfoRowWidget(
          icon: Icons.access_time_rounded,
          label: context.localizations.profileTimezone,
          value: profile.location.timezone,
        ),
      ],
    );
  }
}
