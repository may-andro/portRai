import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit whose state counts the events a screen sends it.
class FakeScreenCubit extends Cubit<int> {
  FakeScreenCubit() : super(0);

  final List<String> receivedEvents = [];

  void add(String event) => receivedEvents.add(event);

  void count() => emit(state + 1);
}
