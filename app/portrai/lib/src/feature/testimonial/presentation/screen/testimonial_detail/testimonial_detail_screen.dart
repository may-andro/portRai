import 'package:flutter/material.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/_bloc.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class TestimonialDetailScreen extends StatelessWidget {
  const TestimonialDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<TestimonialDetailBloc, TestimonialDetailState>(
      onResume: (bloc) => bloc.add(ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<TestimonialDetailBloc, TestimonialDetailState>(
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        LoadedState() => const ScreenLoadedContent.slivers([
          SliverFillRemaining(hasScrollBody: false, child: Placeholder()),
        ]),
      },
    );
  }
}
