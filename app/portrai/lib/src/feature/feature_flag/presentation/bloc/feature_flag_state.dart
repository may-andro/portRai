import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

enum FeatureFlagViewMode { list, grid }

sealed class FeatureFlagState extends Equatable {
  const FeatureFlagState();

  @override
  List<Object?> get props => [];
}

class FeatureFlagInitialState extends FeatureFlagState {
  const FeatureFlagInitialState();
}

class FeatureFlagLoadingState extends FeatureFlagState {
  const FeatureFlagLoadingState();
}

class FeatureFlagLoadedState extends FeatureFlagState {
  const FeatureFlagLoadedState(
    this.allFlags, {
    this.searchQuery = '',
    this.hasManipulatedFlags = false,
    this.viewMode = FeatureFlagViewMode.list,
  });

  final List<AppFeatureFlagEntity> allFlags;
  final String searchQuery;
  final bool hasManipulatedFlags;
  final FeatureFlagViewMode viewMode;

  List<AppFeatureFlagEntity> get filteredFlags {
    if (searchQuery.isEmpty) return allFlags;

    final query = searchQuery.toLowerCase();
    return allFlags.where((flag) {
      final name = flag.name.toLowerCase();
      final description = (flag.description ?? '').toLowerCase();
      final key = flag.flag.key.toLowerCase();
      return name.contains(query) ||
          description.contains(query) ||
          key.contains(query);
    }).toList();
  }

  FeatureFlagLoadedState copyWith({
    List<AppFeatureFlagEntity>? allFlags,
    String? searchQuery,
    bool? hasManipulatedFlags,
    FeatureFlagViewMode? viewMode,
  }) {
    return FeatureFlagLoadedState(
      allFlags ?? this.allFlags,
      searchQuery: searchQuery ?? this.searchQuery,
      hasManipulatedFlags: hasManipulatedFlags ?? this.hasManipulatedFlags,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [allFlags, searchQuery, hasManipulatedFlags, viewMode];
}

class FeatureFlagErrorState extends FeatureFlagState {
  const FeatureFlagErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
