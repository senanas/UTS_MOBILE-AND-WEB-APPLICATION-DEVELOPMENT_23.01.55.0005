// Jalur cadangan: lib/firebase_options.dart
// (Modul Minggu 9 — "Menghubungkan project: pilih satu jalur")
//
// Nilai di bawah diambil dari firebaseConfig yang muncul saat mendaftarkan
// aplikasi web di Firebase Console (Project settings > Your apps > ikon </>).
// Ini PENGENAL project, bukan password, jadi boleh di-commit ke GitHub.
//
// Catatan: modul menonaktifkan Google Analytics dan belum memakai Firestore,
// sehingga measurementId dan storageBucket tidak wajib di minggu ini.
// Bila nanti dibutuhkan, tinggal tambahkan dua baris itu di sini.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3bMbzeCeshOhGBfslML4IMZOzAcrgSwU',
    appId: '1:205975312228:web:b2985f6363d541e2634c71',
    messagingSenderId: '205975312228',
    projectId: 'jam-tangan-490e3',
    authDomain: 'jam-tangan-490e3.firebaseapp.com',
    storageBucket: 'jam-tangan-490e3.firebasestorage.app',
    measurementId: 'G-9G698B4M44',
  );
}
