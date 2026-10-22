import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/_sign_in.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/auth/presentation/screen/sign_in/bloc/mock_sign_in_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockSignInBloc> pumpSignInScreen(
    WidgetTester tester, {
    required String initialLocation,
  }) async {
    final bloc = MockSignInBloc();
    whenListen(
      bloc,
      Stream.value(const SignInState(isSignedIn: true)),
      initialState: const SignInState(),
    );
    await appServiceLocator.reset();
    addTearDown(appServiceLocator.reset);
    appServiceLocator.registerFactory<SignInBloc>(() => bloc);

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Home')),
        GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
        GoRoute(path: '/private', builder: (_, _) => const Text('Private')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('should add the started event when the screen is created', (
    tester,
  ) async {
    final bloc = await pumpSignInScreen(tester, initialLocation: '/sign-in');

    verify(() => bloc.add(const SignInStartedEvent())).called(1);
  });

  testWidgets('should open the requested location when signed in', (
    tester,
  ) async {
    await pumpSignInScreen(
      tester,
      initialLocation: '/sign-in?redirect=%2Fprivate',
    );

    expect(find.text('Private'), findsOneWidget);
  });

  testWidgets('should open the start page when signed in without a requested '
      'location', (tester) async {
    await pumpSignInScreen(tester, initialLocation: '/sign-in');

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('should open the start page when signed in with a link to '
      'another site', (tester) async {
    await pumpSignInScreen(
      tester,
      initialLocation: '/sign-in?redirect=https%3A%2F%2Fexample.com',
    );

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('should go back to the page before sign-in when back is '
      'pressed after signing in', (tester) async {
    final bloc = MockSignInBloc();
    whenListen(
      bloc,
      Stream.value(const SignInState(isSignedIn: true)),
      initialState: const SignInState(),
    );
    await appServiceLocator.reset();
    addTearDown(appServiceLocator.reset);
    appServiceLocator.registerFactory<SignInBloc>(() => bloc);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Settings')),
        GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
        GoRoute(path: '/private', builder: (_, _) => const Text('Private')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await tester.pumpAndSettle();

    unawaited(router.push('/sign-in?redirect=%2Fprivate'));
    await tester.pumpAndSettle();
    expect(find.text('Private'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
  });
}
