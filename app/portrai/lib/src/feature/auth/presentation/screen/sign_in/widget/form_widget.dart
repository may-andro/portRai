part of 'content_widget.dart';

class _FormWidget extends StatefulWidget {
  const _FormWidget();

  @override
  State<_FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<_FormWidget> {
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
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final accent = palette.accent.color;

    return BlocBuilder<SignInBloc, SignInState>(
          builder: (context, state) {
            final isEnabled = !state.isSigningIn && !state.isSignedIn;
            return AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: context.space(factor: 2),
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent.withAlpha(36),
                        borderRadius: BorderRadius.circular(
                          context.dimen.radiusLevel2.value,
                        ),
                      ),
                      child: Icon(Icons.lock_rounded, size: 24, color: accent),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(factor: 0.75),
                    children: [
                      DSTextWidget(
                        localizations.signInTitle,
                        style: context.typography.emphasizedHeadlineMedium,
                        color: palette.neutral.grey10,
                      ),
                      DSTextWidget(
                        localizations.signInDescription,
                        style: context.typography.bodyLarge,
                        color: palette.neutral.grey7,
                      ),
                    ],
                  ),
                  SizedBox(height: context.space()),
                  DSTextFieldWidget(
                    controller: _emailController,
                    labelText: localizations.signInEmailLabel,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    enabledBorderColor: palette.neutral.grey4,
                    enabled: isEnabled,
                  ),
                  DSTextFieldWidget(
                    controller: _passwordController,
                    labelText: localizations.signInPasswordLabel,
                    textFieldType: TextFieldType.password,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    enabledBorderColor: palette.neutral.grey4,
                    enabled: isEnabled,
                    onFieldSubmitted: (_) => _signIn(),
                  ),
                  SizedBox(height: context.space(factor: 0.5)),
                  DSButtonWidget(
                    label: localizations.signInButton,
                    icon: Icons.arrow_forward_rounded,
                    iconDirection: DSButtonIconDirection.right,
                    isLoading: state.isSigningIn,
                    isDisabled: !isEnabled,
                    onPressed: _signIn,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(),
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: palette.neutral.grey7.color,
                      ),
                      Expanded(
                        child: DSTextWidget(
                          localizations.signInNoSignUp,
                          style: context.typography.bodySmall,
                          color: palette.neutral.grey7,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.05, curve: Curves.easeOutCubic);
  }
}
