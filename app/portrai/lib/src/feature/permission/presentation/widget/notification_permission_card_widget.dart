import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

/// The Settings switch for the app's notifications. It shows the system
/// permission and changes it through the system prompt or the device
/// settings.
class NotificationPermissionCardWidget extends StatelessWidget {
  const NotificationPermissionCardWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => appServiceLocator.get<NotificationPermissionBloc>(),
    child: Builder(
      builder: (context) => RouteObserverWidget(
        // Also called when the card first appears.
        onResume: () =>
            context.bloc.add(const NotificationPermissionVisibleEvent()),
        child: _AppResumeListenerWidget(
          // The user may have changed the permission in the device settings.
          onResume: () =>
              context.bloc.add(const NotificationPermissionVisibleEvent()),
          child: const _ContentWidget(),
        ),
      ),
    ),
  );
}

class _ContentWidget extends StatelessWidget {
  const _ContentWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    return BlocBuilder<NotificationPermissionBloc, NotificationPermissionState>(
      builder: (context, state) => DSCardWidget(
        backgroundColor: palette.inverseSurface,
        radius: context.dimen.radiusLevel2,
        elevation: context.dimen.elevationLevel1,
        margin: EdgeInsets.only(bottom: context.space(factor: 2)),
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DSIconWidget(
                    Icons.notifications_outlined,
                    size: context.isMobile
                        ? DSIconSize.large
                        : DSIconSize.medium,
                    color: palette.neutral.grey1,
                  ),
                  const DSHorizontalSpacerWidget(2),
                  Expanded(
                    child: DSTextWidget(
                      localizations.notificationPermissionCardTitle,
                      color: palette.neutral.grey1,
                      style: context.typography.titleMedium,
                    ),
                  ),
                  Switch(
                    value: state.isAllowed,
                    onChanged: state.status == null
                        ? null
                        : (enabled) => context.bloc.add(
                            NotificationPermissionToggleClickEvent(
                              enabled: enabled,
                            ),
                          ),
                  ),
                ],
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                localizations.notificationPermissionCardDescription,
                color: palette.neutral.grey3,
                style: context.typography.bodyMedium,
              ),
              if (state.failure case final failure?) ...[
                const DSVerticalSpacerWidget(1),
                DSTextWidget(
                  FailureTranslator.translate(context, failure),
                  color: palette.semantic.error,
                  style: context.typography.labelMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppResumeListenerWidget extends StatefulWidget {
  const _AppResumeListenerWidget({required this.onResume, required this.child});

  final VoidCallback onResume;
  final Widget child;

  @override
  State<_AppResumeListenerWidget> createState() =>
      _AppResumeListenerWidgetState();
}

class _AppResumeListenerWidgetState extends State<_AppResumeListenerWidget> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: () => widget.onResume());
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
