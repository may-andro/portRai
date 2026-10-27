import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/bloc/_bloc.dart';

import '../../../../../../../mock/feature/design_system/presentation/widget/design_system_card/tracking/mock_design_system_card_tracking_delegate.dart';

void main() {
  group('DesignSystemCardBloc', () {
    late MockDesignSystemCardTrackingDelegate tracking;

    DesignSystemCardBloc buildBloc() => DesignSystemCardBloc(tracking);

    setUp(() => tracking = MockDesignSystemCardTrackingDelegate());

    blocTest<DesignSystemCardBloc, DesignSystemCardState>(
      'should track the tap without changing the state when the card is '
      'tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(const DesignSystemCardClickEvent('theme_card')),
      expect: () => const <DesignSystemCardState>[],
      verify: (_) =>
          verify(() => tracking.trackThemeGalleryClick('theme_card')).called(1),
    );
  });
}
