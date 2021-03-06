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
  final NotesRepository _notesRepository;
  StreamSubscription? _notesSubscription;

  NotesBloc({
    required AuthRepository authRepository,
    required NotesRepository notesRepository,
  })  : _authRepository = authRepository,
        _notesRepository = notesRepository,
        super(NotesInitial()) {
    on<NotesEvent>((event, emit) async {
      if (event is FetchNotes) {
        await _fetchTrigger(emit);
      } else if (event is UpdateNotes) {
        await _updateTrigger(event.notes, emit);
      }
    });
  }

  Future<void> _fetchTrigger(Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final User? currentUser = await _authRepository.getCurrentUser();
      await _notesSubscription?.cancel();
      _notesSubscription = _notesRepository
          .streamNotes(userId: currentUser!.id)
          .listen((notes) => add(UpdateNotes(notes: notes)));
    } catch (err) {
      SafePrint.safeDebug(err);
      emit(NotesError());
    }
  }

  Future<void> _updateTrigger(
      List<Note> notes, Emitter<NotesState> emit) async {
    emit(NotesLoaded(notes));
  }

  @override
  Future<void> close() async {
    await _notesSubscription?.cancel();
    return super.close();
  }
}
