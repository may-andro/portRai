import 'package:equatable/equatable.dart';

sealed class PortfolioUpdateListenerEvent extends Equatable {
  const PortfolioUpdateListenerEvent();

  @override
  List<Object?> get props => [];
}

/// The app started or came back to the foreground.
class PortfolioUpdateCheckRequestedEvent extends PortfolioUpdateListenerEvent {
  const PortfolioUpdateCheckRequestedEvent();
}
