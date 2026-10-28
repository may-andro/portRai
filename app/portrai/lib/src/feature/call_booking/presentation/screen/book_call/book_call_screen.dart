import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/call_booking/presentation/route/_route.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/_bloc.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class BookCallScreen extends StatelessWidget {
  const BookCallScreen({super.key});

  static const topicQueryParameter = 'topic';

  /// Opens the screen with [topic] filled in, when given.
  static void navigate(BuildContext context, {String? topic}) {
    context.pushScreen(
      CallBookingModuleRoute.bookCall,
      queryParameters: {
        if (topic != null && topic.isNotEmpty) topicQueryParameter: topic,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topic = context.routeQueryParameters[topicQueryParameter] ?? '';
    return ScreenScaffoldWidget<BookCallBloc, BookCallState>(
      onCreate: (bloc) => bloc.add(const LoadCallSlotsEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      listenWhen: (previous, current) =>
          previous.sendFailure != current.sendFailure &&
          current.sendFailure != null,
      listener: (context, state) {
        if (state.sendFailure case final failure?) {
          context.showSnackBar(
            snackBar: DSSnackBar(
              message: FailureTranslator.translate(context, failure),
              type: DSSnackBarType.error,
            ),
          );
        }
      },
      body: ContentWidget(topic: topic),
    );
  }
}
