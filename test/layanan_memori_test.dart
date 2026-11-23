import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jam_tangan/models/transaction.dart';
import 'package:jam_tangan/models/user_account.dart';
import 'package:jam_tangan/services/layanan_chronostore.dart';
import 'package:jam_tangan/services/layanan_memori.dart';

/// Unit test Minggu 10. Seluruh test memakai LayananMemori, jadi tidak
/// memanggil Firebase sama sekali (sesuai tabel "Masalah umum" modul:
/// "Widget test gagal karena Firebase -> Injeksi LayananMemori()").
void main() {
  late LayananMemori layanan;

  setUp(() => layanan = LayananMemori());
  tearDown(() => layanan.dispose());

  Future<void> seed() => layanan.isiJamAwalJikaKosong();

  test('Auto-seed mengisi koleksi watches dan stream langsung mengirim data',
      () async {
    expect((await layanan.streamDaftarJam().first).isEmpty, true);

    await seed();
    final daftar = await layanan.streamDaftarJam().first;
    expect(daftar.length, 6);

    // Dipanggil lagi tidak boleh menduplikasi data awal.
    await seed();
    expect((await layanan.streamDaftarJam().first).length, 6);
  });

  test('Profil users/{uid} menyimpan nama lengkap dan peran Admin', () async {
    final profilAwal = await layanan.streamProfil('uid-admin').first;
    expect(profilAwal, isNull);

    await layanan.simpanProfilSaatLogin(
      uid: 'uid-admin',
      email: 'admin@chronostore.test',
      namaLengkap: 'Shafa Admin',
      peran: UserRole.admin,
    );

    expect(await layanan.bacaPeran('uid-admin'), UserRole.admin);
    final profil = await layanan.streamProfil('uid-admin').first;
    expect(profil?.name, 'Shafa Admin');
    expect(profil?.role, UserRole.admin);

    // Profil yang sudah ada tidak boleh ditimpa menjadi Pelanggan.
    await layanan.simpanProfilSaatLogin(
      uid: 'uid-admin',
      email: 'admin@chronostore.test',
      peran: UserRole.customer,
    );
    expect(await layanan.bacaPeran('uid-admin'), UserRole.admin);
  });

  test('Tambah transaksi valid: dokumen masuk & stok berkurang', () async {
    await seed();
    final sebelum = (await layanan.streamDaftarJam().first)
        .firstWhere((w) => w.id == 'w_1');

    await layanan.tambahTransaksi(
      uid: 'uid-a',
      namaPelanggan: 'Pelanggan A',
      watchId: 'w_1',
      watchName: sebelum.name,
      quantity: 2,
      unitPrice: sebelum.price,
      totalPrice: sebelum.price * 2,
      ongkir: 15000,
    );

    final transaksi = await layanan.streamTransaksiSaya('uid-a').first;
    expect(transaksi.length, 1);
    expect(transaksi.first.watchName, sebelum.name); // denormalisasi
    expect(transaksi.first.totalPrice, sebelum.price * 2);
    expect(transaksi.first.status, TransactionStatus.completed);

    final sesudah = (await layanan.streamDaftarJam().first)
        .firstWhere((w) => w.id == 'w_1');
    expect(sesudah.stock, sebelum.stock - 2);
  });

  test('Pesanan ganda (user + jam + tanggal sama) ditolak', () async {
    await seed();
    await layanan.tambahTransaksi(
      uid: 'uid-a',
      namaPelanggan: 'Pelanggan A',
      watchId: 'w_2',
      watchName: 'Casio G-Shock',
      quantity: 1,
      unitPrice: 1800000,
      totalPrice: 1800000,
      ongkir: 0,
    );

    expect(
      () => layanan.tambahTransaksi(
        uid: 'uid-a',
        namaPelanggan: 'Pelanggan A',
        watchId: 'w_2',
        watchName: 'Casio G-Shock',
        quantity: 1,
        unitPrice: 1800000,
        totalPrice: 1800000,
        ongkir: 0,
      ),
      throwsA(isA<TransaksiBentrokException>()),
    );
    expect((await layanan.streamSemuaTransaksi().first).length, 1);
  });

  test('Isolasi antar akun: transaksi A tidak muncul di akun B', () async {
    await seed();
    await layanan.tambahTransaksi(
      uid: 'uid-a',
      namaPelanggan: 'Pelanggan A',
      watchId: 'w_4',
      watchName: 'Timex Expedition',
      quantity: 1,
      unitPrice: 750000,
      totalPrice: 750000,
      ongkir: 0,
    );

    expect((await layanan.streamTransaksiSaya('uid-a').first).length, 1);
    expect((await layanan.streamTransaksiSaya('uid-b').first).isEmpty, true);
    expect((await layanan.streamSemuaTransaksi().first).length, 1);
  });

  test('Jumlah melebihi stok ditolak tanpa menambah dokumen', () async {
    await seed();
    expect(
      () => layanan.tambahTransaksi(
        uid: 'uid-a',
        namaPelanggan: 'Pelanggan A',
        watchId: 'w_3', // stok 0 di data awal
        watchName: 'Citizen Eco-Drive',
        quantity: 1,
        unitPrice: 4200000,
        totalPrice: 4200000,
        ongkir: 0,
      ),
      throwsA(isA<StokTidakCukupException>()),
    );
    expect((await layanan.streamSemuaTransaksi().first).isEmpty, true);
  });

  test('Status transaksi dapat diubah lewat layanan', () async {
    await seed();
    await layanan.tambahTransaksi(
      uid: 'uid-a',
      namaPelanggan: 'Pelanggan A',
      watchId: 'w_5',
      watchName: 'Orient Bambino',
      quantity: 1,
      unitPrice: 2800000,
      totalPrice: 2800000,
      ongkir: 0,
    );
    final id = (await layanan.streamTransaksiSaya('uid-a').first).first.id;

    await layanan.ubahStatusTransaksi(id, TransactionStatus.cancelled);
    final hasil = await layanan.streamTransaksiSaya('uid-a').first;
    expect(hasil.first.status, TransactionStatus.cancelled);
  });

  test('Checkout menyimpan nama, email, telepon, dan alamat lengkap', () async {
    await seed();
    await layanan.tambahTransaksi(
      uid: 'uid-checkout',
      namaPelanggan: 'Budi Santoso',
      emailPelanggan: 'budi@email.com',
      teleponPelanggan: '081234567890',
      watchId: 'w_1',
      watchName: 'Seiko 5 Sports',
      quantity: 1,
      unitPrice: 3500000,
      totalPrice: 3515000,
      ongkir: 15000,
      alamatPengiriman: 'Jl. Merdeka No. 12',
      kota: 'Bandung',
      kodePos: '40123',
      catatan: 'Tolong dibungkus rapi',
    );

    final tx = (await layanan.streamTransaksiSaya('uid-checkout').first).single;
    expect(tx.customerName, 'Budi Santoso');
    expect(tx.customerEmail, 'budi@email.com');
    expect(tx.customerPhone, '081234567890');
    expect(tx.shippingAddress, 'Jl. Merdeka No. 12');
    expect(tx.shippingCity, 'Bandung');
    expect(tx.postalCode, '40123');
    expect(tx.notes, 'Tolong dibungkus rapi');
    expect(tx.shippingCost, 15000);
    expect(tx.totalPrice, 3515000);
    expect(tx.alamatLengkap, contains('Bandung'));
  });

  test('Model transaksi menyimpan flag tersimpanLokal (round-trip)', () {
    final tx = Transaction(
      id: 'lokal_1',
      watchId: 'w_1',
      watchName: 'Seiko 5 Sports',
      quantity: 1,
      unitPrice: 3500000,
      totalPrice: 3515000,
      transactionDate: DateTime(2026, 11, 17),
      customerName: 'Budi',
      userId: 'uid',
      status: TransactionStatus.completed,
      shippingCost: 15000,
      tersimpanLokal: true,
    );
    final hasil = Transaction.fromMap(tx.toMap());
    expect(hasil.tersimpanLokal, true);
    expect(hasil.totalPrice, 3515000);
    expect(hasil.shippingCost, 15000);
  });

  test('Stream bersifat real-time setelah ada perubahan data', () async {
    await seed();
    final events = <int>[];
    final selesai = Completer<void>();
    final sub = layanan.streamDaftarJam().listen((list) {
      events.add(list.length);
      if (list.length == 7 && !selesai.isCompleted) selesai.complete();
    });

    final awal = await layanan.streamDaftarJam().first;
    await layanan.tambahJam(awal.first.copyWith(id: ''));
    await selesai.future.timeout(const Duration(seconds: 2));
    await sub.cancel();

    expect(events, contains(6));
    expect(events, contains(7));
  });
}
