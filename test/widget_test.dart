import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:jam_tangan/main.dart';
import 'package:jam_tangan/providers/auth_provider.dart';
import 'package:jam_tangan/providers/watch_provider.dart';
import 'package:jam_tangan/providers/service_provider.dart';
import 'package:jam_tangan/providers/transaction_provider.dart';

void main() {
  testWidgets('App menampilkan halaman login saat start', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => WatchProvider()),
          ChangeNotifierProvider(create: (_) => ServiceProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ],
        child: const ChronoStoreApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Halaman login menampilkan judul aplikasi dan tombol Masuk
    expect(find.text('ChronoStore'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
