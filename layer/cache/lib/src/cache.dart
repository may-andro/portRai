import 'package:meta/meta.dart';

@internal
abstract class Cache {
  int get lastCachedTimestamp;

  Duration get timeToLive => Duration.zero;

  /// When a value cached at [cachedAt] expires, or `null` when it never does.
  ///
  /// Defaults to [timeToLive] after [cachedAt]. Override it for an expiry a
  /// fixed duration cannot express, such as the end of the month the value
  /// was cached in.
  DateTime? expiryOf(DateTime cachedAt) =>
      timeToLive == Duration.zero ? null : cachedAt.add(timeToLive);

  @visibleForTesting
  @protected
  bool get isExpired => isExpiredAt(lastCachedTimestamp);

  /// Whether a value cached at [cachedTimestamp], in milliseconds since the
  /// epoch, has passed its [expiryOf].
  @protected
  bool isExpiredAt(int cachedTimestamp) {
    final expiry = expiryOf(
      DateTime.fromMillisecondsSinceEpoch(cachedTimestamp),
    );
    return expiry != null && DateTime.now().isAfter(expiry);
  }
}
