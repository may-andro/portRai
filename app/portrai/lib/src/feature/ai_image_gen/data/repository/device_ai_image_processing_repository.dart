import 'dart:typed_data';

import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/data/cache/_cache.dart';
import 'package:portrai/src/feature/ai_image_gen/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/exception/_exception.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/repository/_repository.dart';

@RegisterSingleton(as: AiImageProcessingRepository)
class DeviceAiImageProcessingRepository implements AiImageProcessingRepository {
  DeviceAiImageProcessingRepository(
    this._backgroundRemover,
    this._cache,
    this._mapper,
  );

  final AiImageBackgroundRemover _backgroundRemover;
  final AiImageCache _cache;
  final AiImageMapper _mapper;

  /// Requests still running, by cache key; duplicate calls share one request.
  final _runningRequestsByKey = <String, Future<AiImageEntity>>{};

  @override
  Future<AiImageEntity> removeBackground(AiImageEntity image) {
    final key = _cacheKey(image.bytes);
    return _runningRequestsByKey[key] ??= _process(image, key).whenComplete(() {
      // Must not return the removed future: whenComplete would await itself.
      _runningRequestsByKey.remove(key);
    });
  }

  Future<AiImageEntity> _process(AiImageEntity image, String key) async {
    final cached = await _readCache(key);
    if (cached != null) return cached;

    final AiImageEntity processed;
    try {
      final bytes = await _backgroundRemover.removeBackground(image.bytes);
      processed = AiImageEntity(bytes: bytes, mimeType: 'image/png');
    } on Object catch (error) {
      throw AiImageProcessingException(cause: error);
    }
    try {
      await _cache.put(_mapper.toModel(processed, key: key));
    } on Object catch (_) {
      // The image is still usable for this session when persisting fails.
    }
    return processed;
  }

  Future<AiImageEntity?> _readCache(String key) async {
    try {
      final model = await _cache.get(conditions: {'key': key});
      return model == null ? null : _mapper.map(model);
    } on Object catch (_) {
      return null;
    }
  }

  /// FNV-1a over the bytes, so a processed image is reused for the same input.
  String _cacheKey(Uint8List bytes) {
    var hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    return 'background-removed|${bytes.length}|$hash';
  }
}
