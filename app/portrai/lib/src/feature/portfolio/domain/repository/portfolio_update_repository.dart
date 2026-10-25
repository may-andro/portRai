import 'package:portrai/src/feature/portfolio/domain/entity/_entity.dart';

abstract class PortfolioUpdateRepository {
  /// When each section of the current locale last changed. Sections that
  /// never changed are left out.
  Future<Map<PortfolioSection, DateTime>> getChangeTimes();

  /// The change time each section of the current locale was last refreshed
  /// for. Sections never refreshed are left out.
  Future<Map<PortfolioSection, DateTime>> getAppliedChangeTimes();

  /// Records that [section] of the current locale was refreshed for the
  /// change at [changedAt].
  Future<void> setAppliedChangeTime(
    PortfolioSection section,
    DateTime changedAt,
  );

  /// The sections refreshed by each update that refreshed any.
  Stream<Set<PortfolioSection>> get refreshedSections;

  void reportRefreshedSections(Set<PortfolioSection> sections);
}
