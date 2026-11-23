import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/notes/models/note.dart';

class NotesService {
  NotesService({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notesCollection {
    return _firestore.collection('notes');
  }

  Query<Map<String, dynamic>> get _userNotesQuery {
    return _notesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true);
  }

  Future<String> createNote({
    required String title,
    required String content,
  }) async {
    if (userId.isEmpty) {
      throw StateError('Cannot create a note without a valid userId.');
    }

    final document = _notesCollection.doc();

    await document.set({
      'ownerId': userId,
      'title': title.trim(),
      'content': content.trim(),
      'isFavourite': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<List<Note>> getNotes() async {
    if (userId.isEmpty) return [];

    final snapshot = await _userNotesQuery.get();
    return snapshot.docs.map(_noteFromDocument).toList();
  }

  Stream<List<Note>> watchNotes() {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _userNotesQuery.snapshots().map(
      (snapshot) => snapshot.docs.map(_noteFromDocument).toList(),
    );
  }

  Future<Note?> getNoteById(String noteId) async {
    final doc = await _notesCollection.doc(noteId).get();
    if (!doc.exists || doc.data() == null) return null;

    return _noteFromDocument(doc);
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

    // Prevents unnecessary writes if no actual fields were passed
    if (updates.length == 1) return;

    await _notesCollection.doc(noteId).update(updates);
  }

  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }

  Note _noteFromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};

    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];

    return Note(
      id: document.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      isFavourite: data['isFavourite'] as bool? ?? false,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }
}
