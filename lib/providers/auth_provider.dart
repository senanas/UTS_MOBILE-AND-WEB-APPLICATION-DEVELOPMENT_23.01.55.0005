import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../repositories/auth_repository.dart';

/// State management untuk autentikasi.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  UserAccount? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCustomer => _currentUser?.role == UserRole.customer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Login dengan email + password.
  bool login(String email, String password) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final user = _authRepo.login(email, password);
    _isLoading = false;

    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    } else {
      _error = 'Email atau kata sandi salah';
      notifyListeners();
      return false;
    }
  }

  /// Register akun baru.
  bool register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _authRepo.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ArgumentError: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout.
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
