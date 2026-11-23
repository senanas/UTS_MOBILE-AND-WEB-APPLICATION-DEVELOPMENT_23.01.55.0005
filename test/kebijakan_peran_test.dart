import 'package:flutter_test/flutter_test.dart';
import 'package:jam_tangan/app/constants.dart';
import 'package:jam_tangan/models/user_account.dart';
import 'package:jam_tangan/services/kebijakan_peran.dart';

void main() {
  group('KebijakanPeran', () {
    test('email admin bootstrap selalu menjadi Admin', () {
      for (final email in AppConstants.emailAdmin) {
        expect(
          KebijakanPeran.tentukan(email, UserRole.customer),
          UserRole.admin,
          reason: '$email harus selalu Admin walau cache pelanggan',
        );
      }
    });

    test('huruf besar dan spasi tetap dikenali sebagai email admin', () {
      expect(
        KebijakanPeran.tentukan('  ADMIN@ChronoStore.COM ', UserRole.customer),
        UserRole.admin,
      );
    });

    test('email biasa mempertahankan peran pilihan saat mendaftar', () {
      expect(
        KebijakanPeran.tentukan('pembeli@gmail.com', UserRole.admin),
        UserRole.admin,
      );
      expect(
        KebijakanPeran.tentukan('pembeli@gmail.com', UserRole.customer),
        UserRole.customer,
      );
    });

    test('email kosong / null tidak dianggap admin', () {
      expect(KebijakanPeran.adalahEmailAdmin(null), isFalse);
      expect(KebijakanPeran.adalahEmailAdmin(''), isFalse);
      expect(KebijakanPeran.adalahEmailAdmin('admin@lain.com'), isFalse);
    });
  });
}
