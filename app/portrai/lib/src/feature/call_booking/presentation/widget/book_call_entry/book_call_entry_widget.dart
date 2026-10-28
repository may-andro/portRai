import 'package:flutter/material.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/_screen.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

/// A way into booking a call that hosts style themselves. While booking is
/// off it shows [fallback], which is empty unless given.
class BookCallEntryWidget extends StatelessWidget {
  const BookCallEntryWidget({
    super.key,
    required this.trackingLabel,
    required this.builder,
    this.topic,
    this.fallback = const SizedBox.shrink(),
  });

  /// Names the tapped element in tracking, such as `service_book_call_button`.
  final String trackingLabel;

  /// Builds the entry. Calling `onBookCall` opens the booking screen.
  final Widget Function(BuildContext context, VoidCallback onBookCall) builder;

  /// Filled in as what the call is about, such as a service's title.
  final String? topic;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          appServiceLocator.get<BookCallEntryBloc>()
            ..add(const LoadBookCallEntryEvent()),
      child: BlocBuilder<BookCallEntryBloc, BookCallEntryState>(
        builder: (context, state) {
          if (!state.isAvailable) return fallback;
          return builder(context, () {
            context.bloc.add(
              BookCallClickEvent(label: trackingLabel, topic: topic),
            );
            BookCallScreen.navigate(context, topic: topic);
          });
        },
      ),
    );
  }
}
