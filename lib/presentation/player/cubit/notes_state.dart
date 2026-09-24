part of 'notes_cubit.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesReady extends NotesState {
  const NotesReady(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
