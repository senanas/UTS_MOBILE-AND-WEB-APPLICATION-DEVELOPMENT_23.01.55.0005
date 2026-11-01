# Worksheet Minggu 6 — Widget, Layout, Halaman, dan Navigasi Flutter
# ChronoStore

**Nama:** Maheswari Shafa Helga  
**NIM:** 23.01.55.0005  
**Kelas:** A1  
**Nama project Flutter:** jam_tangan  
**Lokasi project:** C:\dev\jam_tangan  

---

## Latihan 1 — Widget Tree dan StatelessWidget vs StatefulWidget

| Pertanyaan | Jawaban |
|------------|---------|
| Apa perbedaan StatelessWidget dan StatefulWidget? | StatelessWidget tidak memiliki state yang berubah (immutable) — cocok untuk tampilan statis seperti teks, ikon, kartu. StatefulWidget memiliki state yang bisa berubah (mutable) — cocok untuk form, counter, halaman dengan data dinamis. |
| Widget StatelessWidget mana yang ada di project? | `AppScaffold` (wrapper layout responsif), `EmptyState` (keadaan kosong), `WatchCard` (kartu jam tangan), `StatusBadge` (lencana status), `DashboardScreen` (memakai Provider untuk data, bukan setState lokal) |
| Widget StatefulWidget mana yang ada di project? | `MainShell` (mengelola `_currentIndex`), `LoginScreen` (form + obscure toggle), `WatchFormScreen` (form input + date picker), `RegisterScreen`, `TransactionFormScreen`, `ReminderScreen` |
| Di file mana `main()` dan root widget berada? | `lib/main.dart` — berisi `runApp(const ChronoStoreApp())` dengan `ChronoStoreApp extends StatelessWidget` |

---

## Latihan 2 — Layout Widgets

| Widget layout | Di mana dipakai? | Fungsi |
|---------------|-------------------|--------|
| Scaffold | Setiap screen (login, dashboard, watch_form, dll) | Menyediakan struktur dasar: AppBar, body, FAB, BottomNavigationBar |
| AppBar | `AppScaffold._buildNarrow()` dan `_buildWide()` | Menampilkan judul halaman dan actions (menu popup, info user) |
| Column | `LoginScreen`, `WatchFormScreen`, `DashboardScreen`, `EmptyState` | Menyusun widget secara vertikal (form fields, kartu ringkasan) |
| Row | `DashboardScreen` (quick actions), `WatchFormScreen` (date pickers), `LoginScreen` (register link) | Menyusun widget secara horizontal |
| Padding / SizedBox | Semua screen — memakai `AppSizes.spacingMd`, `AppSizes.spacingLg`, dll | Memberi jalan antar elemen (spacing konsisten kelipatan 8) |
| Card / ListTile | `DashboardScreen` (pengingat servis), `WatchListScreen` (daftar jam) | Menampilkan informasi dalam kartu dengan konten terstruktur |
| ListView / SingleChildScrollView | `WatchFormScreen` (form panjang), `DashboardScreen` (konten yang bisa di-scroll) | Memungkinkan konten melebihi tinggi layar untuk di-scroll |
| GridView.count | `DashboardScreen` (kartu ringkasan admin) | Menampilkan 4 kartu ringkasan (Total Jam, Stok, Garansi, Stok Habis) dengan crossAxisCount responsif (4 untuk web, 2 untuk mobile) |
| FilledButton / ElevatedButton | `LoginScreen` (tombol Masuk), `WatchFormScreen` (tombol Simpan), `DashboardScreen` (tombol Tambah Jam) | Aksi utama dengan warna primer #C9A227 |
| OutlinedButton | `WatchFormScreen` (date pickers), `DashboardScreen` (tombol Transaksi) | Aksi sekunder dengan border, latar putih |
| SegmentedButton | `WatchFormScreen` (pilih tipe mesin: Quartz/Automatic/Smart) | Pilihan eksklusif antar beberapa opsi |

---

## Latihan 3 — Satu File per Halaman

| Halaman | File | Stateful? | Deskripsi |
|---------|------|-----------|-----------|
| Login | `lib/screens/login_screen.dart` | Ya | Form login dengan validasi email/password, obscure toggle, SnackBar error |
| Register | `lib/screens/register_screen.dart` | Ya | Form registrasi pelanggan baru |
| Main Shell | `lib/screens/main_shell.dart` | Ya | Mengelola navigasi antar 3 halaman utama via `_currentIndex` |
| Dashboard | `lib/screens/dashboard_screen.dart` | Tidak | Ringkasan toko (admin) / katalog (pelanggan) dengan GridView responsif |
| Data Jam (Watch List) | `lib/screens/watch_list_screen.dart` | Ya | Daftar jam tangan dengan filter, pencarian, empty state |
| Form Jam Tangan | `lib/screens/watch_form_screen.dart` | Ya | Form tambah/edit jam tangan dengan 6+ field dan validasi |
| Detail Jam Tangan | `lib/screens/watch_detail_screen.dart` | Ya | Detail jam tangan + riwayat servis |
| Pengingat (Reminder) | `lib/screens/reminder_screen.dart` | Ya | Daftar pengingat servis terdekat |
| Riwayat Servis | `lib/screens/service_history_screen.dart` | Ya | Riwayat servis per jam tangan |
| Transaksi | `lib/screens/transaction_screen.dart` | Ya | Daftar transaksi penjualan |
| Form Transaksi | `lib/screens/transaction_form_screen.dart` | Ya | Form pencatatan transaksi baru |

**Catatan:** Modul menggunakan `lib/pages/`, project menggunakan `lib/screens/` — keduanya setara (konvensi penamaan folder). Struktur satu file per halaman sudah dipenuhi.

---

## Latihan 4 — Navigasi

| Butir navigasi | Implementasi |
|----------------|--------------|
| NavigationBar untuk halaman utama | `BottomNavigationBar` di `AppScaffold._buildNarrow()` dengan 3 destinasi: Dashboard, Data Jam, Pengingat. Mengelola index via `MainShell._currentIndex` |
| Navigator.push ke halaman anak | `LoginScreen` → `MainShell` (pushAndRemoveUntil), `DashboardScreen` → `WatchFormScreen` (push), `DashboardScreen` → `TransactionScreen` (push), `LoginScreen` → `RegisterScreen` (push) |
| Navigator.pop kembali | `WatchFormScreen._submit()` → `Navigator.pop(context)` setelah simpan berhasil |
| Named routes tersedia | `AppRoutes` di `lib/app/constants.dart` mendefinisikan 11 named routes (login, register, dashboard, watches, watchForm, watchDetail, services, reminder, catalog, transactions, transactionForm, profile) |
| Navigasi responsif (web) | `AppScaffold` beralih ke `NavigationRail` saat `MediaQuery.of(context).size.width >= 600` — mengganti BottomNavigationBar dengan sidebar vertikal |

### Diagram alur navigasi:

```
LoginScreen
  ├──→ RegisterScreen (push)
  └──→ MainShell (pushAndRemoveUntil)
         ├── Dashboard (index 0)
         │     ├──→ WatchFormScreen (push) [admin]
         │     ├──→ TransactionScreen (push)
         │     └──→ Reminder (onNavTap(2))
         ├── WatchList (index 1)
         │     ├──→ WatchFormScreen (push) [tambah/edit]
         │     └──→ WatchDetailScreen (push)
         │           └──→ ServiceHistoryScreen (push)
         └── Reminder (index 2)
               └──→ ServiceHistoryScreen (push)
```

---

## Latihan 5 — Tema dan Cek Responsif

| Butir tema | Implementasi |
|------------|--------------|
| ColorScheme.fromSeed | `AppTheme.light` menggunakan `ColorScheme.fromSeed(seedColor: AppColors.primary)` dengan Material 3 (`useMaterial3: true`) |
| Warna primer | #C9A227 (emas) — didefinisikan di `AppColors.primary`, dipakai untuk tombol, ikon terpilih, border fokus |
| Tema ElevatedButton | `ElevatedButtonThemeData` — latar #C9A227, teks #222222, tinggi 48px, radius 8px |
| Tema OutlinedButton | `OutlinedButtonThemeData` — latar putih, teks #666666, border #E5E5E5, tinggi 48px |
| Tema InputDecoration | `InputDecorationTheme` — filled, border outline radius 8px, focused border emas, error border merah |
| Tema Card | `CardThemeData` — latar putih, elevation 0, border #E5E5E5, radius 12px |
| Tema AppBar | `AppBarTheme` — latar putih, teks #222222, elevation 0 |
| Tema BottomNav | `BottomNavigationBarThemeData` — latar putih, item terpilih emas, item tidak terpilih #999999 |
| TextTheme | 5 level: titleLarge (24px), titleMedium (18px), bodyLarge (16px), bodyMedium (14px), labelLarge (16px) |
| Ukuran spacing | `AppSizes` — spacingXs=4, spacingSm=8, spacingMd=16, spacingLg=24, spacingXl=32 (kelipatan 8) |

### Cek responsif:

| Lebar layar | Komponen yang berubah |
|-------------|----------------------|
| < 600px (mobile) | `BottomNavigationBar` (3 item), GridView crossAxisCount=2 (dashboard admin) |
| >= 600px (web/tablet) | `NavigationRail` (sidebar vertikal), GridView crossAxisCount=4 (dashboard admin) |

**Implementasi:** `AppScaffold` memeriksa `MediaQuery.of(context).size.width >= 600` dan memanggil `_buildWide()` atau `_buildNarrow()`. Dashboard juga memakai MediaQuery untuk menentukan crossAxisCount GridView.

---

## Latihan 6 — Empty State dan Error Handling

| Butir | Implementasi |
|-------|--------------|
| Widget empty state | `lib/widgets/empty_state.dart` — `EmptyState` StatelessWidget dengan ikon, pesan, dan opsional tombol aksi |
| Pesan empty state | Didefinisikan di `AppConstants`: "Belum ada data jam tangan", "Belum ada riwayat servis", "Tidak ada pengingat aktif", "Belum ada transaksi" |
| Penggunaan | Dipakai di `WatchListScreen`, `ReminderScreen`, `TransactionScreen`, `ServiceHistoryScreen` saat data kosong |
| Error handling | SnackBar dengan warna `AppColors.error` (#C62828) untuk login gagal, validasi form, dll |

---

## Refleksi Individu

| Pertanyaan | Jawaban |
|------------|---------|
| Apakah semua halaman Must sudah terhubung? | Ya — Login, Dashboard, Data Jam, dan Pengingat sudah terhubung via BottomNavigationBar (mobile) / NavigationRail (web). Halaman anak (Form Jam, Detail Jam, Transaksi, Servis) terhubung via Navigator.push. Total 11 halaman, jauh melebihi minimum 3 halaman Must. |
| Apakah cek responsif sudah berjalan? | Ya — AppScaffold beralih antara BottomNavigationBar dan NavigationRail di breakpoint 600px. Dashboard GridView juga menyesuaikan crossAxisCount (2 → 4). Saat dijalankan di Chrome, window bisa di-resize untuk melihat perubahannya. |
| Kendala teknis apa yang muncul? | Tidak ada kendala signifikan. Modul menggunakan konvensi `lib/pages/` sedangkan project menggunakan `lib/screens/` — ini hanya perbedaan nama folder, fungsinya sama. Widget tree dan layout sudah sesuai konsep yang diajarkan. |
| Apa yang masih perlu diperbaiki? | Perbaikan Figma dari penilaian dosen Minggu 4: (1) tambah frame keadaan kosong/galat, (2) samakan menu web dengan mobile, (3) lengkapi prototipe klik. Di kode Flutter, empty state sudah diimplementasi — tinggal menyamakan di Figma. |

---

## Definition of Done Checklist

| Butir | Status |
|-------|--------|
| Minimal 3 halaman Must terhubung dan bisa dinavigasi | Ya — 11 halaman terhubung (Login, Register, Dashboard, WatchList, WatchForm, WatchDetail, Reminder, ServiceHistory, Transaction, TransactionForm, MainShell) |
| Menggunakan NavigationBar untuk halaman utama | Ya — BottomNavigationBar (mobile) / NavigationRail (web >= 600px) dengan 3 destinasi |
| Menggunakan Navigator.push/pop untuk halaman anak | Ya — push ke WatchFormScreen, WatchDetailScreen, TransactionScreen, dll. pop dari WatchFormScreen setelah simpan |
| Tema dengan ColorScheme.fromSeed | Ya — AppTheme.light dengan seedColor #C9A227, Material 3 |
| Cek responsif (>= 600px berubah layout) | Ya — AppScaffold beralih BottomNav → NavigationRail, Dashboard GridView crossAxisCount 2 → 4 |
| Empty state untuk daftar kosong | Ya — widget EmptyState reusable di 4+ screen |
| Satu file per halaman di lib/ | Ya — 11 file di lib/screens/, masing-masing satu kelas utama |
| Minimal 3 commit di repository | Ya — commit 1: inisialisasi, commit 2: README + worksheet Minggu 5, commit 3: worksheet Minggu 6 |

---

## Catatan Tambahan

1. **Struktur project lebih lengkap dari contoh modul (RoomBook):** Modul meminta 3 halaman Must, project sudah memiliki 11 halaman dengan fitur lengkap (CRUD jam tangan, transaksi, servis, pengingat, autentikasi dengan role admin/pelanggan).
2. **Provider pattern:** Project menggunakan `MultiProvider` dengan 4 provider (Auth, Watch, Service, Transaction) — lebih advanced dari setState sederhana yang diajarkan di modul, tapi sesuai dengan persiapan transisi ke Firebase di minggu-minggu berikutnya.
3. **Repository pattern:** Data layer terpisah di `lib/repositories/` dengan mock data — memudahkan migrasi ke Firebase nanti.
