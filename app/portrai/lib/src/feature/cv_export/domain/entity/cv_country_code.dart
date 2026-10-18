import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';

/// Short codes for the country names found in the (localized) portfolio data.
class CvCountryCode {
  const CvCountryCode._();

  static const Map<String, String> _codesByName = {
    'alemania': 'DE',
    'germany': 'DE',
    'duitsland': 'DE',
    'austria': 'AT',
    'oostenrijk': 'AT',
    'belgium': 'BE',
    'belgie': 'BE',
    'bélgica': 'BE',
    'españa': 'ES',
    'spain': 'ES',
    'spanje': 'ES',
    'estados unidos': 'US',
    'united states': 'US',
    'verenigde staten': 'US',
    'france': 'FR',
    'francia': 'FR',
    'frankrijk': 'FR',
    'india': 'IN',
    'italia': 'IT',
    'italy': 'IT',
    'italië': 'IT',
    'nederland': 'NL',
    'netherlands': 'NL',
    'países bajos': 'NL',
    'poland': 'PL',
    'polen': 'PL',
    'polonia': 'PL',
    'reino unido': 'GB',
    'united kingdom': 'GB',
    'verenigd koninkrijk': 'GB',
    'suiza': 'CH',
    'switzerland': 'CH',
    'zwitserland': 'CH',
    'turkey': 'TR',
    'turkije': 'TR',
    'turquía': 'TR',
  };

  static final RegExp _appStoreCountry = RegExp(
    r'apps\.apple\.com/([a-z]{2})/',
    caseSensitive: false,
  );

  /// The code of [market]: the storefront in its App Store link, which does
  /// not depend on the portfolio language, else the localized country name.
  static String ofMarket(ProjectMarketEntity market) {
    final storefront = market.appStore == null
        ? null
        : _appStoreCountry.firstMatch(market.appStore!)?.group(1);
    return storefront?.toUpperCase() ?? of(market.country);
  }

  /// The code of [countryName], or the name itself when it is unknown.
  static String of(String countryName) {
    return _codesByName[countryName.trim().toLowerCase()] ?? countryName.trim();
  }
}
