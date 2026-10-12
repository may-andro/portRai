import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';

/// Makes the plain light backdrop of a generated illustration transparent.
///
/// Image models cannot output transparency, so the prompt asks for a flat
/// white background. Only light pixels connected to the image border are
/// removed, which keeps the white of eyes and teeth enclosed by outlines.
///
/// Decoding and encoding run on the engine's own threads and the pixel work
/// yields to the event loop, so the UI thread (the only one on web) stays
/// responsive.
@register
class AiImageBackgroundRemover {
  const AiImageBackgroundRemover();

  /// Longest edge, in pixels, the image is shrunk to before processing.
  static const maxDimension = 512;

  /// Returns PNG bytes with a transparent background.
  ///
  /// Throws when [bytes] cannot be decoded as an image.
  Future<Uint8List> removeBackground(Uint8List bytes) async {
    final decoded = await _decode(bytes);
    final pixels = await _toRgba(decoded);
    final width = decoded.width;
    final height = decoded.height;
    decoded.dispose();

    await clearBackdrop(pixels, width: width, height: height);
    return await _encodePng(pixels, width: width, height: height);
  }

  Future<ui.Image> _decode(Uint8List bytes) async {
    final ui.Image image;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    } on Object catch (error) {
      throw FormatException('Unsupported image data: $error');
    }
    final longest = math.max(image.width, image.height);
    if (longest <= maxDimension) return image;

    final scale = maxDimension / longest;
    final width = math.max(1, (image.width * scale).round());
    final height = math.max(1, (image.height * scale).round());
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
      image.dispose();
    }
  }

  Future<Uint8List> _toRgba(ui.Image image) async {
    final data = await image.toByteData();
    if (data == null) throw const FormatException('Unreadable image data.');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> _encodePng(
    Uint8List pixels, {
    required int width,
    required int height,
  }) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final image = await completer.future;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw const FormatException('Cannot encode image.');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }
}

/// Lowest channel value treated as part of the backdrop when flood filling.
const _backgroundThreshold = 232;

/// Below this lowest channel value an edge pixel is fully opaque.
const _opaqueThreshold = 190;

/// Pixels processed between two yields to the event loop.
const _pixelsPerSlice = 60000;

/// Clears the border-connected light backdrop of straight RGBA [pixels] in
/// place, softening the edge pixels next to it.
@visibleForTesting
Future<void> clearBackdrop(
  Uint8List pixels, {
  required int width,
  required int height,
}) async {
  final total = width * height;
  final removed = Uint8List(total);
  final stack = Int32List(total);
  var top = 0;

  bool isBackdrop(int pixel) {
    final i = pixel << 2;
    return pixels[i + 3] < 16 ||
        (pixels[i] >= _backgroundThreshold &&
            pixels[i + 1] >= _backgroundThreshold &&
            pixels[i + 2] >= _backgroundThreshold);
  }

  void seed(int pixel) {
    if (removed[pixel] == 0 && isBackdrop(pixel)) {
      removed[pixel] = 1;
      stack[top++] = pixel;
    }
  }

  for (var x = 0; x < width; x++) {
    seed(x);
    seed((height - 1) * width + x);
  }
  for (var y = 0; y < height; y++) {
    seed(y * width);
    seed(y * width + width - 1);
  }

  var budget = _pixelsPerSlice;
  Future<void> tick() async {
    if (--budget > 0) return;
    budget = _pixelsPerSlice;
    await Future<void>.delayed(Duration.zero);
  }

  while (top > 0) {
    final pixel = stack[--top];
    final x = pixel % width;
    if (x > 0) seed(pixel - 1);
    if (x < width - 1) seed(pixel + 1);
    if (pixel >= width) seed(pixel - width);
    if (pixel < total - width) seed(pixel + width);
    await tick();
  }

  bool touchesBackdrop(int x, int y) {
    final y0 = y > 0 ? y - 1 : 0;
    final y1 = y < height - 1 ? y + 1 : y;
    final x0 = x > 0 ? x - 1 : 0;
    final x1 = x < width - 1 ? x + 1 : x;
    for (var ny = y0; ny <= y1; ny++) {
      for (var nx = x0; nx <= x1; nx++) {
        if (removed[ny * width + nx] == 1) return true;
      }
    }
    return false;
  }

  // Edge pixels are a blend of artwork and white backdrop: derive their
  // opacity from how light they are and strip the white contribution.
  void soften(int pixel) {
    final i = pixel << 2;
    var lowest = pixels[i];
    if (pixels[i + 1] < lowest) lowest = pixels[i + 1];
    if (pixels[i + 2] < lowest) lowest = pixels[i + 2];
    if (lowest < _opaqueThreshold) return;
    final alpha = ((255 - lowest) / (255 - _opaqueThreshold)).clamp(0.05, 1.0);
    for (var c = 0; c < 3; c++) {
      final value = (pixels[i + c] - 255 * (1 - alpha)) / alpha;
      pixels[i + c] = value.clamp(0, 255).round();
    }
    pixels[i + 3] = (alpha * pixels[i + 3]).round();
  }

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = y * width + x;
      if (removed[pixel] == 1) {
        pixels[(pixel << 2) + 3] = 0;
      } else if (touchesBackdrop(x, y)) {
        soften(pixel);
      }
    }
    if (y % 16 == 0) await Future<void>.delayed(Duration.zero);
  }
}
