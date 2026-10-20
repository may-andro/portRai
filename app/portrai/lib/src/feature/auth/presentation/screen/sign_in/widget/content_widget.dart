import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';

class ContentWidget extends StatefulWidget {
  const ContentWidget({super.key});

  @override
  State<ContentWidget> createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    context.bloc.add(
      SignInClickEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        PageAppBarWidget(title: context.localizations.signInTitle),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.space(factor: 3)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.space(factor: 50),
                ),
                child: BlocBuilder<SignInBloc, SignInState>(
                  builder: (context, state) {
                    final isEnabled = !state.isSigningIn && !state.isSignedIn;
                    return AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: context.space(factor: 2),
                        children: [
                          DSTextWidget(
                            context.localizations.signInDescription,
                            style: context.typography.bodyLarge,
                            color: context.colorPalette.neutral.grey9,
                          ),
                          DSTextFieldWidget(
                            controller: _emailController,
                            labelText: context.localizations.signInEmailLabel,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            enabledBorderColor:
                                context.colorPalette.neutral.grey4,
                            enabled: isEnabled,
                          ),
                          DSTextFieldWidget(
                            controller: _passwordController,
                            labelText:
                                context.localizations.signInPasswordLabel,
                            textFieldType: TextFieldType.password,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            enabledBorderColor:
                                context.colorPalette.neutral.grey4,
                            enabled: isEnabled,
                            onFieldSubmitted: (_) => _signIn(),
                          ),
                          DSButtonWidget(
                            label: context.localizations.signInButton,
                            isLoading: state.isSigningIn,
                            isDisabled: !isEnabled,
                            onPressed: _signIn,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
