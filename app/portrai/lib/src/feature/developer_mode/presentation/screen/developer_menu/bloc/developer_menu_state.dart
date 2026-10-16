import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/ai_image_gen/ai_image_gen.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';

sealed class DeveloperMenuState extends Equatable {
  const DeveloperMenuState();

  @override
  List<Object?> get props => [];
}

class DeveloperMenuInitialState extends DeveloperMenuState {
  const DeveloperMenuInitialState();
}

class DeveloperMenuLoadingState extends DeveloperMenuState {
  const DeveloperMenuLoadingState();
}

class DeveloperMenuLoadedState extends DeveloperMenuState {
  const DeveloperMenuLoadedState({
    this.assetSource = AssetSource.real,
    this.aiImageSettings = const AiImageSettings(),
  });

  final AssetSource assetSource;
  final AiImageSettings aiImageSettings;

  DeveloperMenuLoadedState withAssetSource(AssetSource assetSource) =>
      DeveloperMenuLoadedState(
        assetSource: assetSource,
        aiImageSettings: aiImageSettings,
      );

  DeveloperMenuLoadedState withAiImageSettings(
    AiImageSettings aiImageSettings,
  ) => DeveloperMenuLoadedState(
    assetSource: assetSource,
    aiImageSettings: aiImageSettings,
  );

  @override
  List<Object?> get props => [assetSource, aiImageSettings];
}

class DeveloperMenuErrorState extends DeveloperMenuState {
  const DeveloperMenuErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
