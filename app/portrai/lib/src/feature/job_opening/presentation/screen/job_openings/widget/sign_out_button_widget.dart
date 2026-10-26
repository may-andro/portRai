part of 'content_widget.dart';

class _SignOutButtonWidget extends StatelessWidget {
  const _SignOutButtonWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobOpeningsBloc, JobOpeningsState>(
      buildWhen: (previous, current) =>
          previous.isSigningOut != current.isSigningOut ||
          previous.isSignedOut != current.isSignedOut,
      builder: (context, state) => DSButtonWidget(
        label: context.localizations.signOutButton,
        icon: Icons.logout_rounded,
        variant: DSButtonVariant.text,
        size: DSButtonSize.small,
        isExpanded: false,
        isLoading: state.isSigningOut,
        isDisabled: state.isSigningOut || state.isSignedOut,
        onPressed: () => context.bloc.add(const SignOutClickEvent()),
      ),
    );
  }
}
