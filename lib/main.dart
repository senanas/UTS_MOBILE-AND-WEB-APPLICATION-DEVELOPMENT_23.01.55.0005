import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/watch_provider.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth_gate.dart';
import 'services/layanan_chronostore.dart';
import 'services/layanan_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data lokal bahasa Indonesia untuk intl. Tanpa ini,
  // AppDateUtils.formatDate() melempar LocaleDataException saat halaman
  // detail jam tangan (garansi) dibuka — tombol jam jadi seolah tidak bisa
  // diklik (layar merah error).
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Cadangan peran lokal Minggu 9 tetap dimuat lebih dulu. Nilai resminya kini
  // dibaca dari dokumen users/{uid} di Cloud Firestore oleh AuthRepository.
  await AuthRepository.loadRoles();

  runApp(const ChronoStoreApp());
}

class ChronoStoreApp extends StatelessWidget {
  const ChronoStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Satu layanan dipakai bersama semua provider & halaman.
        // Untuk widget test, ganti nilai ini dengan LayananMemori().
        Provider<LayananChronoStore>(create: (_) => LayananFirestore()),
        ChangeNotifierProvider(
          create: (ctx) =>
              AuthProvider(layanan: ctx.read<LayananChronoStore>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              WatchProvider(layanan: ctx.read<LayananChronoStore>()),
        ),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(
          create: (ctx) =>
              TransactionProvider(layanan: ctx.read<LayananChronoStore>()),
        ),
      ],
      child: MaterialApp(
        title: 'ChronoStore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
