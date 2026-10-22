import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class TestimonialDetailScreen extends StatelessWidget {
  const TestimonialDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<TestimonialDetailBloc>();
      },
      child: Builder(
        builder: (context) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: const ContentWidget(),
            ),
          );
        },
      ),
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
