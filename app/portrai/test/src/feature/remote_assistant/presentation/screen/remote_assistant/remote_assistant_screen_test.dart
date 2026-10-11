import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';

import '../../../../../../mock/feature/remote_assistant/presentation/screen/remote_assistant/bloc/mock_remote_assistant_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  testWidgets(
    'should recheck access without owning the session when the route is opened',
    (tester) async {
      final locator = ModuleInjectorController().serviceLocator;
      await locator.reset();
      addTearDown(locator.reset);
      final bloc = MockRemoteAssistantBloc()
        ..stubState(
          const RemoteAssistantState(status: RemoteAssistantStatus.unavailable),
        );
      addTearDown(bloc.close);
      locator.registerSingleton<RemoteAssistantBloc>(() => bloc);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Builder(
            builder: (context) =>
                RemoteAssistantModuleRoute.assistant.builder(context, null, {}),
          ),
        ),
      );
      verify(() => bloc.add(const RemoteAssistantStartedEvent())).called(1);
      expect(find.text('Cloud portfolio assistant'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      verifyNever(bloc.close);
    },
  );
}
