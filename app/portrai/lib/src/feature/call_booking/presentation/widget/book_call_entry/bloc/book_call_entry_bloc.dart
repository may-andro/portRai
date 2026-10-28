import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/book_call_entry_event.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/book_call_entry_state.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/tracking/_tracking.dart';

@register
class BookCallEntryBloc extends Bloc<BookCallEntryEvent, BookCallEntryState> {
  BookCallEntryBloc(this._isCallBookingAvailableUseCase, this._trackingDelegate)
    : super(const BookCallEntryState()) {
    on<LoadBookCallEntryEvent>(_mapLoadBookCallEntryEventToState);
    on<BookCallClickEvent>(_mapBookCallClickEventToState);
  }

  final IsCallBookingAvailableUseCase _isCallBookingAvailableUseCase;
  final BookCallEntryTrackingDelegate _trackingDelegate;

  Future<void> _mapLoadBookCallEntryEventToState(
    LoadBookCallEntryEvent event,
    Emitter<BookCallEntryState> emit,
  ) async {
    final isAvailableEither = await _isCallBookingAvailableUseCase();
    emit(
      BookCallEntryState(
        isAvailable: isAvailableEither.isRight && isAvailableEither.right,
      ),
    );
  }

  void _mapBookCallClickEventToState(
    BookCallClickEvent event,
    Emitter<BookCallEntryState> emit,
  ) => _trackingDelegate.trackBookCallClick(
    label: event.label,
    topic: event.topic,
  );
}
