import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safeprint/safeprint.dart';

import '../../models/models.dart';
import '../../repositories/repositories.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final AuthRepository _authRepository;
  final NotesRepository _noteRepository;
  StreamSubscription? _notesSubscription;

  NotesBloc(
    this._authRepository,
    this._noteRepository,
  ) : super(NotesInitial()) {
    on<NotesEvent>((event, emit) {
      if (event is FetchNotes) {
        _fetchTrigger(emit);
      } else if (event is UpdateNotes) {
        _updateTrigger(event.notes, emit);
      }
    });
  }

  void _fetchTrigger(Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final User? currentUser = await _authRepository.getCurrentUser();
      _notesSubscription?.cancel();
      _notesSubscription = _noteRepository
          .streamNotes(userId: currentUser!.id)
          .listen((notes) => add(UpdateNotes(notes: notes)));
    } catch (err) {
      SafePrint.safeDebug(err);
      emit(NotesError());
    }
  }

  void _updateTrigger(List<Note> notes, Emitter<NotesState> emit) {
    emit(NotesLoaded(notes));
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
