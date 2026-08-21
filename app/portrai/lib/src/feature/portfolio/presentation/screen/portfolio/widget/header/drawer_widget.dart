import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colorPalette.background.color,
      width: max(context.space(factor: 30), context.width * 0.4),
      elevation: context.dimen.elevationLevel3.value,
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: min(context.space(factor: 20), context.height * 0.2),
                  child: DSImage.logo(),
                ),
              ),
              const SliverToBoxAdapter(child: DSVerticalSpacerWidget(3)),
              if (context.state case final PortfolioState state
                  when state is LoadedState) ...[
                SliverToBoxAdapter(
                  child: _ItemsWidget(state.portfolio.scrollableSections),
                ),
              ],
              const SliverToBoxAdapter(child: DSVerticalSpacerWidget(3)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: DSTextWidget(
                    context.localizations.copyright('${DateTime.now().year}'),
                    style: context.typography.labelSmall,
                    color: context.colorPalette.neutral.grey7,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemsWidget extends StatelessWidget {
  const _ItemsWidget(this.sections);

  final List<SectionWidget> sections;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        final selectedSectionIndex = switch (state) {
          LoadedState(:final selectedSectionIndex) => selectedSectionIndex,
          _ => 0,
        };

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;

            return DSTabItemWidget(
              title: section.getTitle(context),
              isSelected: selectedSectionIndex == index,
              isIndicatorEnabled: true,
              onTap: () {
                context.bloc.add(
                  SectionNavigationEvent(
                    sectionIndex: index,
                    sectionId: section.trackingId,
                    source: NavigationSource.drawer,
                  ),
                );
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }
}
