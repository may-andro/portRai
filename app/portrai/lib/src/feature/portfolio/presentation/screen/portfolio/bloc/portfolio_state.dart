import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_event.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends PortfolioState {
  const LoadingState();
}

final class ErrorState extends PortfolioState {
  const ErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends PortfolioState {
  const LoadedState({
    required this.portfolio,
    this.selectedSectionIndex = 0,
    this.lastNavigationSource,
  });

  final PortfolioEntity portfolio;
  final int selectedSectionIndex;
  final NavigationSource? lastNavigationSource;

  @override
  List<Object?> get props => [
    portfolio,
    selectedSectionIndex,
    lastNavigationSource,
  ];

  LoadedState copyWith({
    PortfolioEntity? portfolio,
    int? selectedSectionIndex,
    NavigationSource? lastNavigationSource,
  }) {
    return LoadedState(
      portfolio: portfolio ?? this.portfolio,
      selectedSectionIndex: selectedSectionIndex ?? this.selectedSectionIndex,
      lastNavigationSource: lastNavigationSource ?? this.lastNavigationSource,
    );
  }
}
