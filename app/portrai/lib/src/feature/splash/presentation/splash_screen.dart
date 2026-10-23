import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/connectivity.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/splash/presentation/widget/_widget.dart';

/// Takes over from the native splash, which stays on screen until this
/// screen can draw the logo.
class SplashScreen extends StatefulWidget {
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
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Delays the set up messages, so a quick start only shows the logo.
  static const _infoRevealDelay = Duration(milliseconds: 600);

  bool _isLogoRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLogoRequested) return;
    _isLogoRequested = true;
    // The first frame would otherwise draw before the logo is decoded.
    precacheImage(
      AssetImage(DSImage.logoPath, package: 'design_system'),
      context,
    ).whenComplete(FlutterNativeSplash.remove);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SplashBloc(ModuleInjectorController(), widget.moduleConfigurators)
            ..add(InitEvent()),
      child: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, state) {
          if (state is SetUpNoInternetState) {
            return NoInternetScreen(
              onRetryClick: () =>
                  context.read<SplashBloc>().add(RetryClickEvent()),
            );
          }
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                CircularRevealLogoWidget(
                  state: state,
                  onComplete: () => handleAnimationComplete(state),
                ),
                _buildFadingInfoWidget(state),
              ],
            ),
          );
        },
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
        child: _SplashInfoWidget(state, widget.buildConfig)
            .animate(delay: _infoRevealDelay)
            .fadeIn(duration: const Duration(milliseconds: 300)),
      ),
    );
  }

  void handleAnimationComplete(SplashState state) {
    if (state is SetUpCompetedState) {
      widget.onInitializationSuccessful(state.designSystem);
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
      SetUpCompetedState() || SetUpNoInternetState() => const SizedBox.shrink(),
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
