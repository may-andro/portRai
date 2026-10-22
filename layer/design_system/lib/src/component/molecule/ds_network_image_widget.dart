import 'dart:async';
import 'dart:math';
import 'dart:ui' show TargetImageSize;

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/color/color.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DSNetworkImageWidget extends StatefulWidget {
  const DSNetworkImageWidget({
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.shape,
    this.borderRadius,
    this.autoSizeImage = false,
    this.loadingWidget,
    this.errorWidget,
    this.color,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BoxShape? shape;
  final BorderRadius? borderRadius;
  final bool autoSizeImage;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final DSColor? color;

  @override
  State<DSNetworkImageWidget> createState() => _DSNetworkImageWidgetState();
}

class _DSNetworkImageWidgetState extends State<DSNetworkImageWidget> {
  ExtendedImageState? imageState;
  late StreamSubscription<void> _connectionRestoredSubscription;

  @override
  void initState() {
    super.initState();
    _connectionRestoredSubscription = _connectionRestoredController.stream
        .listen((_) {
          if (imageState?.extendedImageLoadState == LoadState.failed) {
            imageState?.reLoadImage();
          }
        });
  }

  @override
  void dispose() {
    _connectionRestoredSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.url;
    if (imageUrl.isEmpty) {
      return _ErrorWidget(height: widget.height, width: widget.width);
    }

    return ExtendedImage(
      image: _imageProvider(context, imageUrl),
      enableLoadState: true,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      shape: widget.shape,
      color: widget.color?.color,
      borderRadius: widget.borderRadius,
      loadStateChanged: (ExtendedImageState state) {
        imageState = state;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return widget.loadingWidget ??
                const Center(child: CircularProgressIndicator());
          case LoadState.completed:
            if (widget.autoSizeImage) {
              return AspectRatio(
                aspectRatio:
                    state.extendedImageInfo!.image.width /
                    state.extendedImageInfo!.image.height,
                child: ExtendedRawImage(
                  image: state.extendedImageInfo?.image,
                  fit: widget.fit,
                ),
              );
            }
            return state.completedWidget;
          case LoadState.failed:
            return widget.errorWidget ??
                _ErrorWidget(
                  height: widget.height,
                  width: widget.width,
                  onTap: state.reLoadImage,
                );
        }
      },
    );
  }

  /// Decodes the image at the size it is painted when [DSNetworkImageWidget]
  /// has a width or height, instead of at the full size of the file.
  ImageProvider<Object> _imageProvider(BuildContext context, String imageUrl) {
    final networkImageProvider = ExtendedNetworkImageProvider(
      imageUrl,
      cache: true,
    );
    final fit = widget.fit ?? BoxFit.scaleDown;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final decodeWidth = _physicalPixels(widget.width, devicePixelRatio);
    final decodeHeight = _physicalPixels(widget.height, devicePixelRatio);
    if (fit == BoxFit.none || (decodeWidth == null && decodeHeight == null)) {
      return networkImageProvider;
    }
    return FittedResizeImage(
      networkImageProvider,
      width: decodeWidth,
      height: decodeHeight,
      fit: fit,
    );
  }

  int? _physicalPixels(double? logicalPixels, double devicePixelRatio) {
    if (logicalPixels == null ||
        !logicalPixels.isFinite ||
        logicalPixels <= 0) {
      return null;
    }
    return (logicalPixels * devicePixelRatio).ceil();
  }
}

StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

/// Notifies when the device goes back online. Every [DSNetworkImageWidget]
/// listens to this one stream, which holds a single connectivity subscription
/// while at least one image is shown.
final StreamController<void> _connectionRestoredController =
    StreamController<void>.broadcast(
      onListen: () {
        _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
          (connectivityResults) {
            if (connectivityResults.none(
              (connectivityResult) =>
                  connectivityResult == ConnectivityResult.none,
            )) {
              _connectionRestoredController.add(null);
            }
          },
        );
      },
      onCancel: () {
        _connectivitySubscription?.cancel();
        _connectivitySubscription = null;
      },
    );

/// Decodes [imageProvider] at the smallest size that still fills the area it
/// is painted in when fitted with [fit] into a box of [width] by [height]
/// physical pixels.
///
/// The decoded image keeps the aspect ratio of the source and is never larger
/// than the source. When only one of [width] and [height] is set, the image
/// is scaled to that side.
@visibleForTesting
@immutable
class FittedResizeImage extends ImageProvider<Object> {
  const FittedResizeImage(
    this.imageProvider, {
    this.width,
    this.height,
    this.fit = BoxFit.scaleDown,
  }) : assert(width != null || height != null);

  final ImageProvider<Object> imageProvider;
  final int? width;
  final int? height;
  final BoxFit fit;

  @override
  Future<Object> obtainKey(ImageConfiguration configuration) {
    return imageProvider
        .obtainKey(configuration)
        .then(
          (providerKey) => _FittedResizeImageKey(
            providerKey: providerKey,
            width: width,
            height: height,
            fit: fit,
          ),
        );
  }

  @override
  ImageStreamCompleter loadImage(Object key, ImageDecoderCallback decode) {
    return imageProvider.loadImage((key as _FittedResizeImageKey).providerKey, (
      buffer, {
      getTargetSize,
    }) {
      assert(
        getTargetSize == null,
        'FittedResizeImage cannot wrap a provider that already resizes.',
      );
      return decode(buffer, getTargetSize: targetSize);
    });
  }

  /// The size to decode an image of [intrinsicWidth] by [intrinsicHeight]
  /// pixels at.
  TargetImageSize targetSize(int intrinsicWidth, int intrinsicHeight) {
    final widthScale = width == null ? null : width! / intrinsicWidth;
    final heightScale = height == null ? null : height! / intrinsicHeight;
    final scale = switch ((widthScale, heightScale)) {
      (final widthScale?, final heightScale?) => switch (fit) {
        BoxFit.cover || BoxFit.fill => max(widthScale, heightScale),
        BoxFit.contain || BoxFit.scaleDown => min(widthScale, heightScale),
        BoxFit.fitWidth => widthScale,
        BoxFit.fitHeight => heightScale,
        BoxFit.none => 1.0,
      },
      (final widthScale?, null) => widthScale,
      (null, final heightScale?) => heightScale,
      (null, null) => 1.0,
    };
    if (scale >= 1) return const TargetImageSize();
    return TargetImageSize(
      width: max(1, (intrinsicWidth * scale).ceil()),
      height: max(1, (intrinsicHeight * scale).ceil()),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FittedResizeImage &&
      other.imageProvider == imageProvider &&
      other.width == width &&
      other.height == height &&
      other.fit == fit;

  @override
  int get hashCode => Object.hash(imageProvider, width, height, fit);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'FittedResizeImage')}'
      '($imageProvider, width: $width, height: $height, fit: $fit)';
}

@immutable
class _FittedResizeImageKey {
  const _FittedResizeImageKey({
    required this.providerKey,
    required this.width,
    required this.height,
    required this.fit,
  });

  final Object providerKey;
  final int? width;
  final int? height;
  final BoxFit fit;

  @override
  bool operator ==(Object other) =>
      other is _FittedResizeImageKey &&
      other.providerKey == providerKey &&
      other.width == width &&
      other.height == height &&
      other.fit == fit;

  @override
  int get hashCode => Object.hash(providerKey, width, height, fit);
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({this.width, this.height, this.onTap});

  final double? width;
  final double? height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? double.infinity,
        width: width ?? double.infinity,
        color: context.colorPalette.neutral.transparent.color,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Icon(onTap != null ? Icons.refresh : Icons.broken_image);
          },
        ),
      ),
    );
  }
}
