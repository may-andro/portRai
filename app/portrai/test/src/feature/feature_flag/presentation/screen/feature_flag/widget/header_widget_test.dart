import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/header_widget.dart';

import '../../../../../../../mock/feature/feature_flag/presentation/screen/feature_flag/bloc/mock_feature_flag_bloc.dart';
import '../../../../../../../mock/feature/feature_flag/test_data/feature_flag_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const SearchFeatureFlagsEvent('fallback'));
  });

  group('HeaderWidget', () {
    Future<void> pumpWidget(WidgetTester tester, FeatureFlagBloc bloc) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider.value(value: bloc, child: const HeaderWidget()),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'should render the localized result count when the state is loaded',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(
            const FeatureFlagLoadedState(
              allFeatureFlags,
              hasManipulatedFlags: true,
            ),
          );

        await pumpWidget(tester, bloc);

        final context = tester.element(find.byType(HeaderWidget));
        expect(
          find.text(context.localizations.featureFlagHeaderTitle(2)),
          findsOneWidget,
        );
        expect(
          find.text(context.localizations.featureFlagRestartRequiredMessage),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should dispatch a search event when the user types in the field',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadedState(allFeatureFlags));

        await pumpWidget(tester, bloc);
        await tester.enterText(find.byType(TextField), 'services');
        await tester.pump();

        verify(
          () => bloc.add(const SearchFeatureFlagsEvent('services')),
        ).called(1);
      },
    );

    testWidgets(
      'should populate the search field when the loaded state already has a query',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(
            const FeatureFlagLoadedState(
              allFeatureFlags,
              searchQuery: 'services',
            ),
          );

        await pumpWidget(tester, bloc);

        expect(find.text('services'), findsOneWidget);
      },
    );
  });
}
