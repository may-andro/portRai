import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/locale/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'locale_list_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.isDialog});

  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<LocaleSelectionBloc, LocaleSelectionState>(
      impressionPrefix: 'language_update',
      buildWhen: (previous, current) => previous != current,
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(
          failure,
          onRetry: () => context.bloc.add(const LoadLocaleEvent()),
        ),
        final LoadedState state when isDialog => ScreenLoadedContent.fullScreen(
          SingleChildScrollView(
            child: _SuccessWidget(state, isDialog: isDialog),
          ),
        ),
        final LoadedState state => ScreenLoadedContent.slivers([
          SliverToBoxAdapter(child: _SuccessWidget(state, isDialog: isDialog)),
          const SliverToBoxAdapter(child: DSVerticalSpacerWidget(2)),
        ]),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}

/// The title and the list of languages.
class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget(this.state, {required this.isDialog});

  final LoadedState state;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 2),
      children: [
        const DSVerticalSpacerWidget(1),
        Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: DSTextWidget(
            context.localizations.localeSelectionTitle,
            style: isDialog
                ? context.typography.headlineSmall
                : context.typography.titleMedium,
            color: context.colorPalette.neutral.grey9,
          ),
        ),
        _LocaleListWidget(
          supportedLocales: state.supportedLocales,
          currentLocale: state.appLocale,
          targetLocale: state.updatingState?.targetLocale,
          isLoading: state.isUpdating,
        ),
      ],
    );
  }
}
