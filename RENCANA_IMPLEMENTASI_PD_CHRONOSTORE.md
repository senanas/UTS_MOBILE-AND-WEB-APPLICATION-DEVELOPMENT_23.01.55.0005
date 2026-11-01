# Rencana Implementasi PD — ChronoStore

**Nama**: Maheswari Shafa H. (23.01.55.0005)  
**Aplikasi**: ChronoStore — Sistem Informasi Manajemen Stok, Garansi, dan Servis Jam Tangan  
**Tanggal**: 26 Oktober 2026  

---

## 1. Pendahuluan

Dokumen ini berisi rencana implementasi (PD) untuk aplikasi ChronoStore menggunakan **Flutter + Dart**. Pada fase awal ini, **belum menggunakan Firebase** — semua data akan disimpan secara **lokal (mock/static data)** sampai dinyatakan siap untuk integrasi Firebase. Arsitektur dirancang agar transisi dari data lokal ke Firebase dapat dilakukan dengan perubahan minimal pada layer repository.

### Prinsip implementasi
- **Local-first**: semua operasi CRUD memakai data lokal/mock di memori atau SharedPreferences/JSON.
- **Repository pattern**: isolasi sumber data agar mudah diganti Firebase nanti.
- **Satu kode, dua peran**: aplikasi membaca role (admin/pelanggan) dan menampilkan UI sesuai role.
- **Wireframe sebagai acuan visual**: gunakan hasil Minggu 4 sebagai panduan layout.

---

## 2. Halaman yang akan diimplementasi (10 halaman)

### Halaman Must (8 halaman — wajib untuk MVP)

| Kode | Halaman | Role | Deskripsi |
|------|---------|------|-----------|
| H1 | Login | Umum | Form email + password. Validasi kosong. Simulasi login dengan data mock. |
| H2 | Register | Umum | Form daftar akun baru: nama, email, password, pilih role (admin/pelanggan). |
| H3 | Dashboard (Admin) | Admin | Ringkasan: jumlah jam tangan, total stok, garansi aktif, pengingat servis. Akses ke menu utama. |
| H4 | Data Jam Tangan | Admin | Daftar jam tangan dalam bentuk list/card. Tombol Tambah, Search/Filter. Aksi per item: Edit, Hapus. |
| H5 | Form Jam Tangan | Admin | Form tambah/edit: nama, merek, model, tipe mesin, harga, stok, nomor seri, masa garansi (mulai/akhir), foto (asset/placeholder). Validasi: field wajib, stok tidak negatif, nomor seri unik. |
| H6 | Detail Jam Tangan | Admin & Pelanggan | Informasi lengkap: foto, spesifikasi, garansi, stok. Tombol "Catat Servis" (admin). Tombol "Beli/Pesan" (pelanggan). |
| H7 | Riwayat Servis | Admin | Daftar servis per jam tangan + form catat servis (tanggal, jenis, deskripsi, biaya, servis berikutnya). |
| H8 | Pengingat | Admin | Daftar garansi & servis yang mendekati jatuh tempo. Diurutkan berdasarkan tanggal terdekat. |

### Halaman Should (2 halaman — setelah MVP dasar berjalan)

| Kode | Halaman | Role | Deskripsi |
|------|---------|------|-----------|
| H9 | Katalog Pelanggan | Pelanggan | Tampilan katalog jam tangan (card dengan foto, nama, harga, status stok). Tanpa aksi edit. |
| H10 | Transaksi | Admin & Pelanggan | Daftar transaksi + form catat transaksi (pilih jam, jumlah, total). Admin bisa lihat semua; pelanggan lihat miliknya. |

---

## 3. Arsitektur & Struktur Folder

```
chronostore/
├── lib/
│   ├── main.dart                      # Entry point, routing, tema
│   ├── app/
│   │   ├── theme.dart                 # Warna (emas #C9A227, dll), tipografi, ukuran
│   │   ├── routes.dart                # Named routes / navigator
│   │   └── constants.dart             # Konstanta: nama koleksi, label, ukuran
│   ├── models/
│   │   ├── watch.dart                 # Model Jam Tangan
│   │   ├── service_record.dart        # Model Riwayat Servis
│   │   ├── warranty.dart              # Model Garansi (embedded di watch)
│   │   ├── transaction.dart           # Model Transaksi
│   │   └── user_account.dart          # Model User + role
│   ├── repositories/
│   │   ├── watch_repository.dart      # Interface + impl lokal
│   │   ├── service_repository.dart    # Interface + impl lokal
│   │   ├── transaction_repository.dart# Interface + impl lokal
│   │   ├── auth_repository.dart       # Interface + impl lokal (mock login)
│   │   └── mock_data.dart             # Data simulasi statis
│   ├── services/
│   │   ├── auth_service.dart          # Logika login/register (mock)
│   │   ├── validation_service.dart    # Validasi stok, nomor seri, field wajib
│   │   └── reminder_service.dart      # Hitung garansi/servis jatuh tempo
│   ├── providers/                     # State management (Provider/ChangeNotifier)
│   │   ├── auth_provider.dart         # Status login, role user
│   │   ├── watch_provider.dart        # Daftar jam, CRUD, filter
│   │   ├── service_provider.dart      # Daftar servis, catat servis
│   │   ├── transaction_provider.dart  # Daftar transaksi
│   │   └── reminder_provider.dart     # Pengingat
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── watch_list_screen.dart     # Data Jam Tangan / Katalog
│   │   ├── watch_form_screen.dart     # Form tambah/edit
│   │   ├── watch_detail_screen.dart   # Detail Jam Tangan
│   │   ├── service_history_screen.dart# Riwayat Servis
│   │   ├── reminder_screen.dart       # Pengingat
│   │   ├── transaction_screen.dart    # Transaksi
│   │   └── profile_screen.dart        # (Could — belakangan)
│   ├── widgets/
│   │   ├── watch_card.dart            # Kartu jam tangan (list/katalog)
│   │   ├── empty_state.dart           # Pesan "Belum ada data..."
│   │   ├── status_badge.dart          # Badge garansi/servis/stok
│   │   ├── bottom_nav.dart            # Bottom navigation (3 item)
│   │   ├── sidebar_nav.dart           # Sidebar untuk web
│   │   └── form_field.dart            # Reusable form field dengan validasi
│   └── utils/
│       ├── date_utils.dart            # Format tanggal, hitung selisih
│       └── id_generator.dart          # Generate ID unik (nomor seri cek)
├── assets/
│   ├── images/                        # Placeholder gambar jam tangan
│   └── icons/                         # Ikon kustom jika perlu
├── test/
│   ├── models/
│   ├── repositories/
│   └── widgets/
└── pubspec.yaml
```

---

## 4. Model Data (Local — Mock)

### 4.1 User
```dart
class UserAccount {
  String id;
  String name;
  String email;
  String password;      // mock — tidak di-hash di fase lokal
  UserRole role;         // admin | pelanggan
}
```

### 4.2 Watch
```dart
class Watch {
  String id;
  String name;
  String brand;
  String model;
  WatchType movementType;   // automatic | quartz | solar
  int price;
  int stock;
  String serialNumber;      // unik
  String? imageUrl;         // path asset atau URL placeholder
  DateTime? warrantyStart;
  DateTime? warrantyEnd;
  DateTime createdAt;
}
```

### 4.3 ServiceRecord
```dart
class ServiceRecord {
  String id;
  String watchId;           // relasi ke Watch
  DateTime serviceDate;
  String serviceType;       // ringan, berkala, besar
  String description;
  int? cost;
  DateTime? nextServiceDate;
}
```

### 4.4 Transaction
```dart
class Transaction {
  String id;
  String watchId;
  int quantity;
  int totalPrice;
  DateTime transactionDate;
  String customerName;
  TransactionStatus status;  // pending | completed | cancelled
}
```

---

## 5. Fase Implementasi

### FASE 1 — Fondasi & Navigasi (Minggu 1 PD)

**Tujuan**: Aplikasi bisa berjalan dengan navigasi dasar dan tema.

| Langkah | Deskripsi |
|---------|-----------|
| 1.1 | Setup project Flutter, pubspec.yaml (provider, intl, shared_preferences) |
| 1.2 | Buat `theme.dart` (warna emas #C9A227, teks #222, status colors) |
| 1.3 | Buat `constants.dart` dan `routes.dart` |
| 1.4 | Buat bottom navigation (Dashboard, Data Jam, Pengingat) |
| 1.5 | Buat sidebar untuk web (NavigationRail) |
| 1.6 | Buat screen dasar (skeleton) untuk semua 10 halaman dengan placeholder |
| 1.7 | Implementasi responsif: mobile < 600px → bottom nav; >= 600px → sidebar |

**Output**: Aplikasi berjalan, navigasi antar halaman berfungsi, semua halaman ada skeleton.

---

### FASE 2 — Model, Mock Data & Repository (Minggu 1-2 PD)

**Tujuan**: Data simulasi tersedia, repository pattern siap.

| Langkah | Deskripsi |
|---------|-----------|
| 2.1 | Buat semua model (User, Watch, ServiceRecord, Transaction) |
| 2.2 | Buat `mock_data.dart` — 5-8 jam tangan contoh, 3-4 servis, 2-3 transaksi |
| 2.3 | Buat interface repository + implementasi lokal (List in-memory) |
| 2.4 | Buat auth_service mock (cek email/password hardcoded) |
| 2.5 | Buat validation_service (stok negatif, nomor seri duplikat, field wajib) |
| 2.6 | Buat reminder_service (hitung tanggal jatuh tempo) |
| 2.7 | Setup Provider/ChangeNotifier untuk state management |

**Output**: Semua data mock bisa diakses dari provider. Repositories siap diganti Firebase nanti.

---

### FASE 3 — Login, Register & Role Routing (Minggu 2 PD)

**Tujuan**: User bisa login/register dan diarahkan sesuai role.

| Langkah | Deskripsi |
|---------|-----------|
| 3.1 | Implementasi Login screen (form email + password + tombol Masuk) |
| 3.2 | Validasi input kosong, tampilkan pesan error |
| 3.3 | Cek kredensial via auth_repository (mock) |
| 3.4 | Jika sukses → simpan role di auth_provider → route ke Dashboard (admin) atau Katalog (pelanggan) |
| 3.5 | Implementasi Register screen (nama, email, password, pilih role) |
| 3.6 | Register menyimpan akun baru ke list mock |
| 3.7 | Tombol Logout (kembali ke Login) |

**Output**: Login & register berfungsi. Role menentukan halaman awal dan menu yang tampil.

---

### FASE 4 — CRUD Jam Tangan (Minggu 2-3 PD)

**Tujuan**: Admin bisa tambah, lihat, edit, hapus jam tangan.

| Langkah | Deskripsi |
|---------|-----------|
| 4.1 | Data Jam Tangan screen: list card dengan foto, nama, nomor seri, stok, badge garansi |
| 4.2 | Search bar (cari nama/merek) + filter (tipe mesin, status garansi) |
| 4.3 | Tombol Tambah Jam Tangan → buka Form Jam Tangan |
| 4.4 | Form Jam Tangan: semua field + validasi (wajib, stok ≥ 0, nomor seri unik) |
| 4.5 | Tombol Simpan → simpan ke repository → kembali ke daftar |
| 4.6 | Edit: tap item → buka Form dengan data terisi |
| 4.7 | Hapus: long-press atau ikon hapus → dialog konfirmasi → hapus |
| 4.8 | Detail Jam Tangan: tampilkan semua info + garansi + akses ke Riwayat Servis |
| 4.9 | Empty state: "Belum ada data jam tangan" + tombol Tambah |

**Output**: CRUD jam tangan lengkap dengan validasi dan empty states.

---

### FASE 5 — Riwayat Servis & Pengingat (Minggu 3 PD)

**Tujuan**: Admin bisa catat servis dan lihat pengingat.

| Langkah | Deskripsi |
|---------|-----------|
| 5.1 | Riwayat Servis screen: daftar servis per jam tangan |
| 5.2 | Form catat servis: tanggal, jenis, deskripsi, biaya, servis berikutnya |
| 5.3 | Simpan servis → relasi ke watchId |
| 5.4 | Pengingat screen: daftar garansi & servis mendekati jatuh tempo |
| 5.5 | Urutkan berdasarkan tanggal terdekat |
| 5.6 | Badge warna: merah (lewat), kuning (≤7 hari), hijau (>7 hari) |
| 5.7 | Empty state untuk Pengingat dan Riwayat Servis |

**Output**: Servis tercatat, pengingat menampilkan data jatuh tempo.

---

### FASE 6 — Katalog Pelanggan & Transaksi (Minggu 3-4 PD)

**Tujuan**: Pelanggan bisa lihat katalog dan buat transaksi.

| Langkah | Deskripsi |
|---------|-----------|
| 6.1 | Katalog Pelanggan: grid/list card jam tangan (foto, nama, harga, status stok) |
| 6.2 | Detail untuk pelanggan: read-only, tombol "Pesan" bukan "Edit" |
| 6.3 | Form Transaksi: pilih jam, isi jumlah, hitung total otomatis |
| 6.4 | Simpan transaksi → kurangi stok jam tangan |
| 6.5 | Daftar Transaksi: admin lihat semua, pelanggan lihat miliknya |
| 6.6 | Status transaksi (pending/completed/cancelled) |

**Output**: Katalog pelanggan berfungsi, transaksi tercatat, stok berkurang otomatis.

---

### FASE 7 — Polish, Empty States & Error Handling (Minggu 4 PD)

**Tujuan**: Aplikasi siap untuk demo.

| Langkah | Deskripsi |
|---------|-----------|
| 7.1 | Pastikan semua halaman punya empty state |
| 7.2 | Tambah error handling (try-catch, pesan error user-friendly) |
| 7.3 | Konsistensi margin/spacing (kelipatan 8) |
| 7.4 | Cek responsif di mobile dan web |
| 7.5 | Splash screen / app icon (opsional) |
| 7.6 | Testing manual semua alur (login → CRUD → servis → transaksi) |
| 7.7 | Push ke GitHub dengan commit history yang rapi |

**Output**: Aplikasi siap demo, semua fitur Must berfungsi.

---

## 6. Peta Transisi ke Firebase (nantinya)

Ketika kamu bilang **"siap"**, transisi dilakukan dengan langkah berikut — **tanpa mengubah UI/screen**:

| Sekarang (Lokal) | Nanti (Firebase) | Yang berubah |
|-------------------|-------------------|--------------|
| `auth_repository` (mock list) | Firebase Auth | Ganti implementasi interface, tambah `firebase_auth` package |
| `watch_repository` (List in-memory) | Cloud Firestore `watches` collection | Ganti CRUD ke Firestore queries |
| `service_repository` (List) | Cloud Firestore `services` collection | Sama |
| `transaction_repository` (List) | Cloud Firestore `transactions` collection | Sama |
| `shared_preferences` (session) | Firebase Auth session | Otomatis via FirebaseAuth.instance |
| Gambar: asset lokal | Firebase Storage | Upload via `firebase_storage` |

**Karena sudah pakai repository pattern, hanya file di `repositories/` yang perlu diubah. Screen, provider, dan model tetap sama.**

---

## 7. Dependencies (pubspec.yaml — fase lokal)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # State management
  intl: ^0.19.0             # Format tanggal & angka
  shared_preferences: ^2.3.3 # Simpan session login (mock)
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

> Catatan: `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage` **belum ditambahkan** sampai dinyatakan siap.

---

## 8. Timeline Ringkas

| Minggu PD | Fase | Output utama |
|-----------|------|--------------|
| Minggu 1 | Fase 1 + Fase 2 | Navigasi + tema + mock data + repository |
| Minggu 2 | Fase 3 + Fase 4 awal | Login/register/role + daftar jam + form |
| Minggu 3 | Fase 4 akhir + Fase 5 | CRUD lengkap + servis + pengingat |
| Minggu 4 | Fase 6 + Fase 7 | Katalog pelanggan + transaksi + polish |

---

## 9. Prioritas MoSCoW Implementasi

| Prioritas | Fitur | Kapan |
|-----------|-------|------|
| **Must** | Login, Register, Dashboard, CRUD Jam, Detail, Servis, Pengingat, Katalog, Transaksi, Role-based | Fase 1-6 |
| **Should** | Search/filter, Upload gambar (asset), Edit/hapus, Empty states | Fase 4-7 |
| **Could** | Profile/settings, Detail transaksi, Badge warna pengingat | Fase 7 / setelah |
| **Won't now** | Firebase, Payment gateway, Notifikasi WhatsApp, Kalender eksternal | Setelah dinyatakan siap |
