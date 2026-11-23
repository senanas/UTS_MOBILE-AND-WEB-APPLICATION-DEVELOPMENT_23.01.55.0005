import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Halaman mengikuti status login Firebase (cek status login, Minggu 9).
/// Belum login -> LoginScreen, sudah login -> MainShell.
///
/// Menggunakan AuthProvider (bukan FirebaseAuth langsung) supaya peran dari
/// Firestore sudah selesai dibaca sebelum MainShell ditampilkan. Tanpa ini,
/// saat refresh browser, dashboard sempat memakai role default "Pelanggan"
/// walau pengguna sebenarnya admin.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Belum login sama sekali.
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    // Sudah login tetapi peran dari Firestore belum selesai dibaca.
    // Tampilkan loading supaya Dashboard tidak sempat memakai role default.
    if (!auth.isRoleLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const MainShell();
  }
}
