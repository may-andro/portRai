import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';

/// ISO country codes of project markets, read from the store links so they do
/// not depend on the (localized) country name in the portfolio data.
class CvCountryCode {
  const CvCountryCode._();

  static final RegExp _appStoreCountry = RegExp(
    r'apps\.apple\.com/([a-z]{2})/',
    caseSensitive: false,
  );

  static final RegExp _playStoreCountry = RegExp(
    r'[?&]gl=([a-z]{2})(?:&|$)',
    caseSensitive: false,
  );

  /// The code of [market] from its App Store (or Play Store) link, or `null`
  /// when the links carry none.
  static String? ofMarket(ProjectMarketEntity market) {
    final storefront =
        _match(_appStoreCountry, market.appStore) ??
        _match(_playStoreCountry, market.playStore);
    return storefront?.toUpperCase();
  }

  static String? _match(RegExp pattern, String? url) {
    if (url == null) return null;
    return pattern.firstMatch(url)?.group(1);
  }
}
