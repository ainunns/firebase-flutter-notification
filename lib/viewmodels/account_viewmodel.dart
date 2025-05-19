import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_notification/models/user.dart';
import 'package:firebase_flutter_notification/viewmodels/auth_viewmodel.dart';

class AccountViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  bool _isLoading = false;
  String? _error;

  AccountViewModel(this._authViewModel);

  bool get isLoading => _isLoading;
  String? get error => _error;
  AppUser? get currentUser => _authViewModel.currentUser;

  Future<void> updateDisplayName(String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateEmail(email);
        await user.reload();
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthErrorMessage(e);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthErrorMessage(e);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        await _authViewModel.signOut();
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthErrorMessage(e);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Please sign in again to update your account.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'User not found.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return e.message ?? 'An error occurred.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
