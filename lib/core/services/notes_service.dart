import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/notes/models/note.dart';

class NotesService {
  NotesService({required this._userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _userId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notesCollection {
    return _firestore.collection('users').doc(_userId).collection('notes');
  }

  Future<String> createNote({
    required String title,
    required String content,
  }) async {
    final document = _notesCollection.doc();

    await document.set({
      'title': title.trim(),
      'content': content.trim(),
      'isFavourite': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<List<Note>> getNotes() async {
    final snapshot = await _notesCollection
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs.map(_noteFromDocument).toList();
  }

  Stream<List<Note>> watchNotes() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_noteFromDocument).toList());
  }

  Future<void> updateNote({
    required String noteId,
    String? title,
    String? content,
    bool? isFavourite,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (title != null) {
      updates['title'] = title.trim();
    }

    if (content != null) {
      updates['content'] = content.trim();
    }

    if (isFavourite != null) {
      updates['isFavourite'] = isFavourite;
    }

    await _notesCollection.doc(noteId).update(updates);
  }

  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }

  Note _noteFromDocument(QueryDocumentSnapshot<Map<String, dynamic>> document, ) {
    final data = document.data();

    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];

    return Note(
      id: document.id,
      title: data['title'] as String,
      content: data['content'] as String,
      isFavourite: data['isFavourite'] as bool? ?? false,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }
}
