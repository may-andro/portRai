import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/auth/presentation/route/auth_module_route.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final redirectLocation = AuthModuleRoute.redirectLocation(
      context.routeQueryParameters[AuthModuleRoute.redirectQueryParameter],
    );
    return ScreenScaffoldWidget<SignInBloc, SignInState>(
      onCreate: (bloc) => bloc.add(const SignInStartedEvent()),
      listenWhen: (previous, current) =>
          previous.isSignedIn != current.isSignedIn ||
          previous.failure != current.failure,
      listener: (context, state) {
        if (state.isSignedIn) {
          // Sign-in leaves the stack, so Back returns to where the user
          // came from instead of to this page.
          context.replaceLocation(redirectLocation);
          return;
        }
        if (state.failure case final failure?) {
          context.showSnackBar(
            snackBar: DSSnackBar(
              message: FailureTranslator.translate(context, failure),
              type: DSSnackBarType.error,
            ),
          );
        }
      },
      body: const ContentWidget(),
    );
  }
}
