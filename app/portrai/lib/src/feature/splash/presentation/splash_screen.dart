import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/splash/presentation/widget/_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    required this.buildConfig,
    required this.moduleConfigurators,
    required this.onInitializationSuccessful,
    super.key,
  });

  final BuildConfig buildConfig;
  final List<ModuleConfigurator> moduleConfigurators;
  final void Function(DesignSystem) onInitializationSuccessful;

  @override
  Widget build(BuildContext context) {
    // Make the screen full screen by hiding system overlays
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return BlocProvider(
      create: (_) =>
          SplashBloc(ModuleInjectorController(), moduleConfigurators)
            ..add(InitEvent()),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return BlocBuilder<SplashBloc, SplashState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    CircularRevealLogoWidget(
                      state: state,
                      constraints: constraints,
                      onComplete: () => handleAnimationComplete(state),
                    ),
                    _buildFadingInfoWidget(state),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFadingInfoWidget(SplashState state) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: state is SetUpCompetedState ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: _SplashInfoWidget(state, buildConfig),
      ),
    );
  }

  void handleAnimationComplete(SplashState state) {
    if (state is SetUpCompetedState) {
      onInitializationSuccessful(state.designSystem);
    }
  }
}

class _SplashInfoWidget extends StatelessWidget {
  const _SplashInfoWidget(this.state, this.buildConfig);

  final SplashState state;
  final BuildConfig buildConfig;

  @override
  Widget build(BuildContext context) {
    final isDescriptiveMode = buildConfig.buildEnvironment.isSplashDescriptive;

    return switch (state) {
      SetUpCompetedState() => const SizedBox.shrink(),
      SetUpErrorState(:final cause) => SetupFailureWidget(
        cause,
        isDescriptiveMode: isDescriptiveMode,
      ),
      SetUpProgressState(:final progress, :final setUpStatus) =>
        isDescriptiveMode
            ? SetupStatusInfoWidget(setUpStatus)
            : SetupProgressWidget(progress),
    };
  }
}

extension on BuildContext {
  Color get backgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF6F6F6);
  }
}
