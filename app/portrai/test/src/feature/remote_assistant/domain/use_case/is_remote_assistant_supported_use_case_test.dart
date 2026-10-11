import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/is_remote_assistant_supported_use_case.dart';

Future<bool> _isSupportedOn(TargetPlatform? platform) async {
  final previousPlatform = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform ?? previousPlatform;
  addTearDown(() {
    debugDefaultTargetPlatformOverride = previousPlatform;
  });

  final result = await IsRemoteAssistantSupportedUseCase()();
  expect(result.isRight, isTrue);
  return result.right;
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test(
      'should report support when the current platform is ${platform.name}',
      () async {
        expect(await _isSupportedOn(platform), isTrue);
      },
    );
  }

  test('should report support when running on web', () async {
    expect(await _isSupportedOn(null), isTrue);
  }, skip: !kIsWeb);

  for (final platform in [
    TargetPlatform.macOS,
    TargetPlatform.linux,
    TargetPlatform.windows,
  ]) {
    test(
      'should report unsupported when the current platform is ${platform.name}',
      () async {
        expect(await _isSupportedOn(platform), isFalse);
      },
      skip: kIsWeb,
    );
  }
}
