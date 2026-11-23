import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';
import '../services/kebijakan_peran.dart';
import '../services/layanan_chronostore.dart';
import '../services/layanan_firestore.dart';

/// Repository autentikasi — Minggu 9 Firebase Auth + Minggu 10 Firestore.
///
/// Firebase Authentication tidak punya kolom `role`. Mulai Minggu 10 peran
/// dibaca dari dokumen `users/{uid}` di Cloud Firestore, sehingga pilihan
/// "Daftar sebagai Admin" benar-benar tersimpan di cloud dan ikut terbawa
/// ketika login di browser/perangkat lain. Penyimpanan lokal Minggu 9 tetap
/// dipertahankan sebagai cadangan bila Firestore belum aktif / sedang offline.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LayananChronoStore _layanan;

  AuthRepository({LayananChronoStore? layanan})
      : _layanan = layanan ?? LayananFirestore();

  static const _roleKeyPrefix = 'chronostore_role_';
  static final Map<String, UserRole> _roleCache = {};

  /// Muat cadangan peran lokal sebelum widget pertama dibangun (dipanggil di
  /// `main`). Nilai dari Firestore tetap yang utama.
  static Future<void> loadRoles() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_roleKeyPrefix)) continue;
      final uid = key.substring(_roleKeyPrefix.length);
      final value = prefs.getString(key);
      _roleCache[uid] = UserRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => UserRole.customer,
      );
    }
  }

  /// Firebase User -> UserAccount (model lama ChronoStore tetap dipakai UI).
  UserAccount? _toAccount(User? user) {
    if (user == null) return null;
    return UserAccount(
      id: user.uid,
      name: user.displayName ?? (user.email?.split('@').first ?? 'Pengguna'),
      email: user.email ?? '',
      password: '', // password tidak pernah disimpan di aplikasi
      role: _roleCache[user.uid] ?? UserRole.customer,
    );
  }

  /// Tulis profil `users/{uid}` bila belum ada, lalu baca peran dari sana.
  ///
  /// Urutan keputusan (penting untuk akun lama):
  /// 1. Email yang masuk daftar bootstrap admin SELALU Admin. Dokumen
  ///    `users/{uid}` yang masih `pelanggan` langsung diperbaiki (self-heal).
  /// 2. Cache lokal admin (akun didaftarkan sebagai Admin) juga memperbaiki
  ///    dokumen lama yang belum tersinkron.
  /// 3. Selain itu, nilai Firestore dipercaya — termasuk promosi manual lewat
  ///    Console — supaya admin tidak pernah otomatis turun jadi pelanggan.
  /// 4. Bila Firestore gagal (belum dibuat / Rules belum publish / offline),
  ///    tetap kembalikan peran hasil kebijakan agar aplikasi tidak macet.
  Future<UserAccount?> _akunDariFirestore(User user) async {
    final email = user.email ?? '';
    final peranCache = _roleCache[user.uid] ?? UserRole.customer;
    final paksaAdmin = KebijakanPeran.adalahEmailAdmin(email) ||
        peranCache == UserRole.admin;
    UserRole peran = paksaAdmin ? UserRole.admin : peranCache;

    try {
      await _layanan.simpanProfilSaatLogin(
        uid: user.uid,
        email: email,
        namaLengkap: user.displayName,
        peran: peran,
      );

      final peranFirestore = await _layanan.bacaPeran(user.uid);
      if (paksaAdmin) {
        if (peranFirestore != UserRole.admin) {
          await _layanan.perbaruiPeran(user.uid, UserRole.admin);
        }
        peran = UserRole.admin;
      } else if (peranFirestore != null) {
        peran = peranFirestore;
      }
    } catch (e) {
      debugPrint('Gagal menyinkron peran dari Firestore: $e');
      // Tetap pakai `peran` hasil kebijakan (tidak memaksa Pelanggan).
    }

    _roleCache[user.uid] = peran;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_roleKeyPrefix${user.uid}', peran.name);
    } catch (e) {
      debugPrint('Gagal menyimpan cadangan peran lokal: $e');
    }
    return _toAccount(user)!.copyWith(role: peran);
  }

  /// Aliran status login. `asyncMap` dipakai supaya setiap kali status berubah
  /// (termasuk saat refresh browser) peran dibaca ulang dari Firestore.
  Stream<UserAccount?> get authState =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        return _akunDariFirestore(user);
      });

  /// Nilai awal saat provider pertama kali dibuat (mencegah kedip halaman).
  UserAccount? get currentUser => _toAccount(_auth.currentUser);

  Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    return await _akunDariFirestore(user) ?? _toAccount(user)!;
  }

  Future<UserAccount> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;

    // Email bootstrap admin selalu Admin; email lain mengikuti pilihan
    // "Daftar sebagai" pada form register.
    final peranEfektif = KebijakanPeran.tentukan(email, role);

    // Simpan peran SEGERA (sinkron) agar authStateChanges yang aktif saat
    // pendaftaran langsung membawa peran yang benar, lalu tulis ke Firestore.
    _roleCache[user.uid] = peranEfektif;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_roleKeyPrefix${user.uid}', peranEfektif.name);
    await user.updateDisplayName(name);
    await _layanan.simpanProfilSaatLogin(
      uid: user.uid,
      email: email,
      namaLengkap: name,
      peran: peranEfektif,
    );

    return _toAccount(user)!.copyWith(name: name, role: peranEfektif);
  }

  Future<void> logout() => _auth.signOut();
}
