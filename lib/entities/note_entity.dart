import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// NoteEntity is the representation of the data stored in the db in firestore
// We separate entity from models in case we change the store provider, we will
// not touch the models
class NoteEntity extends Equatable {
  final String? id;
  final String userId;
  final String content;
  final String color;
  final Timestamp timestamp;

  const NoteEntity({
    this.id,
    required this.userId,
    required this.content,
    required this.color,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, content, color, timestamp];

  @override
  String toString() => '''NoteEntity {
    id: $id,
    userId: $userId,
    content: $content,
    color: $color,
    timestamp: $timestamp,
  }''';

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'content': content,
      'color': color,
      'timestamp': timestamp,
    };
  }

  factory NoteEntity.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      color: data['color'] ?? '#FFFFFF',
      timestamp: data['timestamp'],
    );
  }
}
