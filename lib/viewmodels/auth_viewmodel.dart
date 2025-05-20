import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_notification/models/user.dart';
import 'package:firebase_flutter_notification/services/notification.dart';
import 'package:firebase_flutter_notification/main.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  final bool _isProcessingNotification = false;

  AuthViewModel() {
    _init();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isProcessingNotification => _isProcessingNotification;

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      try {
        if (user == null) {
          _currentUser = null;
        } else {
          // Create a new AppUser instance with only the essential fields
          _currentUser = AppUser(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoURL: user.photoURL,
            isEmailVerified: user.emailVerified,
          );
        }
      } catch (e) {
        // If anything goes wrong, just set to null
        _currentUser = null;
      }
      notifyListeners();
    });
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

      // Send welcome notification after successful login
      if (_currentUser != null) {
        try {
          await NotificationService.createNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: 'Welcome Back! 👋',
            body:
                'Hello ${_currentUser!.displayName ?? _currentUser!.email}! You have successfully logged in.',
            payload: {'type': 'login'},
          );
        } catch (e) {
          // Ignore notification errors
        }
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

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Temporarily disable auth state listener
      _currentUser = null;
      notifyListeners();

      // Create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure we have a valid user before proceeding
      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Sign out immediately
      await _auth.signOut();

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

      // Send logout notification
      await NotificationService.createNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Logged Out',
        body: 'You have been successfully logged out. See you next time!',
        payload: {'type': 'logout'},
      );

      // Force navigation to login page
      if (MyApp.navigatorKey.currentContext != null) {
        Navigator.of(MyApp.navigatorKey.currentContext!)
            .pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }

      _isLoading = false;
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
