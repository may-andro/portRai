import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/_bloc.dart';
import 'package:portrai/src/feature/user/user.dart';

part 'background_widget.dart';
part 'header_widget.dart';
part 'role_card_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _BackgroundWidget()),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.space(factor: 3)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(factor: context.isMobile ? 3 : 5),
                  children: [
                    const _HeaderWidget(),
                    BlocBuilder<OnboardingBloc, OnboardingState>(
                      builder: (context, state) => _RolesWidget(state: state),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RolesWidget extends StatelessWidget {
  const _RolesWidget({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final (index, role) in UserRole.values.indexed)
        _RoleCardWidget(
          role: role,
          index: index,
          isSelected: state.selectedRole == role,
          isDisabled: state.isSaving,
        ),
    ];

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 1.5),
        children: cards,
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 2),
        children: [for (final card in cards) Expanded(child: card)],
      ),
    );
  }
}
