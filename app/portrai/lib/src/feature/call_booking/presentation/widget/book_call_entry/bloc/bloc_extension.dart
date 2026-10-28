import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/book_call_entry_bloc.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/book_call_entry_state.dart';

extension ContextExtension on BuildContext {
  BookCallEntryBloc get bloc => read<BookCallEntryBloc>();

  BookCallEntryState get state => bloc.state;
}
