import 'package:flutter/material.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/l10n/l10n.dart';

class SetupStatusInfoWidget extends StatelessWidget {
  const SetupStatusInfoWidget(this.receivedEvents, {super.key});

  final List<InjectionStatus> receivedEvents;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          _ItemWidget(receivedEvents, setUpStatus: InjectionStatus.start),
          const Divider(color: Colors.grey),
          _ItemWidget(receivedEvents, setUpStatus: InjectionStatus.register),
          const Divider(color: Colors.grey),
          _ItemWidget(
            receivedEvents,
            setUpStatus: InjectionStatus.postRegister,
          ),
          const Divider(color: Colors.grey),
          _ItemWidget(receivedEvents, setUpStatus: InjectionStatus.finished),
        ],
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget(this.receivedStatusList, {required this.setUpStatus});

  final List<InjectionStatus> receivedStatusList;
  final InjectionStatus setUpStatus;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: receivedStatusList.contains(setUpStatus)
          ? Icon(setUpStatus.icon, color: context.color, size: 24)
          : SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.color,
              ),
            ),
      title: Text(
        setUpStatus.getLabel(context),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
          height: 24 / 16,
          color: context.color,
        ),
      ),
    );
  }
}

extension on InjectionStatus {
  IconData get icon {
    switch (this) {
      case InjectionStatus.start:
        return Icons.start_rounded;
      case InjectionStatus.register:
        return Icons.download_rounded;
      case InjectionStatus.postRegister:
        return Icons.save_alt_rounded;
      case InjectionStatus.finished:
        return Icons.download_done_rounded;
    }
  }

  String getLabel(BuildContext context) {
    switch (this) {
      case InjectionStatus.start:
        return context.localizations.splashStagingStartMessage;
      case InjectionStatus.register:
        return context.localizations.splashStagingRegisteringMessage;
      case InjectionStatus.postRegister:
        return context.localizations.splashStagingPostRegisterMessage;
      case InjectionStatus.finished:
        return context.localizations.splashStagingDoneMessage;
    }
  }
}

extension on BuildContext {
  Color get color {
    return MediaQuery.of(this).platformBrightness == Brightness.light
        ? const Color(0xFF121212)
        : const Color(0xFFFFFFFF);
  }
}
