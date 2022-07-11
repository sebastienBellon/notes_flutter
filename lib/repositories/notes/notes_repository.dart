import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/config/paths.dart';
import 'package:notes/entities/note_entity.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/repositories/repositories.dart';

class NotesRepository extends BaseNotesRepository {
  final FirebaseFirestore _firestore;
  final Duration _timeoutDuration = const Duration(seconds: 10);

  NotesRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Note> addNote({required Note note}) async {
    await _firestore
        .collection(Paths.notes)
        .add(note.toEntity().toDocument())
        .timeout(_timeoutDuration);
    return note;
  }

  @override
  Future<Note> deleteNote({required Note note}) async {
    await _firestore
        .collection(Paths.notes)
        .doc(note.id)
        .delete()
        .timeout(_timeoutDuration);
    return note;
  }

  @override
  void dispose() {}

  @override
  Stream<List<Note>> streamNotes({required String userId}) {
    return _firestore
        .collection(Paths.notes)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Note.fromEntity(NoteEntity.fromSnapshot(doc)))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
        );
  }

  @override
  Future<Note> updateNote({required Note note}) async {
    await _firestore
        .collection(Paths.notes)
        .doc(note.id)
        .update(note.toEntity().toDocument())
        .timeout(_timeoutDuration);
    return note;
  }
}
