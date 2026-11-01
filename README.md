# ChronoStore

Aplikasi manajemen stok, garansi, dan servis jam tangan. Proyek individu MK Mobile and Web Application Development.

## Identitas

- Nama: Maheswari Shafa Helga
- NIM: 23.01.55.0005
- Kelas: A1

## Deskripsi Singkat

ChronoStore adalah sistem informasi yang membantu pemilik/admin toko jam tangan mengelola data produk, stok, nomor seri, riwayat servis, dan pengingat garansi. Aplikasi dibangun dengan Flutter dan berjalan di mobile (Android) maupun web (Chrome). Pada fase ini data masih disimpan secara lokal (mock data); integrasi Firebase dilakukan pada tahap berikutnya.

## Tautan

- Desain Figma (Minggu 4): https://www.figma.com/design/shafa-chronostore-wireframe
- Repository GitHub: https://github.com/shafahelga/jam_tangan

## Cara Menjalankan

```bash
# Pastikan Flutter SDK terpasang dan terdeteksi
flutter doctor

# Masuk ke folder project
cd jam_tangan

# Install dependencies
flutter pub get

# Jalankan di Chrome
flutter run -d chrome
```

## Fitur Utama (MVP)

1. **Login & Register** — autentikasi dengan email/password (mock data)
2. **Dashboard** — ringkasan jumlah jam tangan, total stok, garansi aktif, pengingat servis
3. **Data Jam Tangan** — CRUD jam tangan dengan nomor seri, tipe mesin, garansi
4. **Detail Jam Tangan** — informasi lengkap + akses ke riwayat servis
5. **Riwayat Servis** — pencatatan servis per jam tangan dengan tanggal dan biaya
6. **Pengingat** — daftar garansi dan servis yang mendekati jatuh tempo

## Tech Stack

- Flutter + Dart
- Provider (state management)
- Shared Preferences (session lokal)
- Figma (desain UI)
- GitHub (version control)

## Struktur Project

```
jam_tangan/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app/
│   │   ├── theme.dart            # Tema warna (emas #C9A227)
│   │   └── constants.dart        # Konstanta & routes
│   ├── models/                   # Model data (Watch, User, Service, Transaction)
│   ├── repositories/             # Repository pattern (mock data)
│   ├── providers/                # State management (ChangeNotifier)
│   ├── screens/                  # 11 halaman (login, dashboard, dll)
│   ├── widgets/                  # Reusable widgets
│   ├── services/                 # Validation service
│   └── utils/                    # Date utils, ID generator
├── assets/
│   ├── images/
│   └── icons/
├── test/
│   └── widget_test.dart
└── pubspec.yaml
```

## Screenshot

![Screenshot Beranda](docs/screenshot-beranda.png)
