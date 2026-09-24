import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/notes_repository.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository, {required this.courseId, required this.lessonId}) : super(const NotesLoading());

  static const _debounce = Duration(milliseconds: 600);

  final String courseId;
  final String lessonId;
  final NotesRepository _repository;
  Timer? _pendingSave;

  Future<void> load() async {
    final String text;
    try {
      text = await _repository.load(courseId, lessonId);
    } on Object {
      if (!isClosed) emit(const NotesReady(''));
      return;
    }
    if (!isClosed) emit(NotesReady(text));
  }

  void update(String text) {
    if (state case NotesReady(text: final current) when current == text) return;
    emit(NotesReady(text));
    _pendingSave?.cancel();
    _pendingSave = Timer(_debounce, _flush);
  }

  Future<void> _flush() async {
    _pendingSave?.cancel();
    _pendingSave = null;
    if (state case NotesReady(:final text)) await _repository.save(courseId, lessonId, text);
  }

  @override
  Future<void> close() async {
    if (_pendingSave != null) await _flush();
    return super.close();
  }
}
