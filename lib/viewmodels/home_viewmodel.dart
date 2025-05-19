import 'package:flutter/foundation.dart';
import 'package:firebase_flutter_notification/models/user.dart';
import 'package:firebase_flutter_notification/viewmodels/auth_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  HomeViewModel(this._authViewModel);

  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AppUser? get currentUser => _authViewModel.currentUser;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authViewModel.signOut();

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
