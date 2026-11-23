# Panduan Minggu 9 — Menghubungkan Firebase & Login Email/Password

**Project:** ChronoStore (`C:\dev\jam_tangan`)  
**Sumber:** `modul-minggu-09-firebase-login.docx` + `materi-ajar-minggu-09-firebase-login.pptx`  
**Target wajib:** Chrome, paket Spark, penyedia Email/Password saja, **belum** memakai Firestore.

Panduan ini dibuat berdasarkan kondisi asli folder `jam_tangan`, jadi tiap langkah menyebut **file mana yang dibuka** dan **kode apa yang ditempel**.

> **Status 9 November 2026 — SUDAH DITERAPKAN.** Semua perubahan kode di bawah sudah ditulis ke project:
> `flutter analyze` → *No issues found*, `flutter test` → 4/4 lulus, `flutter build web` → berhasil.
> Tabel audit di bab 0 sengaja dipertahankan sebagai **kondisi SEBELUM** perubahan.
> **Perbaikan 19:18:** "daftar sebagai Admin tapi tampil Pelanggan" sudah diatasi — peran kini disimpan per `uid` di `SharedPreferences` dan dimuat lewat `AuthRepository.loadRoles()` di `main()`. Lihat **Soal role** di Langkah 4. Akun yang dibuat sebelum perbaikan harus didaftar ulang.
> Yang masih perlu kamu kerjakan sendiri: **Langkah 1** (cek Firebase Console) dan **Langkah 10** (uji manual di Chrome, screenshot, tabel uji, lalu commit & push).
>
> **Catatan 16 November 2026 — Minggu 10 sudah diterapkan.** Dokumen ini adalah
> catatan historis Minggu 9. `auth_repository.dart` sekarang membaca peran dari
> dokumen `users/{uid}` di Cloud Firestore (SharedPreferences hanya cadangan),
> dan data jam/transaksi sudah pindah ke Firestore. Lihat
> [`PANDUAN_MINGGU_10_FIRESTORE.md`](PANDUAN_MINGGU_10_FIRESTORE.md) untuk kode
> dan langkah terbaru. Potongan kode di bawah **jangan ditempel ulang**.

---

## 0. Posisi project kamu sekarang (hasil pemeriksaan)

| Bagian                                  | Status           | Keterangan                                                                                          |
| --------------------------------------- | ---------------- | --------------------------------------------------------------------------------------------------- |
| `pubspec.yaml`                          | ✅ Sudah          | `firebase_core: ^5.1.0`, `firebase_auth: ^7.0.1` (terkunci 5.1.0 / 7.0.1, sama persis dengan modul) |
| `lib/firebase_options.dart`             | ✅ Sudah          | Jalur cadangan (salin manual), `projectId: jam-tangan-490e3`                                        |
| `firebase.json`                         | ✅ Sudah          | Konfigurasi web dari FlutterFire                                                                    |
| `lib/main.dart`                         | ✅ Sudah          | `WidgetsFlutterBinding.ensureInitialized()` + `await Firebase.initializeApp(...)`                   |
| `flutter analyze`                       | ✅ Bersih         | "No issues found!"                                                                                  |
| `lib/repositories/auth_repository.dart` | ❌ Belum          | Masih `MockData.users` (data di memori), **belum memanggil Firebase sama sekali**                   |
| `lib/providers/auth_provider.dart`      | ❌ Belum          | `login()` / `register()` masih sinkron & mengembalikan `bool`, belum `async/await`                  |
| `lib/main.dart` → `home`                | ❌ Belum          | Masih `LoginScreen()`, belum ada `authStateChanges()` + `StreamBuilder`                             |
| Pindah halaman                          | ❌ Belum          | Masih `Navigator.pushAndRemoveUntil(...)` dari halaman login                                        |
| Tombol Keluar                           | ❌ Belum          | Masih `auth.logout()` lokal, bukan `signOut()` Firebase                                             |
| Pesan kesalahan                         | ❌ Belum          | Belum ada penerjemah `e.code`                                                                       |
| Kotak "Akun demo"                       | ⚠️ Perlu dihapus | `admin@chronostore.id / admin123` sudah tidak berlaku setelah pindah ke Firebase                    |
| `test/widget_test.dart`                 | ⚠️ Akan gagal    | Test membuka widget yang memanggil Firebase                                                         |

**Kesimpulan:** Latihan 1 (setup Firebase) hampir selesai. Yang tersisa = **Latihan 2, 3, 4** dan bukti/luaran.

---

## 1. Konsep singkat supaya tidak bingung

| Istilah     | Artinya                 | Di ChronoStore                                       |
| ----------- | ----------------------- | ---------------------------------------------------- |
| Autentikasi | "Siapa kamu?"           | Masuk dengan email + password ke Firebase            |
| Otorisasi   | "Boleh apa?"            | `MainShell`/Dashboard hanya untuk yang sudah login   |
| Token       | Bukti sudah login       | Dikelola SDK Firebase, tidak kita simpan sendiri     |
| Sesi        | Berapa lama tetap masuk | Tetap masuk setelah refresh, sampai tekan **Keluar** |

**Ide utama minggu ini:** kita **tidak lagi menyimpan password** di aplikasi. Aplikasi mengirim email+password ke Firebase, Firebase yang memeriksa, lalu membalas status. Karena status bisa berubah kapan saja (login, logout, refresh), halaman tidak boleh dipindah dengan `Navigator`, tapi harus **mengikuti aliran** `authStateChanges()` lewat `StreamBuilder`.

```
LoginScreen --(email,password)--> FirebaseAuth --(User / error)--> authStateChanges()
                                                                   |
                                              StreamBuilder (AuthGate)
                                               /                    \
                                        belum login              sudah login
                                        LoginScreen               MainShell
```

---

## 2. Urutan langkah (ringkasan)

1. Cek Firebase Console (project, paket Spark, Email/Password aktif).
2. `flutter pub get` + `flutter run -d chrome`, pastikan tidak error → **commit ke-1**.
3. Buat `lib/services/auth_error.dart` (penerjemah kode error).
4. Ganti `lib/repositories/auth_repository.dart` (mock → Firebase).
5. Ganti `lib/providers/auth_provider.dart` (sinkron → async + stream).
6. Buat `lib/screens/auth_gate.dart`, lalu ubah `home` di `lib/main.dart`.
7. Ubah `login_screen.dart` & `register_screen.dart` (await, hapus Navigator, hapus akun demo).
8. Ubah tombol Keluar di `dashboard_screen.dart`.
9. Ganti `test/widget_test.dart` dengan unit test murni.
10. Uji 5 kasus, ambil screenshot, isi tabel uji → **commit ke-2**.

---

## 3. Langkah detail

### Langkah 1 — Cek Firebase Console

Buka <https://console.firebase.google.com> , login, pilih project **`jam-tangan-490e3`**.

1. Pastikan paket tetap **Spark** (gratis, tanpa billing account).
2. Buka **Build / Security → Authentication → Get started → Sign-in method**.  
   Aktifkan **Email/Password**, lalu **Save**. Ini wajib — kalau tidak, semua login gagal dengan `operation-not-allowed`.
3. Buka **Project settings → Your apps → aplikasi web (ikon `</>`)**.  
   Cocokkan `apiKey`, `appId`, `projectId`, `authDomain` dengan isi `lib/firebase_options.dart`. Kalau beda, salin ulang `firebaseConfig` ke file itu.
4. Buka **Authentication → Users**. Masih kosong tidak apa-apa; nanti akun simulasi muncul di sini.
5. `localhost` sudah termasuk *Authorized domains* secara default, jadi `flutter run -d chrome` bisa langsung.

> `firebase_options.dart` berisi **pengenal project, bukan password**, jadi aman di-commit. Yang tidak boleh pernah ditulis di kode adalah password akun Anda.

### Langkah 2 — Pastikan aplikasi nyala, lalu commit

```bash
cd C:\dev\jam_tangan
flutter pub get
flutter analyze
flutter run -d chrome
```

Kalau muncul `No Firebase App '[DEFAULT]' has been created`, berarti `await Firebase.initializeApp(...)` belum dijalankan sebelum `runApp` — cek lagi `main.dart`.

Kalau sudah tampil tanpa error merah:

```bash
git add -A
git commit -m "Hubungkan project ke Firebase"
git push
```



> Catatan: `web/index.html` **tidak perlu** ditambahi script Firebase JS SDK. Versi `firebase_core_web 4.1.0` yang terpasang menyuntikkan SDK-nya sendiri secara otomatis.  
> Minggu ini jangan jalankan di Android/desktop: `firebase_options.dart` baru berisi konfigurasi **web**. Android butuh `google-services.json` (di luar batas pertemuan ini).

---

### Langkah 3 — Buat `lib/services/auth_error.dart` (file baru)

Ini implementasi tabel "Menerjemahkan Kode Error" (modul bab 6, slide 19).

```dart
/// Menerjemahkan FirebaseAuthException.code menjadi pesan yang dipahami pengguna.
class AuthError {
  static String message(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        // Sengaja disamakan agar orang lain tidak bisa menebak email terdaftar.
        return 'Email atau password salah';
      case 'invalid-email':
        return 'Format email belum benar';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Password terlalu lemah, minimal 6 karakter';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak dapat terhubung. Periksa koneksi internet.';
      case 'operation-not-allowed':
        return 'Login email/password belum diaktifkan';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
```

---

### Langkah 4 — Ganti seluruh isi `lib/repositories/auth_repository.dart`

File lama memakai `MockData.users` dan menyimpan password plaintext di memori. Ganti dengan pembungkus `FirebaseAuth`.

**Trik penting:** kita tetap memakai model `UserAccount` yang lama. Jadi `DashboardScreen`, `TransactionScreen`, dll. **tidak perlu diubah**. Firebase `User` diterjemahkan menjadi `UserAccount`.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';

/// Repository autentikasi — Minggu 9: Firebase Authentication.
/// Tidak ada lagi daftar user dan password yang disimpan di aplikasi.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firebase Auth TIDAK punya kolom role. Untuk sementara (Minggu 9), peran
  /// yang dipilih saat mendaftar disimpan di penyimpanan lokal dengan kunci
  /// berdasarkan uid. Minggu 10 data ini pindah ke Firestore.
  static const _roleKeyPrefix = 'chronostore_role_';
  static final Map<String, UserRole> _roleCache = {};

  /// Muat peran tersimpan sebelum widget pertama dibangun (dipanggil di main).
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

  /// Firebase User -> UserAccount (dipakai UI lama ChronoStore).
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

  /// Aliran status login, dipakai AuthProvider.
  Stream<UserAccount?> get authState =>
      _auth.authStateChanges().map(_toAccount);

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
    return _toAccount(credential.user)!;
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

    // Simpan peran SEGERA (sinkron) agar aliran authStateChanges yang aktif
    // saat pendaftaran langsung membawa peran yang benar, lalu simpan permanen.
    _roleCache[user.uid] = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_roleKeyPrefix${user.uid}', role.name);
    await user.updateDisplayName(name);

    return _toAccount(user)!.copyWith(name: name);
  }

  Future<void> logout() => _auth.signOut();
}
```

**Soal role (baca ini, penting):** aplikasi kamu punya tampilan Admin vs Pelanggan, tapi Firebase Auth cuma menyimpan `uid`, `email`, `displayName`, dan token — **tidak ada kolom role**. Kalau peran di-hardcode `UserRole.customer`, maka "daftar sebagai Admin" tetap tampil Pelanggan (persis seperti screenshot: `admin (Pelanggan)`). Nama "admin" yang muncul itu hanya `displayName`, bukan peran.

Solusi sementara yang dipakai di sini: peran yang dipilih di `SegmentedButton` disimpan di `SharedPreferences` dengan kunci `chronostore_role_<uid>`, lalu dimuat ulang oleh `AuthRepository.loadRoles()` di `main()` sebelum `runApp`. Jadi peran **benar saat daftar dan tetap benar setelah refresh**. Ini masih jembatan: Minggu 10 peran disimpan di Firestore supaya bisa dibaca lintas perangkat dan tidak bisa diubah sembarangan dari sisi klien.

> ⚠️ Akun yang dibuat **sebelum** perbaikan ini tidak punya data peran tersimpan, jadi tetap terbaca Pelanggan. Daftar akun simulasi baru (atau hapus user lama di Firebase Console → Authentication → Users, lalu daftar ulang) untuk melihat tampilan Admin.

---

### Langkah 5 — Ganti seluruh isi `lib/providers/auth_provider.dart`

Perubahan kunci: `login()` / `register()` jadi `Future<bool>` dengan `await` + `try/catch`, dan provider **mendengarkan** aliran status login.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_account.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_error.dart';

/// State management untuk autentikasi (Minggu 9: Firebase).
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  UserAccount? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _currentUser = _authRepo.currentUser;
    _authRepo.authState.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCustomer => _currentUser?.role == UserRole.customer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepo.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthError.message(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepo.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthError.message(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Status pengguna dikosongkan otomatis oleh aliran authState.
  Future<void> logout() => _authRepo.logout();

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```


### Langkah 6 — Buat `lib/screens/auth_gate.dart`, lalu ubah `lib/main.dart`

Ini versi ChronoStore dari `cek_status_login.dart` di modul (bab 5, slide 17).

**File baru `lib/screens/auth_gate.dart`:**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'main_shell.dart';

/// Halaman mengikuti status login Firebase (cek status login, Minggu 9).
/// Belum login -> LoginScreen, sudah login -> MainShell.
/// Sesi bertahan setelah refresh karena status dibaca dari Firebase.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Gagal memeriksa status login')),
          );
        }
        if (snapshot.hasData) return const MainShell();
        return const LoginScreen();
      },
    );
  }
}
```

**Di `lib/main.dart`** tambahkan import, satu `await`, lalu ganti `home`:

```dart
import 'repositories/auth_repository.dart';
import 'screens/auth_gate.dart';   // sebelumnya: import 'screens/login_screen.dart';
```

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Auth tidak menyimpan role; muat peran yang dipilih saat mendaftar
  // sebelum widget apa pun dibangun (penting agar benar setelah refresh).
  await AuthRepository.loadRoles();

  runApp(const ChronoStoreApp());
}
```

```dart
        home: const AuthGate(),     // sebelumnya: home: const LoginScreen(),
```

---

### Langkah 7 — Ubah `login_screen.dart` dan `register_screen.dart`

#### `lib/screens/login_screen.dart`

1. Hapus baris `import '../screens/main_shell.dart';` (sudah tidak dipakai).
2. Ganti seluruh method `_submit()` menjadi:

```dart
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Tidak perlu Navigator: AuthGate otomatis pindah ke MainShell
    // begitu Firebase mengirim status "sudah login".
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
```

1. **Hapus blok "Akun demo"** (mulai dari komentar `// Info akun demo` sampai `Container(...)` penutup, yaitu elemen terakhir di dalam `Column`). Ganti dengan:

```dart
                    const SizedBox(height: AppSizes.spacingLg),
                    const Text(
                      'Gunakan email & password simulasi, jangan password asli Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
```

Alasannya: `admin@chronostore.id / admin123` itu akun `MockData`, **tidak ada di Firebase**, jadi kalau dibiarkan kamu akan bingung kenapa tidak bisa login. Sekaligus perbarui tabel **Akun Demo** di `README.md` supaya tidak menyesatkan.

#### `lib/screens/register_screen.dart`

1. Hapus `import '../screens/main_shell.dart';`.
2. Ganti `_submit()` menjadi:

```dart
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    // Pindah halaman ditangani AuthGate, bukan Navigator.
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Pendaftaran gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
```

1. Biarkan `SegmentedButton` "Daftar sebagai" tetap ada — pilihannya **sekarang benar-benar disimpan** (secara lokal per `uid`) oleh `AuthRepository.register()`. Lihat **Soal role** di Langkah 4.

> `onPressed: auth.isLoading ? null : _submit` tidak perlu diubah; method `async` tetap bisa dipakai di sini. Tombol otomatis nonaktif selama menunggu jawaban Firebase (`_isLoading`), sesuai modul.

---

### Langkah 8 — Tombol Keluar di `lib/screens/dashboard_screen.dart`

Cari `onSelected:` di `PopupMenuButton`, ganti menjadi:

```dart
          onSelected: (value) async {
            if (value == 'logout') {
              await auth.logout(); // -> FirebaseAuth.instance.signOut()
              return;
            }
            if (value == 'transactions') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionScreen()),
              );
            }
          },
```

`auth.logout()` sekarang memanggil `signOut()`. Setelah itu `authStateChanges()` mengirim `null`, `AuthGate` kembali ke `LoginScreen`, dan provider mengosongkan `currentUser`. **Tidak ada `Navigator` di sini.**

---

### Langkah 9 — Perbaiki `test/widget_test.dart`

Test lama memompa `ChronoStoreApp`, yang sekarang memanggil Firebase → akan gagal dengan `No Firebase App '[DEFAULT]' has been created`. Modul menyarankan memakai `halamanAwal` pada test; untuk project ini paling sederhana adalah mengganti jadi unit test murni yang tidak menyentuh Firebase:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:jam_tangan/services/validation_service.dart';

void main() {
  test('Email kosong ditolak', () {
    expect(ValidationService.validateEmail('').isValid, false);
  });

  test('Format email salah ditolak', () {
    expect(ValidationService.validateEmail('nama').isValid, false);
  });

  test('Password minimal 6 karakter', () {
    expect(ValidationService.validatePassword('123').isValid, false);
    expect(ValidationService.validatePassword('123456').isValid, true);
  });
}
```

Opsional: samakan pesan di `lib/services/validation_service.dart` dengan modul, misalnya `'Format email belum benar'` dan `'Password minimal 6 karakter'`, supaya isi tabel uji cocok dengan yang tampil di layar.

---

### Langkah 10 — Jalankan, uji, kumpulkan bukti

```bash
cd C:\dev\jam_tangan
flutter analyze          # harus "No issues found!"
flutter test              # unit test di atas harus lulus
flutter run -d chrome
```

Lalu di browser: **Daftar** 1–2 akun simulasi (mis. `shafa@chronostore.test` / `rahasia123`), cek muncul di **Authentication → Users**, **refresh** browser (harus tetap masuk), lalu tekan **Keluar** (harus kembali ke halaman Masuk).

#### Tabel uji login (wajib ≥ 5 kasus — modul bab 6 / slide 22)

| # | Kasus uji                    | Input                             | Hasil yang diharapkan                                     | Hasil nyata |
| - | ---------------------------- | --------------------------------- | --------------------------------------------------------- | ----------- |
| 1 | Login benar                  | Akun simulasi yang sudah didaftar | `MainShell`/Dashboard tampil                              |             |
| 2 | Password salah               | Email benar, password salah       | `Email atau password salah`                               |             |
| 3 | Email tidak valid            | `nama` (tanpa `@`)                | `Format email belum benar` (atau pesan validasi aplikasi) |             |
| 4 | Kolom kosong                 | —                                 | Kedua kolom menampilkan pesan                             |             |
| 5 | Daftar dengan email terpakai | Email yang sudah didaftar         | `Email sudah terdaftar. Silakan masuk.`                   |             |
| 6 | Refresh setelah login        | F5                                | Tetap masuk (sesi bertahan)                               |             |
| 7 | Tekan Keluar                 | Menu akun → Keluar                | Kembali ke halaman Masuk                                  |             |

#### Luaran yang dikumpulkan

- [ ] Project Spark terhubung, Email/Password aktif, tanpa billing
- [ ] Daftar, masuk, keluar berjalan di Chrome
- [ ] Halaman utama hanya terbuka setelah login; sesi bertahan saat refresh
- [ ] Pesan kesalahan jelas (tidak membocorkan email terdaftar)
- [ ] Tabel uji ≥ 5 kasus terisi
- [ ] Screenshot **Authentication → Users**
- [ ] ≥ 2 commit baru ter-push

```bash
git add -A
git commit -m "Tambah login Firebase, cek status, dan pesan kesalahan"
git push
```

---

## 4. Masalah umum (dari modul bab 7 / slide 23)

| Gejala                                         | Penyebab                                             | Solusi                                                           |
| ---------------------------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------- |
| `flutterfire tidak dikenali`                   | Pub cache belum di PATH                              | Pakai jalur cadangan (salin manual) — **sudah kamu pakai**, aman |
| `No Firebase App '[DEFAULT]' has been created` | `initializeApp` belum ditunggu                       | Pastikan `await Firebase.initializeApp(...)` sebelum `runApp`    |
| `api-key-not-valid`                            | `apiKey` salah salin                                 | Salin ulang `firebaseConfig` dari Project settings               |
| `operation-not-allowed`                        | Email/Password belum aktif                           | Aktifkan di Authentication → Sign-in method                      |
| Selalu muncul pesan umum                       | Kode error belum diterjemahkan                       | Tambah `case` di `AuthError.message`                             |
| Halaman tidak berganti setelah login           | `home` masih `LoginScreen()`                         | `home: const AuthGate()`                                         |
| Widget test gagal                              | Test memanggil Firebase                              | Pakai unit test murni (Langkah 9)                                |
| Akun demo lama tidak bisa login                | Itu akun `MockData`, bukan Firebase                  | Hapus kotak "Akun demo", daftar akun simulasi baru               |
| Error saat dijalankan di Android               | `firebase_options.dart` hanya berisi konfigurasi web | Minggu ini target **Chrome** saja                                |
| Daftar sebagai Admin tapi tampilan tetap Pelanggan | Firebase Auth tidak punya kolom `role`; peran belum disimpan | Simpan peran per `uid` (lihat **Soal role**, Langkah 4); akun lama harus didaftar ulang |
| `flutter test`: `Invalid WebSocket upgrade request` | Variabel proxy mengganggu koneksi `flutter_tester` | `HTTP_PROXY= HTTPS_PROXY= http_proxy= https_proxy= flutter test --no-pub` |

---

## 5. Batas pertemuan ini & persiapan Minggu 10

- **Boleh:** Chrome, paket Spark, Email/Password, email+password simulasi.
- **Hindari:** billing account, login Google/nomor telepon, password asli Anda, Firestore.
- Data jam tangan, servis, dan transaksi **masih di memori** (`MockData`) — hilang saat refresh. Itu memang beda: **sesi login** bertahan karena disimpan Firebase, **data bisnis** belum. Inilah yang akan dibenahi Minggu 10 dengan Firestore (collection & field, tambah data, tampilkan data), sekaligus tempat menyimpan `role` admin/pelanggan dengan benar.
- Pengayaan (tidak wajib): lupa password dengan `FirebaseAuth.instance.sendPasswordResetEmail(email: email)`.
