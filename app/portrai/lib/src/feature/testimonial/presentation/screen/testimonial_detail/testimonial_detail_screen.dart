import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class TestimonialDetailScreen extends StatelessWidget {
  const TestimonialDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<TestimonialDetailBloc>();
      },
      child: BlocBuilder<TestimonialDetailBloc, TestimonialDetailState>(
        builder: (context, state) {
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
    return const Placeholder();
  }
}
