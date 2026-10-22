import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/page_header_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/auth/presentation/screen/sign_in/bloc/mock_sign_in_bloc.dart';
import '../../../../../../../util/animated_page_test_util.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockSignInBloc> pumpContent(
    WidgetTester tester,
    SignInState state, {
    Size size = const Size(1440, 2400),
  }) async {
    setUpAnimatedPage(tester, size: size);
    final bloc = MockSignInBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: ScreenFooterProviderWidget(
          footer: const Text('footer'),
          child: BlocProvider<SignInBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      ),
    );
    await pumpAnimations(tester);
    return bloc;
  }

  testWidgets('should dispatch the entered credentials when sign in is '
      'tapped', (tester) async {
    final bloc = await pumpContent(tester, const SignInState());

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'owner@example.com');
    await tester.enterText(textFields.at(1), 'secret');
    await tester.tap(find.byType(DSButtonWidget));
    await tester.pump();

    verify(
      () => bloc.add(
        const SignInClickEvent(email: 'owner@example.com', password: 'secret'),
      ),
    ).called(1);
  });

  testWidgets('should disable the form when signing in', (tester) async {
    await pumpContent(tester, const SignInState(isSigningIn: true));

    final textFields = tester.widgetList<DSTextFieldWidget>(
      find.byType(DSTextFieldWidget),
    );
    expect(textFields.every((textField) => !textField.enabled), isTrue);
    final button = tester.widget<DSButtonWidget>(find.byType(DSButtonWidget));
    expect(button.isLoading, isTrue);
    expect(button.isDisabled, isTrue);
  });

  testWidgets('should welcome the user beside the form on a desktop', (
    tester,
  ) async {
    await pumpContent(tester, const SignInState());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Accounts are created by the site owner. There is no sign-up.'),
      findsOneWidget,
    );
    final welcome = tester.getTopLeft(find.text('Welcome back'));
    final email = tester.getTopLeft(find.text('Email'));
    expect(welcome.dx, lessThan(email.dx));
  });

  testWidgets('should show the welcome panel above the form on a phone', (
    tester,
  ) async {
    await pumpContent(tester, const SignInState());
    setUpAnimatedPage(tester, size: const Size(390, 1400));
    await pumpAnimations(tester);

    final welcome = tester.getTopLeft(find.text('Welcome back'));
    final email = tester.getTopLeft(find.text('Email'));
    expect(welcome.dy, lessThan(email.dy));
  });

  testWidgets('should end the shared scroll view with the screen footer when '
      'shown on a desktop', (tester) async {
    await pumpContent(tester, const SignInState());

    final scrollView = find.descendant(
      of: find.byType(ScreenContentWidget<SignInBloc, SignInState>),
      matching: find.byType(CustomScrollView),
    );
    expect(scrollView, findsOneWidget);
    expect(
      find.descendant(of: scrollView, matching: find.text('Email')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('footer', skipOffstage: false),
      200,
      scrollable: find
          .descendant(of: scrollView, matching: find.byType(Scrollable))
          .first,
    );
    expect(
      tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
      greaterThan(tester.getBottomLeft(find.byType(DSButtonWidget)).dy),
    );
    expect(find.byType(FooterWidget), findsNothing);
  });

  testWidgets('should end the shared scroll view with the screen footer when '
      'shown on a phone', (tester) async {
    await pumpContent(tester, const SignInState());
    setUpAnimatedPage(tester, size: const Size(390, 1400));
    await pumpAnimations(tester);

    final scrollView = find.descendant(
      of: find.byType(ScreenContentWidget<SignInBloc, SignInState>),
      matching: find.byType(CustomScrollView),
    );
    expect(
      find.descendant(of: scrollView, matching: find.text('Welcome back')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('footer', skipOffstage: false),
      200,
      scrollable: find
          .descendant(of: scrollView, matching: find.byType(Scrollable))
          .first,
    );
    expect(
      tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
      greaterThan(tester.getBottomLeft(find.byType(DSButtonWidget)).dy),
    );
    expect(find.byType(FooterWidget), findsNothing);
  });

  double logoLeft(WidgetTester tester) {
    return tester
        .getTopLeft(
          find.descendant(
            of: find.byType(PageHeaderWidget),
            matching: find.byType(Image),
          ),
        )
        .dx;
  }

  testWidgets(
    'should centre the welcome text under the illustration in the panel when '
    'shown side by side',
    (tester) async {
      await pumpContent(tester, const SignInState());

      // The panel takes 5 of the 9 columns of the 1440 wide window.
      const panelCentre = 1440 * 5 / 9 / 2;
      final illustration = find.byType(DSLottieIllustrationWidget).first;
      expect(tester.getCenter(illustration).dx, closeTo(panelCentre, 1));
      expect(
        tester.getCenter(find.text('Welcome back')).dx,
        closeTo(panelCentre, 1),
      );
      expect(
        tester.getTopLeft(find.text('Welcome back')).dy,
        greaterThan(tester.getBottomLeft(illustration).dy),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'should start the welcome text and the form where the logo starts when '
    'stacked',
    (tester) async {
      await pumpContent(
        tester,
        const SignInState(),
        size: const Size(400, 1600),
      );

      expect(tester.getTopLeft(find.text('Welcome back')).dx, logoLeft(tester));
      expect(
        tester.getTopLeft(find.byType(TextFormField).first).dx,
        logoLeft(tester),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'should show the side by side layout without overflow when the window is '
    'short',
    (tester) async {
      await pumpContent(
        tester,
        const SignInState(),
        size: const Size(1440, 800),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Welcome back'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'should lay the header over the welcome band and start the welcome text '
    'below it when stacked',
    (tester) async {
      await pumpContent(
        tester,
        const SignInState(),
        size: const Size(820, 1600),
      );

      final band = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient is LinearGradient,
      );
      final headerBottom = tester
          .getBottomLeft(find.byType(PageHeaderWidget))
          .dy;
      expect(tester.getTopLeft(band.first).dy, 0);
      expect(tester.getTopLeft(find.byType(PageHeaderWidget)).dy, 0);
      expect(
        tester.getTopLeft(find.text('Welcome back')).dy,
        greaterThan(headerBottom),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'should start the form where the logo starts on a tablet when stacked',
    (tester) async {
      await pumpContent(
        tester,
        const SignInState(),
        size: const Size(820, 1600),
      );

      expect(
        tester.getTopLeft(find.byType(TextFormField).first).dx,
        logoLeft(tester),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );
}
