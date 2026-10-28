import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'decision_dialog_widget.dart';
part 'empty_widget.dart';
part 'request_card_widget.dart';

/// Widest the list grows, so cards stay readable on desktop.
const _maxContentWidth = 760.0;

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<
      AppointmentRequestsBloc,
      AppointmentRequestsState
    >(
      // An answer replaces one loaded state with another.
      buildWhen: (previous, current) => previous != current,
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(
          failure,
          onRetry: () =>
              context.bloc.add(const AppointmentRequestsRetryClickEvent()),
        ),
        final LoadedState state => ScreenLoadedContent.slivers([
          PageAppBarWidget(
            title: context.localizations.appointmentRequestsTitle,
          ),
          SliverToBoxAdapter(child: _ListWidget(state: state)),
        ]),
      },
    );
  }
}

/// The requests waiting for an answer, then the earlier ones.
class _ListWidget extends StatelessWidget {
  const _ListWidget({required this.state});

  final LoadedState state;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final now = DateTime.now();
    final openRequests = state.openRequests(now);
    final closedRequests = state.closedRequests(now);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenHorizontalPadding.left,
        vertical: context.space(factor: 3),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: context.space(factor: 2),
            children: [
              _SectionTitleWidget(localizations.appointmentRequestsOpenTitle),
              if (openRequests.isEmpty)
                const _EmptyWidget()
              else
                for (final request in openRequests)
                  _RequestCardWidget(
                    key: ValueKey(request.id),
                    request: request,
                    isAnswerable: true,
                    isDeciding: state.decidingRequestId == request.id,
                  ),
              if (closedRequests.isNotEmpty) ...[
                SizedBox(height: context.space()),
                _SectionTitleWidget(
                  localizations.appointmentRequestsClosedTitle,
                ),
                for (final request in closedRequests)
                  _RequestCardWidget(
                    key: ValueKey(request.id),
                    request: request,
                    isAnswerable: false,
                    isDeciding: false,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitleWidget extends StatelessWidget {
  const _SectionTitleWidget(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      title,
      style: context.typography.emphasizedTitleLarge,
      color: context.colorPalette.neutral.grey10,
    );
  }
}
