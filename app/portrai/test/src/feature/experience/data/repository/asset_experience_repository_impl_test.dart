import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/experience/data/repository/asset_experience_repository_impl.dart';

import '../../../../../mock/feature/asset_source/domain/use_case/mock_get_asset_source_use_case.dart';
import '../../../../../mock/feature/experience/domain/repository/mock_experience_repository.dart';
import '../../../../../mock/utility/fake_error_reporter.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  final appLocale = AppLocale('en');

  group('AssetExperienceRepositoryImpl', () {
    late MockExperienceRepository cacheDelegateRepository;
    late MockGetAssetSourceUseCase getAssetSourceUseCase;
    late AssetExperienceRepositoryImpl repository;

    setUp(() {
      cacheDelegateRepository = MockExperienceRepository();
      getAssetSourceUseCase = MockGetAssetSourceUseCase();
      repository = AssetExperienceRepositoryImpl(
        appLocale,
        cacheDelegateRepository,
        ExperienceMapper(appLocale: appLocale),
        MockLogReporter(),
        FakeErrorReporter(),
        getAssetSourceUseCase,
      );
    });

    test('should leave the cache untouched when refreshed', () async {
      await repository.refreshExperiences();

      verifyZeroInteractions(cacheDelegateRepository);
      verifyZeroInteractions(getAssetSourceUseCase);
    });
  });
}
