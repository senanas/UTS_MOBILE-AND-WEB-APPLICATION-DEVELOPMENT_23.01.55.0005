import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_account.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_error.dart';
import '../services/layanan_chronostore.dart';

/// State management autentikasi. Peran kini berasal dari `users/{uid}`
/// di Cloud Firestore (Minggu 10), bukan lagi sekadar penyimpanan lokal.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;

  UserAccount? _currentUser;
  bool _isLoading = false;
  bool _roleLoaded = false;
  String? _error;

  AuthProvider({LayananChronoStore? layanan})
      : _authRepo = AuthRepository(layanan: layanan) {
    _currentUser = _authRepo.currentUser;
    _authRepo.authState.listen((user) {
      _currentUser = user;
      _roleLoaded = true;
      notifyListeners();
    });
  }

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCustomer => _currentUser?.role == UserRole.customer;
  bool get isLoading => _isLoading;
  /// True setelah peran dibaca dari Firestore (bukan hanya dari cache).
  /// AuthGate menunggu flag ini sebelum menampilkan MainShell agar role
  /// tidak sempat bernilai default "Pelanggan" saat refresh browser.
  bool get isRoleLoaded => _roleLoaded;
  String? get error => _error;

  /// Login dengan email + password, menunggu jawaban Firebase.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authRepo.login(email: email, password: password);
      _roleLoaded = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthError.message(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register akun baru.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authRepo.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _roleLoaded = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthError.message(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Status pengguna dikosongkan otomatis oleh aliran authState.
  /// Reset _roleLoaded agar AuthGate menunggu Firestore lagi saat login berikutnya.
  Future<void> logout() {
    _roleLoaded = false;
    notifyListeners();
    return _authRepo.logout();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
