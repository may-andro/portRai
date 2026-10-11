import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';

/// Matches the platforms configured by DefaultFirebaseOptions.
bool get isRemoteAssistantSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

@registerSingleton
class RemoteAssistantAvailability {
  const RemoteAssistantAvailability() : _supported = null;

  const RemoteAssistantAvailability.supported(bool supported)
    : _supported = supported;

  final bool? _supported;

  bool get isSupported => _supported ?? isRemoteAssistantSupported;
}
