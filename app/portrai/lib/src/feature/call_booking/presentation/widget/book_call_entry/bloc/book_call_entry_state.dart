import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class BookCallEntryState extends Equatable {
  const BookCallEntryState({this.isAvailable = false});

  /// False until the flag is read, so the entry never flashes in.
  final bool isAvailable;

  @override
  List<Object?> get props => [isAvailable];
}
