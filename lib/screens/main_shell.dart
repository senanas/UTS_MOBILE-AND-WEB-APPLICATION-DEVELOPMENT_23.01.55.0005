import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'watch_list_screen.dart';
import 'reminder_screen.dart';

/// Shell utama setelah login.
/// Mengelola navigasi antar halaman dan menampilkan sesuai role.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    switch (_currentIndex) {
      case 0:
        return DashboardScreen(navIndex: _currentIndex, onNavTap: _onNavTap);
      case 1:
        return WatchListScreen(navIndex: _currentIndex, onNavTap: _onNavTap);
      case 2:
        return ReminderScreen(navIndex: _currentIndex, onNavTap: _onNavTap);
      default:
        return DashboardScreen(navIndex: _currentIndex, onNavTap: _onNavTap);
    }
  }
}
