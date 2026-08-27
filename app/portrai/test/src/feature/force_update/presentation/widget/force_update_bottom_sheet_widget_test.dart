import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/force_update/presentation/widget/force_update_bottom_sheet_widget.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../mock/feature/force_update/domain/use_case/mock_get_app_store_url_use_case.dart';
import '../../../../../mock/feature/force_update/domain/use_case/mock_is_app_update_required_use_case.dart';
import '../../../../../mock/feature/force_update/presentation/tracking/mock_force_update_tracking_delegate.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOpenExternalUrlParam());
  });

  group('ForceUpdateBottomSheetWidget', () {
    // The bloc is intentionally created inside each `testWidgets` body
    // rather than in `setUp`. `setUp` runs outside the `FakeAsync` zone
    // that wraps a test body, and a `Bloc`'s internal `StreamController`
    // captures the zone it was created in - if it's built in `setUp`, its
    // event processing never synchronizes with the test's pumped clock,
    // and `pumpAndSettle` will not observe its async work completing.
    ({
      MockIsAppUpdateRequiredUseCase isAppUpdateRequiredUseCase,
      MockGetAppStoreUrlUseCase getAppStoreUrlUseCase,
      MockOpenExternalUrlUseCase openExternalUrlUseCase,
      MockForceUpdateTrackingDelegate trackingDelegate,
      ForceUpdateBloc bloc,
    })
    buildBloc() {
      final isAppUpdateRequiredUseCase = MockIsAppUpdateRequiredUseCase();
      final getAppStoreUrlUseCase = MockGetAppStoreUrlUseCase();
      final openExternalUrlUseCase = MockOpenExternalUrlUseCase();
      final trackingDelegate = MockForceUpdateTrackingDelegate();
      final bloc = ForceUpdateBloc(
        isAppUpdateRequiredUseCase: isAppUpdateRequiredUseCase,
        getAppStoreUrlUseCase: getAppStoreUrlUseCase,
        openExternalUrlUseCase: openExternalUrlUseCase,
        trackingDelegate: trackingDelegate,
      );
      return (
        isAppUpdateRequiredUseCase: isAppUpdateRequiredUseCase,
        getAppStoreUrlUseCase: getAppStoreUrlUseCase,
        openExternalUrlUseCase: openExternalUrlUseCase,
        trackingDelegate: trackingDelegate,
        bloc: bloc,
      );
    }

    Future<void> pumpWidget(WidgetTester tester, ForceUpdateBloc bloc) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider.value(
            value: bloc,
            child: const ForceUpdateBottomSheetWidget(),
          ),
        ),
      );
    }

    testWidgets('should show title, message and button when rendered', (
      tester,
    ) async {
      final deps = buildBloc();
      addTearDown(deps.bloc.close);

      await pumpWidget(tester, deps.bloc);

      final context = tester.element(find.byType(ForceUpdateBottomSheetWidget));
      expect(find.text(context.localizations.forceUpdateTitle), findsOneWidget);
      expect(
        find.text(context.localizations.forceUpdateMessage),
        findsOneWidget,
      );
      expect(
        find.text(context.localizations.forceUpdateButton),
        findsOneWidget,
      );
    });

    testWidgets('should open the store when the update button is tapped', (
      tester,
    ) async {
      final deps = buildBloc();
      addTearDown(deps.bloc.close);

      final storeUrl = Uri.parse('https://play.google.com/store/apps');
      deps.getAppStoreUrlUseCase.stubCall(
        Right<GetAppStoreUrlFailure, Uri>(storeUrl),
      );
      deps.openExternalUrlUseCase.stubCall(
        const Right<OpenExternalUrlFailure, bool>(true),
      );

      await pumpWidget(tester, deps.bloc);
      final context = tester.element(find.byType(ForceUpdateBottomSheetWidget));
      final finder = find.text(context.localizations.forceUpdateButton);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      verify(() => deps.getAppStoreUrlUseCase()).called(1);
      verify(() => deps.openExternalUrlUseCase(any())).called(1);
      verify(() => deps.trackingDelegate.trackUpdateNowClick()).called(1);
    });

    testWidgets('should show a snackbar when the store url can not be opened', (
      tester,
    ) async {
      final deps = buildBloc();
      addTearDown(deps.bloc.close);

      deps.getAppStoreUrlUseCase.stubCall(
        const Left<GetAppStoreUrlFailure, Uri>(
          GetAppStoreUrlUnknownFailure(cause: 'boom'),
        ),
      );

      await pumpWidget(tester, deps.bloc);
      final context = tester.element(find.byType(ForceUpdateBottomSheetWidget));
      await tester.tap(find.text(context.localizations.forceUpdateButton));
      await tester.pumpAndSettle();

      expect(
        find.text(context.localizations.errorForceUpdateStoreUrl),
        findsOneWidget,
      );
    });
  });
}
