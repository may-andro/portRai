final _urlPattern = RegExp(r'''https://[^\s"'\\<>]+''');

/// HTTPS URLs present in the portfolio context, the only images and links the model may use.
Set<String> assistantUrlsFrom(String portfolioContext) => {
  for (final match in _urlPattern.allMatches(portfolioContext)) match.group(0)!,
};
