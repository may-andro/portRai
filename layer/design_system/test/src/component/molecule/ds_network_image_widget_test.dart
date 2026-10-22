import 'dart:async';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:design_system/src/component/molecule/ds_network_image_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util/test_wrapper_widget.dart';

void main() {
  const connectivityChannel = EventChannel(
    'dev.fluttercommunity.plus/connectivity_status',
  );

  /// Calls [onListen] and [onCancel] when a connectivity subscription is
  /// made or cancelled on the platform side.
  void mockConnectivity(
    WidgetTester tester, {
    required void Function() onListen,
    void Function()? onCancel,
  }) {
    tester.binding.defaultBinaryMessenger.setMockStreamHandler(
      connectivityChannel,
      MockStreamHandler.inline(
        onListen: (_, _) => onListen(),
        onCancel: (_) => onCancel?.call(),
      ),
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockStreamHandler(
        connectivityChannel,
        null,
      ),
    );
  }

  Future<void> pumpImages(WidgetTester tester, List<Widget> images) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestWidgetWrapper(
        brightness: Brightness.light,
        designSystem: DesignSystem.values.first,
        child: Column(children: images),
      ),
    );
  }

  group('DSNetworkImageWidget', () {
    testWidgets('should request the decode size in physical pixels when the '
        'width and height are set', (tester) async {
      mockConnectivity(tester, onListen: () {});

      await pumpImages(tester, const [
        DSNetworkImageWidget(
          url: 'https://example.com/image.png',
          width: 100,
          height: 50,
          fit: BoxFit.cover,
        ),
      ]);

      final image = tester.widget<ExtendedImage>(find.byType(ExtendedImage));
      expect(
        image.image,
        isA<FittedResizeImage>()
            .having((provider) => provider.width, 'width', 200)
            .having((provider) => provider.height, 'height', 100)
            .having((provider) => provider.fit, 'fit', BoxFit.cover),
      );
    });

    testWidgets('should constrain only the known side when one side is set', (
      tester,
    ) async {
      mockConnectivity(tester, onListen: () {});

      await pumpImages(tester, const [
        DSNetworkImageWidget(url: 'https://example.com/image.png', width: 80),
      ]);

      final image = tester.widget<ExtendedImage>(find.byType(ExtendedImage));
      expect(
        image.image,
        isA<FittedResizeImage>()
            .having((provider) => provider.width, 'width', 160)
            .having((provider) => provider.height, 'height', isNull),
      );
    });

    testWidgets('should decode at full size when no size is set', (
      tester,
    ) async {
      mockConnectivity(tester, onListen: () {});

      await pumpImages(tester, const [
        DSNetworkImageWidget(
          url: 'https://example.com/image.png',
          fit: BoxFit.cover,
        ),
      ]);

      final image = tester.widget<ExtendedImage>(find.byType(ExtendedImage));
      expect(image.image, isA<ExtendedNetworkImageProvider>());
    });

    testWidgets('should share one connectivity subscription while images '
        'are shown and cancel it when the last one is removed', (tester) async {
      var listenCount = 0;
      var cancelCount = 0;
      mockConnectivity(
        tester,
        onListen: () => listenCount++,
        onCancel: () => cancelCount++,
      );

      await pumpImages(tester, [
        for (var imageIndex = 0; imageIndex < 3; imageIndex++)
          DSNetworkImageWidget(
            url: 'https://example.com/image_$imageIndex.png',
            width: 10,
            height: 10,
          ),
      ]);

      expect(listenCount, 1);
      expect(cancelCount, 0);

      await pumpImages(tester, const []);

      expect(cancelCount, 1);
    });
  });

  group('FittedResizeImage', () {
    const sourceProvider = AssetImage('image.png');

    for (final (fit, width, height, expectedWidth, expectedHeight) in [
      // A 1000 x 500 source into a 100 x 100 box.
      (BoxFit.cover, 100, 100, 200, 100),
      (BoxFit.fill, 100, 100, 200, 100),
      (BoxFit.contain, 100, 100, 100, 50),
      (BoxFit.scaleDown, 100, 100, 100, 50),
      (BoxFit.fitWidth, 100, 100, 100, 50),
      (BoxFit.fitHeight, 100, 100, 200, 100),
    ]) {
      test('should keep the aspect ratio when fitting with ${fit.name}', () {
        final provider = FittedResizeImage(
          sourceProvider,
          width: width,
          height: height,
          fit: fit,
        );

        final targetSize = provider.targetSize(1000, 500);

        expect(targetSize.width, expectedWidth);
        expect(targetSize.height, expectedHeight);
      });
    }

    test('should scale to the known side when only the height is set', () {
      const provider = FittedResizeImage(sourceProvider, height: 50);

      final targetSize = provider.targetSize(1000, 500);

      expect(targetSize.width, 100);
      expect(targetSize.height, 50);
    });

    test('should keep the intrinsic size when the box is larger than the '
        'source', () {
      const provider = FittedResizeImage(
        sourceProvider,
        width: 2000,
        height: 2000,
        fit: BoxFit.cover,
      );

      final targetSize = provider.targetSize(1000, 500);

      expect(targetSize.width, isNull);
      expect(targetSize.height, isNull);
    });

    testWidgets('should decode the image at the target size when resolved', (
      tester,
    ) async {
      final decodedImage = await tester.runAsync(() async {
        final pictureRecorder = ui.PictureRecorder();
        Canvas(pictureRecorder).drawRect(
          const Rect.fromLTWH(0, 0, 400, 200),
          Paint()..color = Colors.blue,
        );
        final sourceImage = await pictureRecorder.endRecording().toImage(
          400,
          200,
        );
        final pngBytes = await sourceImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        sourceImage.dispose();
        final provider = FittedResizeImage(
          MemoryImage(pngBytes!.buffer.asUint8List()),
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        );
        final imageStream = provider.resolve(ImageConfiguration.empty);
        final imageInfo = await imageStream.firstImage();
        return imageInfo;
      });

      expect(decodedImage!.image.width, 100);
      expect(decodedImage.image.height, 50);
      decodedImage.dispose();
    });
  });
}

extension on ImageStream {
  Future<ImageInfo> firstImage() {
    final imageCompleter = Completer<ImageInfo>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, _) {
        removeListener(listener);
        imageCompleter.complete(imageInfo);
      },
      onError: (error, stackTrace) {
        removeListener(listener);
        imageCompleter.completeError(error, stackTrace);
      },
    );
    addListener(listener);
    return imageCompleter.future;
  }
}
