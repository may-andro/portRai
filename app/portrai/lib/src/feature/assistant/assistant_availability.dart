import 'package:flutter/foundation.dart';

/// The browser LiteRT-LM runtime cannot run the assistant model yet, so the
/// assistant is only offered on native platforms.
bool get isAssistantSupported => !kIsWeb;
