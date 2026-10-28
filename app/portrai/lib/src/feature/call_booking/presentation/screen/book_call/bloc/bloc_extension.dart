import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/book_call_bloc.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/book_call_state.dart';

extension ContextExtension on BuildContext {
  BookCallBloc get bloc => read<BookCallBloc>();

  BookCallState get state => bloc.state;
}
