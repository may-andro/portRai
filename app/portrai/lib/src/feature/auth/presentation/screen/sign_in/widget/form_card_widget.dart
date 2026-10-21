part of 'content_widget.dart';

class _FormCardWidget extends StatefulWidget {
  const _FormCardWidget();

  @override
  State<_FormCardWidget> createState() => _FormCardWidgetState();
}

class _FormCardWidgetState extends State<_FormCardWidget> {
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

    return Container(
          padding: EdgeInsets.all(
            context.space(factor: context.isMobile ? 3 : 4),
          ),
          decoration: BoxDecoration(
            color: palette.surface.surfaceContainerLow.color.withAlpha(240),
            borderRadius: BorderRadius.circular(
              context.dimen.radiusLevel3.value,
            ),
            border: Border.all(color: accent.withAlpha(60)),
            boxShadow: [BoxShadow(color: accent.withAlpha(24), blurRadius: 48)],
          ),
          child: BlocBuilder<SignInBloc, SignInState>(
            builder: (context, state) {
              final isEnabled = !state.isSigningIn && !state.isSignedIn;
              return AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(factor: 2),
                  children: [
                    Row(
                      spacing: context.space(factor: 1.5),
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withAlpha(40),
                            border: Border.all(color: accent.withAlpha(110)),
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 22,
                            color: accent,
                          ),
                        ),
                        Expanded(
                          child: DSTextWidget(
                            localizations.signInTitle,
                            style: context.typography.emphasizedHeadlineSmall,
                            color: palette.neutral.grey10,
                          ),
                        ),
                      ],
                    ),
                    DSTextWidget(
                      localizations.signInDescription,
                      style: context.typography.bodyMedium,
                      color: palette.neutral.grey7,
                    ),
                    const SizedBox.shrink(),
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
          ),
        )
        .animate()
        .fadeIn(delay: 150.ms, duration: 500.ms)
        .slideY(begin: 0.06, curve: Curves.easeOutCubic);
  }
}
