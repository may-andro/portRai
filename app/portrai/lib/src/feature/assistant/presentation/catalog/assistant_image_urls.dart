final _urlPattern = RegExp(r'''https://[^\s"'\\<>]+''');

/// HTTPS URLs present in the portfolio context, the only images the model may show.
Set<String> assistantImageUrlsFrom(String portfolioContext) => {
  for (final match in _urlPattern.allMatches(portfolioContext)) match.group(0)!,
};
