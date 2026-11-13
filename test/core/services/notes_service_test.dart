import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_01_firebase_notes/core/services/notes_service.dart';
import 'package:flutter_01_firebase_notes/features/notes/models/note.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NotesService notesService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();

    notesService = NotesService(userId: 'user-1', firestore: fakeFirestore);
  });

  group('NotesService', () {
    test('creates and retrieves a note', () async {
      final noteId = await notesService.createNote(
        title: 'Learn Flutter',
        content: 'Study Firestore integration.',
      );

      final notes = await notesService.getNotes();

      expect(notes, hasLength(1));
      expect(notes.first.id, noteId);
      expect(notes.first.title, 'Learn Flutter');
      expect(notes.first.content, 'Study Firestore integration.');
      expect(notes.first.isFavourite, isFalse);
    });

    test('updates a note', () async {
      final noteId = await notesService.createNote(
        title: 'Original title',
        content: 'Original content',
      );

      await notesService.updateNote(
        noteId: noteId,
        title: 'Updated title',
        isFavourite: true,
      );

      final notes = await notesService.getNotes();

      expect(notes, hasLength(1));
      expect(notes.first.title, 'Updated title');
      expect(notes.first.content, 'Original content');
      expect(notes.first.isFavourite, isTrue);
    });

    test('deletes a note', () async {
      final noteId = await notesService.createNote(
        title: 'Temporary note',
        content: 'This note will be deleted.',
      );

      await notesService.deleteNote(noteId);

      final notes = await notesService.getNotes();

      expect(notes, isEmpty);
    });

    test('keeps notes isolated between users', () async {
      await notesService.createNote(
        title: 'Private note',
        content: 'Belongs to user 1.',
      );

      final secondUserService = NotesService(
        userId: 'user-2',
        firestore: fakeFirestore,
      );

      final firstUserNotes = await notesService.getNotes();
      final secondUserNotes = await secondUserService.getNotes();

      expect(firstUserNotes, hasLength(1));
      expect(secondUserNotes, isEmpty);
    });

    test('emits notes through the real-time stream', () async {
      final expectation = expectLater(
        notesService.watchNotes(),
        emitsInOrder([
          isEmpty,
          predicate<List<Note>>(
            (notes) =>
                // notes != null &&
                notes.length == 1 &&
                notes.first.title == 'Streamed note',
          ),
        ]),
      );

      await notesService.createNote(
        title: 'Streamed note',
        content: 'Testing snapshots.',
      );

      await expectation;
    });
  });
}
