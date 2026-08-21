import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/locale/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/route/route.dart';
import 'package:tracking/tracking.dart';

part 'locale_list_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.isDialog});

  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = isDialog
        ? context.typography.headlineSmall
        : context.typography.titleMedium;
    return RouteObserverWidget(
      onResume: () => context.bloc.add(ScreenVisibleEvent(isDialog)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 2),
          children: [
            const DSVerticalSpacerWidget(1),
            Padding(
              padding: EdgeInsets.all(context.space(factor: 2)),
              child: DSTextWidget(
                context.localizations.localeSelectionTitle,
                style: titleTextStyle,
                color: context.colorPalette.neutral.grey9,
              ),
            ),
            BlocBuilder<LocaleSelectionBloc, LocaleSelectionState>(
              builder: (context, state) {
                switch (state) {
                  case final LoadingState _:
                    return const _LoadingWidget();
                  case final LoadedState state:
                    return _SuccessWidget(state, isDialog: isDialog);
                  case final ErrorState state:
                    return _ErrorWidget(
                      errorMessage: FailureTranslator.translate(
                        context,
                        state.failure,
                      ),
                      onRetry: () => context.bloc.add(const LoadLocaleEvent()),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'language_update_loading_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.loading()),
      child: Center(child: DSLoadingWidget(size: context.space(factor: 5))),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.errorMessage, required this.onRetry});

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'language_update_loading_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.error()),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: context.space(factor: 8),
              color: context.colorPalette.semantic.error.color,
            ),
            const DSVerticalSpacerWidget(2),
            DSTextWidget(
              errorMessage ??
                  context.localizations.errorLocaleFailedToLoadUnknownReason,
              style: context.typography.bodyLarge,
              color: context.colorPalette.semantic.error,
              textAlign: TextAlign.center,
            ),
            const DSVerticalSpacerWidget(2),
            DSButtonWidget(
              label: context.localizations.retry,
              onPressed: onRetry,
              variant: DSButtonVariant.secondary,
              size: DSButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget(this.state, {required this.isDialog});

  final LoadedState state;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'language_update_success_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: Column(
        children: [
          _LocaleListWidget(
            supportedLocales: state.supportedLocales,
            currentLocale: state.appLocale,
            targetLocale: state.updatingState?.targetLocale,
            isLoading: state.isUpdating,
          ),
          if (state.profile case final ProfileEntity profile
              when !isDialog) ...[
            const DSVerticalSpacerWidget(2),
            FooterWidget(profile: profile),
          ],
        ],
      ),
    );
  }
}
