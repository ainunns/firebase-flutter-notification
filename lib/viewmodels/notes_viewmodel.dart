import 'package:flutter/foundation.dart';
import 'package:firebase_flutter_notification/models/note.dart';
import 'package:firebase_flutter_notification/services/firestore.dart';
import 'package:firebase_flutter_notification/services/notification.dart';
import 'package:firebase_flutter_notification/viewmodels/auth_viewmodel.dart';

class NotesViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthViewModel _authViewModel;
  final List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;
  bool _isProcessingNotification = false;

  NotesViewModel(this._firestoreService, this._authViewModel);

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isProcessingNotification => _isProcessingNotification;

  Stream<List<Note>> getNotesStream() {
    return _firestoreService.getNotesStream().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  Future<void> _sendNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    if (_isProcessingNotification) return;

    try {
      _isProcessingNotification = true;
      notifyListeners();

      await NotificationService.createNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      // Error handling is done through the UI
    } finally {
      _isProcessingNotification = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String text) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final docRef = await _firestoreService.addNote(text);
      final user = _authViewModel.currentUser;

      await _sendNotification(
        title: 'New Note Created 📝',
        body:
            'Note: ${text.length > 50 ? '${text.substring(0, 47)}...' : text}',
        payload: {
          'type': 'note_created',
          'noteId': docRef.id,
          'userId': user?.id ?? 'unknown',
        },
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote(String docId, String text) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateNote(docId, text);
      final user = _authViewModel.currentUser;

      await _sendNotification(
        title: 'Note Updated ✏️',
        body:
            'Note updated: ${text.length > 50 ? '${text.substring(0, 47)}...' : text}',
        payload: {
          'type': 'note_updated',
          'noteId': docId,
          'userId': user?.id ?? 'unknown',
        },
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String docId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteNote(docId);
      final user = _authViewModel.currentUser;

      await _sendNotification(
        title: 'Note Deleted 🗑️',
        body: 'A note has been deleted from your collection',
        payload: {
          'type': 'note_deleted',
          'noteId': docId,
          'userId': user?.id ?? 'unknown',
        },
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
