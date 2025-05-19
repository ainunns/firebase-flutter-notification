import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of notes
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  // CREATE: add a new note
  Future<DocumentReference> addNote(String note) {
    return notes.add({
      'note': note,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'deletedAt': null,
    });
  }

  // READ: get notes from database
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('updatedAt', descending: true).snapshots();

    return notesStream;
  }

  // UPDATE: update a notes given a doc id
  Future<void> updateNote(String docId, String newNote) {
    return notes.doc(docId).update({
      'note': newNote,
      'updatedAt': Timestamp.now(),
    });
  }

  // DELETE: delete a note given a doc id
  Future<void> deleteNote(String docId) {
    return notes.doc(docId).delete();
  }
}
