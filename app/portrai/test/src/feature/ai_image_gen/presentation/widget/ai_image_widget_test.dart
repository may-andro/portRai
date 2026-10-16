import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/widget/ai_image_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../mock/feature/ai_image_gen/presentation/bloc/mock_ai_image_bloc.dart';

void main() {
  // A 1x1 transparent PNG.
  final pngBytes = Uint8List.fromList(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNgYGD4DwABBAEAfbLI3wAAAABJRU5ErkJggg==',
    ),
  );

  setUpAll(
    () => registerFallbackValue(const LoadImageEvent(sourceImageUrl: '')),
  );

  setUp(() => appServiceLocator.reset());

  tearDown(() => appServiceLocator.reset());

  Future<MockAiImageBloc> pumpWidget(
    WidgetTester tester,
    AiImageState state,
  ) async {
    final bloc = MockAiImageBloc()
      ..stubState(state)
      ..registerFactory();
    await tester.pumpWidget(
      const MaterialApp(
        home: AiImageWidget(
          sourceImageUrl: 'https://example.com/a.png',
          fallback: Text('fallback'),
        ),
      ),
    );
    return bloc;
  }

  testWidgets('should request the image when the widget is built', (
    tester,
  ) async {
    final bloc = await pumpWidget(tester, const LoadingState());

    verify(
      () => bloc.add(
        const LoadImageEvent(sourceImageUrl: 'https://example.com/a.png'),
      ),
    ).called(1);
  });

  testWidgets('should show fallback when the image is loading', (tester) async {
    await pumpWidget(tester, const LoadingState());

    expect(find.text('fallback'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('should show fallback when the image is unavailable', (
    tester,
  ) async {
    await pumpWidget(tester, const UnavailableState());

    expect(find.text('fallback'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('should show generated image when it is loaded', (tester) async {
    await pumpWidget(
      tester,
      LoadedState(
        image: AiImageEntity(bytes: pngBytes, mimeType: 'image/png'),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('fallback'), findsNothing);
  });
}
