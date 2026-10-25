import 'package:equatable/equatable.dart';

sealed class PortfolioUpdateListenerState extends Equatable {
  const PortfolioUpdateListenerState();

  @override
  List<Object?> get props => [];
}

/// Syncing has no visible state; screens reload the refreshed sections.
class PortfolioUpdateListenerIdleState extends PortfolioUpdateListenerState {
  const PortfolioUpdateListenerIdleState();
}
