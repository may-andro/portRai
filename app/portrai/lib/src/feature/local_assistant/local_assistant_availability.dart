import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';

/// The browser LiteRT-LM runtime cannot run the assistant model yet, so the
/// assistant is only offered on native platforms.
bool get isLocalAssistantSupported => !kIsWeb;

@registerSingleton
class LocalAssistantAvailability {
  const LocalAssistantAvailability() : _supported = null;

  const LocalAssistantAvailability.supported(bool supported)
    : _supported = supported;

  final bool? _supported;

  bool get isSupported => _supported ?? isLocalAssistantSupported;
}
