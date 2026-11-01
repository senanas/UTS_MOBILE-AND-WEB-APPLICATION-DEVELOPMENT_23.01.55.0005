import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/watch_provider.dart';
import 'providers/service_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ChronoStoreApp());
}

class ChronoStoreApp extends StatelessWidget {
  const ChronoStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WatchProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'ChronoStore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
