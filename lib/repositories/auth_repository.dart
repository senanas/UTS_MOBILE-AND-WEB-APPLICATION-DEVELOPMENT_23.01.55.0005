import '../models/user_account.dart';
import 'mock_data.dart';

/// Repository autentikasi (fase lokal).
/// Saat Firebase siap, ganti implementasi ini dengan Firebase Auth.
class AuthRepository {
  final List<UserAccount> _users = List.from(MockData.users);

  /// Login dengan email + password.
  /// Mengembalikan UserAccount jika berhasil, null jika gagal.
  UserAccount? login(String email, String password) {
    try {
      return _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Register akun baru.
  /// Mengembalikan UserAccount jika berhasil.
  /// Melempar ArgumentError jika email sudah dipakai.
  UserAccount register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      throw ArgumentError('Email sudah terdaftar');
    }
    final user = UserAccount(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      password: password,
      role: role,
    );
    _users.add(user);
    return user;
  }

  /// Cek apakah email sudah dipakai.
  bool isEmailTaken(String email) {
    return _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
  }
}
