import 'package:equatable/equatable.dart';
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
  const DeveloperMenuLoadedState({this.assetSource = AssetSource.real});

  final AssetSource assetSource;

  @override
  List<Object?> get props => [assetSource];
}

class DeveloperMenuErrorState extends DeveloperMenuState {
  const DeveloperMenuErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
