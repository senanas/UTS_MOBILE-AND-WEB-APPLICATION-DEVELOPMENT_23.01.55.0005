// `Transaction` juga merupakan nama kelas di cloud_firestore (runTransaction).
// Sembunyikan agar nama model ChronoStore yang dipakai di berkas ini.
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';

import '../data/data_chronostore.dart';
import '../models/transaction.dart';
import '../models/user_account.dart';
import '../models/watch.dart';
import 'layanan_chronostore.dart';

/// Implementasi Cloud Firestore asli untuk ChronoStore (Minggu 10).
///
/// Pemetaan ERD proyek -> 3 collection:
///   users/{uid}              profil + peran (Doc ID = uid Firebase Auth)
///   watches/{id_jam}         master jam tangan, auto-seed 6 data awal
///   transactions/{auto-ID}   pesanan; `nama_jam` sengaja di-denormalisasi
///                            supaya daftar transaksi cukup satu kali baca
///                            (Firestore tidak punya JOIN).
///
/// Batas Minggu 10: hanya Create & Read. Query cukup satu `.where()` saja;
/// pengurutan terbaru dilakukan di sisi Dart agar tidak memicu composite index.
class LayananFirestore implements LayananChronoStore {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  LayananFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _watches =>
      _db.collection('watches');

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _db.collection('transactions');

  // ---------------------------------------------------------------- users ---

  @override
  Future<void> simpanProfilSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
    UserRole? peran,
  }) async {
    final docRef = _users.doc(uid);
    final snap = await docRef.get();
    if (snap.exists) return; // jangan timpa profil / peran yang sudah ada

    final namaBersih = (namaLengkap ?? '').trim();
    await docRef.set({
      'id_pengguna': uid,
      'nama_lengkap':
          namaBersih.isNotEmpty ? namaBersih : email.split('@').first,
      'email': email,
      'nomor_telepon': '',
      'peran': _roleToString(peran ?? UserRole.customer),
      'dibuat_pada': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<UserRole?> bacaPeran(String uid) async {
    final snap = await _users.doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return _roleFromString(data['peran'] as String?);
  }

  @override
  Future<void> perbaruiPeran(String uid, UserRole peran) =>
      _users.doc(uid).set(
        {'peran': _roleToString(peran)},
        SetOptions(merge: true),
      );

  @override
  Stream<UserAccount?> streamProfil(String uid) =>
      _users.doc(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return null;
        final email = data['email'] as String? ?? '';
        final nama = data['nama_lengkap'] as String? ?? '';
        return UserAccount(
          id: uid,
          name: nama.isNotEmpty
              ? nama
              : (email.isNotEmpty ? email.split('@').first : 'Pengguna'),
          email: email,
          password: '',
          role: _roleFromString(data['peran'] as String?),
        );
      });

  // -------------------------------------------------------------- watches ---

  @override
  Future<void> isiJamAwalJikaKosong() async {
    final cek = await _watches.limit(1).get();
    if (cek.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final watch in daftarJamAwal) {
      batch.set(_watches.doc(watch.id), _watchToMap(watch));
    }
    await batch.commit();
  }

  /// Langganan Firestore baru dimulai setelah `request.auth != null` terpenuhi.
  /// `asyncExpand` membatalkan langganan lama setiap status login berubah,
  /// sehingga provider yang dibuat sejak aplikasi dibuka tidak mengalami
  /// `permission-denied` saat pengguna masih di halaman Login.
  Stream<List<Watch>> get _streamJam =>
      _watches.snapshots().map(_jamFromSnapshot);

  @override
  Stream<List<Watch>> streamDaftarJam() =>
      _auth.authStateChanges().asyncExpand((user) {
        if (user == null) return Stream<List<Watch>>.value(const <Watch>[]);
        return _streamJam;
      });

  @override
  Future<Watch> tambahJam(Watch watch) async {
    final docRef = _watches.doc();
    final baru = watch.copyWith(id: docRef.id, createdAt: DateTime.now());
    await docRef.set(_watchToMap(baru));
    return baru;
  }

  @override
  Future<void> ubahJam(Watch watch) =>
      _watches.doc(watch.id).set(_watchToMap(watch));

  @override
  Future<void> hapusJam(String id) => _watches.doc(id).delete();

  // ---------------------------------------------------------- transactions ---

  @override
  Future<void> tambahTransaksi({
    required String uid,
    required String namaPelanggan,
    required String watchId,
    required String watchName,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    required int ongkir,
    String emailPelanggan = '',
    String teleponPelanggan = '',
    String alamatPengiriman = '',
    String kota = '',
    String kodePos = '',
    String catatan = '',
  }) async {
    final tanggal = formatTanggal(DateTime.now());

    // 1. Aturan bisnis: tolak pesanan ganda (pengguna + jam + tanggal sama).
    //    Satu .where() saja, tanpa .orderBy() -> tidak butuh composite index.
    final adaDiTanggal =
        await _transactions.where('tanggal', isEqualTo: tanggal).get();
    final bentrok = adaDiTanggal.docs.any((doc) {
      final data = doc.data();
      return data['id_jam'] == watchId &&
          data['id_pengguna'] == uid &&
          (data['status'] as String? ?? 'pending').toLowerCase() != 'cancelled';
    });
    if (bentrok) {
      throw const TransaksiBentrokException(
        'Jam tangan ini sudah Anda pesan hari ini.',
      );
    }

    // 2. Cek stok, tulis dokumen, dan kurangi stok dalam satu transaksi atomik.
    final docRef = _transactions.doc();
    await _db.runTransaction<void>((txn) async {
      final jamSnap = await txn.get(_watches.doc(watchId));
      final jam = jamSnap.data();
      if (jam == null) {
        throw const StokTidakCukupException('Jam tangan tidak ditemukan.');
      }
      final stok = (jam['stok'] as num?)?.toInt() ?? 0;
      if (stok < quantity) {
        throw StokTidakCukupException('Stok tinggal $stok unit.');
      }

      txn.set(docRef, {
        'id_transaksi': docRef.id,
        'id_pengguna': uid,
        'id_jam': watchId,
        // Denormalisasi: nama jam ikut disimpan agar daftar transaksi
        // tidak perlu melakukan query tambahan ke collection watches.
        'nama_jam': watchName,
        'nama_pelanggan': namaPelanggan,
        'email_pelanggan': emailPelanggan,
        'telepon_pelanggan': teleponPelanggan,
        'alamat_pengiriman': alamatPengiriman,
        'kota': kota,
        'kode_pos': kodePos,
        'catatan': catatan,
        'jumlah': quantity,
        'harga_satuan': unitPrice,
        'ongkir': ongkir,
        'total_harga': totalPrice,
        'tanggal': tanggal,
        'status': TransactionStatus.completed.name,
        'dibuat_pada': FieldValue.serverTimestamp(),
      });
      txn.update(_watches.doc(watchId), {'stok': stok - quantity});
    });
  }

  @override
  Stream<List<Transaction>> streamTransaksiSaya(String uid) =>
      _auth.authStateChanges().asyncExpand((user) {
        if (user == null) {
          return Stream<List<Transaction>>.value(const <Transaction>[]);
        }
        return _transactions
            .where('id_pengguna', isEqualTo: uid)
            .snapshots()
            .map(_transactionsFromSnapshot);
      });

  @override
  Stream<List<Transaction>> streamSemuaTransaksi() =>
      _auth.authStateChanges().asyncExpand((user) {
        if (user == null) {
          return Stream<List<Transaction>>.value(const <Transaction>[]);
        }
        return _transactions.snapshots().map(_transactionsFromSnapshot);
      });

  @override
  Future<void> ubahStatusTransaksi(String id, TransactionStatus status) =>
      _transactions.doc(id).update({'status': status.name});

  // ------------------------------------------------------------ konversi ---

  List<Watch> _jamFromSnapshot(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((doc) => _watchFromMap(doc.id, doc.data())).toList();

  List<Transaction> _transactionsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final daftar = snap.docs.map((doc) {
      final data = doc.data();
      final rawWaktu = data['dibuat_pada'];
      DateTime? dibuatPada;
      if (rawWaktu is Timestamp) {
        dibuatPada = rawWaktu.toDate();
      } else if (rawWaktu is String) {
        dibuatPada = DateTime.tryParse(rawWaktu);
      }

      return Transaction(
        id: data['id_transaksi'] as String? ?? doc.id,
        watchId: data['id_jam'] as String? ?? '',
        watchName: data['nama_jam'] as String? ?? '',
        quantity: (data['jumlah'] as num?)?.toInt() ?? 0,
        unitPrice: (data['harga_satuan'] as num?)?.toInt() ?? 0,
        totalPrice: (data['total_harga'] as num?)?.toInt() ?? 0,
        transactionDate:
            DateTime.tryParse((data['tanggal'] as String?) ?? '') ??
                DateTime.now(),
        customerName: data['nama_pelanggan'] as String? ?? '',
        customerEmail: data['email_pelanggan'] as String? ?? '',
        customerPhone: data['telepon_pelanggan'] as String? ?? '',
        shippingAddress: data['alamat_pengiriman'] as String? ?? '',
        shippingCity: data['kota'] as String? ?? '',
        postalCode: data['kode_pos'] as String? ?? '',
        notes: data['catatan'] as String? ?? '',
        shippingCost: (data['ongkir'] as num?)?.toInt() ?? 0,
        userId: data['id_pengguna'] as String? ?? '',
        status: TransactionStatus.values.firstWhere(
          (s) => s.name == data['status'],
          orElse: () => TransactionStatus.pending,
        ),
        createdAt: dibuatPada,
      );
    }).toList();

    // Urutkan di Dart (bukan .orderBy() di Firestore) supaya tidak muncul
    // error `failed-precondition ... requires an index`.
    daftar.sort((a, b) => _waktuUrut(b).compareTo(_waktuUrut(a)));
    return daftar;
  }

  static DateTime _waktuUrut(Transaction t) => t.createdAt ?? t.transactionDate;

  Map<String, dynamic> _watchToMap(Watch w) => {
        'id_jam': w.id,
        'nama_jam': w.name,
        'merek': w.brand,
        'model': w.model,
        'jenis_mesin': w.movementType.name,
        'harga': w.price,
        'stok': w.stock,
        'nomor_seri': w.serialNumber,
        'gambar_url': w.imageUrl,
        'garansi_mulai': w.warrantyStart?.toIso8601String(),
        'garansi_akhir': w.warrantyEnd?.toIso8601String(),
        'dibuat_pada': w.createdAt.toIso8601String(),
      };

  Watch _watchFromMap(String docId, Map<String, dynamic> data) => Watch(
        id: data['id_jam'] as String? ?? docId,
        name: data['nama_jam'] as String? ?? '',
        brand: data['merek'] as String? ?? '',
        model: data['model'] as String? ?? '',
        movementType: WatchType.values.firstWhere(
          (t) => t.name == data['jenis_mesin'],
          orElse: () => WatchType.quartz,
        ),
        price: (data['harga'] as num?)?.toInt() ?? 0,
        stock: (data['stok'] as num?)?.toInt() ?? 0,
        serialNumber: data['nomor_seri'] as String? ?? '',
        imageUrl: data['gambar_url'] as String?,
        warrantyStart: data['garansi_mulai'] != null
            ? DateTime.tryParse(data['garansi_mulai'].toString())
            : null,
        warrantyEnd: data['garansi_akhir'] != null
            ? DateTime.tryParse(data['garansi_akhir'].toString())
            : null,
        createdAt: DateTime.tryParse(data['dibuat_pada']?.toString() ?? '') ??
            DateTime.now(),
      );

  static String _roleToString(UserRole role) =>
      role == UserRole.admin ? 'admin' : 'pelanggan';

  static UserRole _roleFromString(String? value) =>
      (value ?? '').toLowerCase() == 'admin'
          ? UserRole.admin
          : UserRole.customer;
}
