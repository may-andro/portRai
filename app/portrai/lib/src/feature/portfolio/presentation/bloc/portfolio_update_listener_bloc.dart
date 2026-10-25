import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/bloc/portfolio_update_listener_event.dart';
import 'package:portrai/src/feature/portfolio/presentation/bloc/portfolio_update_listener_state.dart';

/// Refreshes the cached portfolio sections that changed since they were
/// cached, whenever the app starts or comes back to the foreground.
@register
class PortfolioUpdateListenerBloc
    extends Bloc<PortfolioUpdateListenerEvent, PortfolioUpdateListenerState> {
  PortfolioUpdateListenerBloc(this._syncPortfolioUseCase)
    : super(const PortfolioUpdateListenerIdleState()) {
    on<PortfolioUpdateCheckRequestedEvent>(
      _mapPortfolioUpdateCheckRequestedEventToState,
    );
  }

  final SyncPortfolioUseCase _syncPortfolioUseCase;

  // A failed sync keeps the caches and is tried again on the next request.
  Future<void> _mapPortfolioUpdateCheckRequestedEventToState(
    PortfolioUpdateCheckRequestedEvent event,
    Emitter<PortfolioUpdateListenerState> emit,
  ) async {
    await _syncPortfolioUseCase();
  }
}
