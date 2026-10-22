import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/ai_image_gen/data/mapper/ai_image_background_remover.dart';

void main() {
  group('clearBackdrop', () {
    const size = 40;

    // White canvas with a dark closed ring around a white interior and a
    // coloured subject in the middle.
    Uint8List buildPixels({List<int> background = const [255, 255, 255]}) {
      final pixels = Uint8List(size * size * 4);
      for (var y = 0; y < size; y++) {
        for (var x = 0; x < size; x++) {
          final distance = (x - 20) * (x - 20) + (y - 20) * (y - 20);
          final color = switch (distance) {
            <= 16 => [200, 80, 40],
            <= 121 => [255, 255, 255],
            <= 196 => [20, 20, 20],
            _ => background,
          };
          final i = (y * size + x) * 4;
          pixels.setRange(i, i + 3, color);
          pixels[i + 3] = 255;
        }
      }
      return pixels;
    }

    int alphaAt(Uint8List p, int x, int y) => p[(y * size + x) * 4 + 3];
    int redAt(Uint8List p, int x, int y) => p[(y * size + x) * 4];

    test(
      'should make the outer background transparent when it is white',
      () async {
        final pixels = buildPixels();

        await clearBackdrop(pixels, width: size, height: size);

        expect(alphaAt(pixels, 0, 0), 0);
        expect(alphaAt(pixels, 39, 39), 0);
        expect(alphaAt(pixels, 0, 20), 0);
      },
    );

    test(
      'should keep enclosed white opaque when an outline surrounds it',
      () async {
        final pixels = buildPixels();

        await clearBackdrop(pixels, width: size, height: size);

        expect(alphaAt(pixels, 20, 12), 255);
        expect(redAt(pixels, 20, 12), 255);
      },
    );

    test(
      'should keep outline and subject colours when removing the background',
      () async {
        final pixels = buildPixels();

        await clearBackdrop(pixels, width: size, height: size);

        expect(alphaAt(pixels, 20, 7), 255);
        expect(redAt(pixels, 20, 7), lessThan(60));
        expect(alphaAt(pixels, 20, 20), 255);
        expect(redAt(pixels, 20, 20), 200);
      },
    );

    test(
      'should treat slightly off-white pixels as background when encoded lossy',
      () async {
        final pixels = buildPixels(background: [248, 250, 247]);

        await clearBackdrop(pixels, width: size, height: size);

        expect(alphaAt(pixels, 1, 1), 0);
      },
    );

    test(
      'should clear every backdrop pixel when the fill spans several slices',
      () async {
        // More pixels than one slice, so the fill yields to the event loop.
        const largeSize = 300;
        final pixels = Uint8List(largeSize * largeSize * 4)
          ..fillRange(0, largeSize * largeSize * 4, 255);

        await clearBackdrop(pixels, width: largeSize, height: largeSize);

        for (
          var pixelIndex = 0;
          pixelIndex < largeSize * largeSize;
          pixelIndex++
        ) {
          expect(pixels[pixelIndex * 4 + 3], 0);
        }
      },
    );
  });
}
