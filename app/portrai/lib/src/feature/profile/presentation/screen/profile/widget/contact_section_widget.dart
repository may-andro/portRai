part of 'content_widget.dart';

class _ContactSectionWidget extends StatelessWidget {
  const _ContactSectionWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return _SectionWidget(
      label: isDesktop ? 'Contact' : 'Contact Information',
      isDesktop: isDesktop,
      children: [
        DSLabeledInfoRowWidget(
          icon: Icons.email_rounded,
          label: 'Email',
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
          label: 'Location',
          value: '${profile.location.city}, ${profile.location.country}',
        ),
        DSLabeledInfoRowWidget(
          icon: Icons.access_time_rounded,
          label: 'Timezone',
          value: profile.location.timezone,
        ),
      ],
    );
  }
}
