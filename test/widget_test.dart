import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:jam_tangan/services/validation_service.dart';
import 'package:jam_tangan/utils/date_utils.dart';

/// Unit test murni: tidak membuka widget yang memanggil Firebase.
/// (Lihat panduan Minggu 9 — widget test gagal karena Firebase.)
void main() {
  // intl perlu data lokal di-init dulu, sama seperti di main(). Kalau tidak,
  // formatDate melempar LocaleDataException saat detail jam dibuka.
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  test('Email kosong ditolak', () {
    expect(ValidationService.validateEmail('').isValid, false);
  });

  test('Format email salah ditolak', () {
    expect(ValidationService.validateEmail('nama').isValid, false);
    expect(ValidationService.validateEmail('nama@').isValid, false);
    expect(ValidationService.validateEmail('nama@domain.com').isValid, true);
  });

  test('Password minimal 6 karakter', () {
    expect(ValidationService.validatePassword('').isValid, false);
    expect(ValidationService.validatePassword('123').isValid, false);
    expect(ValidationService.validatePassword('123456').isValid, true);
  });

  test('Nama wajib diisi', () {
    expect(ValidationService.validateName('').isValid, false);
    expect(ValidationService.validateName('Shafa').isValid, true);
  });

  // Regresi: format tanggal garansi di halaman detail jam tidak boleh error.
  test('formatDate tanggal garansi jam tangan (id_ID)', () {
    expect(AppDateUtils.formatDate(DateTime(2026, 8, 15)), '15 Agu 2026');
  });

  test('formatCurrency harga jam tangan (id_ID)', () {
    expect(AppDateUtils.formatCurrency(3500000), contains('3.500.000'));
  });
}
