import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/assistant_launcher_widget.dart';

import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  for (final (local, remote) in [
    (false, false),
    (true, false),
    (false, true),
    (true, true),
  ]) {
    testWidgets(
      'should launch ${remote
          ? 'remote'
          : local
          ? 'local'
          : 'neither'} directly when availability is local=$local remote=$remote',
      (tester) async {
        final bloc = MockPortfolioBloc()
          ..stubState(
            LoadedState(
              portfolio: createPortfolioEntity(),
              isLocalAssistantAvailable: local,
              isRemoteAssistantAvailable: remote,
            ),
          );
        addTearDown(bloc.close);
        var localClicks = 0;
        var remoteClicks = 0;
        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<PortfolioBloc>.value(
              value: bloc,
              child: Scaffold(
                floatingActionButton: AssistantLauncherWidget(
                  onLocalLaunch: () => localClicks++,
                  onRemoteLaunch: () => remoteClicks++,
                ),
              ),
            ),
          ),
        );
        if (!local && !remote) {
          expect(find.byType(FloatingActionButton), findsNothing);
          return;
        }
        await tester.tap(find.byType(FloatingActionButton));
        expect(localClicks, local && !remote ? 1 : 0);
        expect(remoteClicks, remote ? 1 : 0);
        expect(find.byType(BottomSheet), findsNothing);
        verify(
          () => bloc.add(AssistantLaunchClickEvent(isLocal: local && !remote)),
        ).called(1);
      },
    );
  }
}
