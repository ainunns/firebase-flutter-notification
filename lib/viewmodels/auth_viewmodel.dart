import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_flutter_notification/models/user.dart';
import 'package:firebase_flutter_notification/services/notification.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isProcessingNotification = false;

  AuthViewModel() {
    _init();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isProcessingNotification => _isProcessingNotification;

  void _init() {
    _auth.authStateChanges().listen((User? user) async {
      final oldUser = _currentUser;
      _currentUser = user != null ? AppUser.fromFirebaseUser(user) : null;

      // Send welcome notification when user signs in
      if (_currentUser != null && oldUser == null) {
        await _sendWelcomeNotification();
      }

      notifyListeners();
    });
  }

  Future<void> _sendWelcomeNotification() async {
    if (_isProcessingNotification) return;

    try {
      _isProcessingNotification = true;
      notifyListeners();

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      if (isAllowed && _currentUser != null) {
        final user = _currentUser!;
        await NotificationService.createNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'Welcome Back! 👋',
          body:
              'Hello ${user.displayName ?? user.email}! You have successfully logged in.',
          payload: {
            'type': 'login',
            'email': user.email,
            'userId': user.id,
          },
        );
      }
    } catch (e) {
      // Error handling is done through the UI
    } finally {
      _isProcessingNotification = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.signOut();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

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
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return e.message ?? 'An error occurred.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
