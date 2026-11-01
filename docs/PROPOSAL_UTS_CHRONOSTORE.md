# Proposal UTS — ChronoStore
# Sistem Informasi Manajemen Toko Jam Tangan

**Mata Kuliah:** Mobile and Web Application Development  
**Kelas:** A1 (Senin, 10.20)  
**Semester:** Ganjil 2026/2027  
**Pengampu:** Jeffri Alfa Razaq & Dwi Budi Santoso  

**Nama:** Maheswari Shafa Helga  
**NIM:** 23.01.55.0005  
**Kelas:** A1  
**Judul Aplikasi:** ChronoStore — Sistem Informasi Manajemen Toko Jam Tangan  
**Repository GitHub:** https://github.com/senanas/UTS_MOBILE-AND-WEB-APPLICATION-DEVELOPMENT_23.01.55.0005  
**Tautan Figma:** https://www.figma.com/design/dR2XS04F45XfPhO9x2LBrD/23.01.55.0005---SI-Manajemen-Jam-Tangan-Wireframe-Minggu-4?node-id=0-1&t=Wm5CuiVQ7ukApOV4-1  

---

## 1. Problem Statement

Pemilik toko jam tangan menghadapi tiga masalah utama dalam mengelola operasional sehari-hari:

1. **Pencatatan stok dan nomor seri yang manual dan rentan kesalahan.** Setiap jam tangan memiliki nomor seri unik yang harus dilacak untuk keperluan garansi dan autentikasi. Saat ini pencatatan dilakukan di buku atau spreadsheet yang tidak terstruktur, sehingga sulit mencari jam tangan tertentu, memeriksa ketersediaan stok, dan memastikan tidak ada duplikasi nomor seri.

2. **Informasi tipe mesin dan spesifikasi yang tidak terorganisir.** Jam tangan memiliki berbagai tipe mesin (Automatic, Quartz, Solar) yang masing-masing memerlukan perawatan berbeda. Tanpa sistem yang terstruktur, informasi ini tersebar dan sulit diakses saat pelanggan bertanya atau saat admin perlu menentukan jadwal servis.

3. **Riwayat servis dan pengingat garansi yang tidak terkelola.** Garansi jam tangan memiliki masa berlaku, dan servis berkala perlu dijadwalkan berdasarkan tipe mesin. Tanpa sistem pengingat, pemilik toko sering melewatkan masa berakhirnya garansi atau jadwal servis, yang berdampak pada kepuasan pelanggan dan potensi pendapatan dari layanan servis.

**Mengapa penting:** Toko jam tangan menangani produk bernilai tinggi dengan nomor seri unik dan masa garansi. Kekacauan dalam pencatatan dapat menyebabkan kerugian finansial (stok hilang, garansi gagal), penurunan kepercayaan pelanggan, dan ketidakefisienan operasional. ChronoStore mengatasi masalah ini dengan sistem terpusat yang mengelola data produk, stok, garansi, dan riwayat servis dalam satu aplikasi.

---

## 2. Persona Pengguna Utama

### Persona 1: Admin/Pemilik Toko (Pengguna Utama)

| Atribut | Detail |
|---------|--------|
| Nama | Andi Pratama |
| Usia | 34 tahun |
| Pekerjaan | Pemilik toko jam tangan "Pratama Watch" |
| Pendidikan | SMA |
| Kemampuan teknologi | Cukup — menggunakan WhatsApp, Excel, dan marketplace online setiap hari |
| Tujuan | Mengelola stok jam tangan, melacak nomor seri, memantau garansi, dan menjadwalkan servis dengan efisien |
| Tantangan | Pencatatan manual di buku sering ketinggalan, sulit mencari jam tangan tertentu, lupa jadwal servis dan garansi |
| Kebutuhan | Dashboard ringkasan, CRUD jam tangan, pencarian cepat, pengingat garansi dan servis |

### Persona 2: Pelanggan (Pengguna Sekunder)

| Atribut | Detail |
|---------|--------|
| Nama | Siti Rahma |
| Usia | 28 tahun |
| Pekerjaan | Karyawan kantoran, kolektor jam tangan |
| Kemampuan teknologi | Tinggi — aktif di media sosial dan e-commerce |
| Tujuan | Melihat katalog jam tangan yang tersedia, memesan, dan melacak transaksi |
| Kebutuhan | Katalog yang mudah dijelajahi, detail produk lengkap, riwayat transaksi |

---

## 3. User Stories

| No | Sebagai | Saya ingin | Sehingga |
|----|---------|------------|----------|
| US-01 | Admin | menambah, mengedit, dan menghapus data jam tangan (nama, merek, model, tipe mesin, harga, stok, nomor seri) | data produk selalu terbarui dan akurat |
| US-02 | Admin | nomor seri divalidasi secara unik | tidak ada dua jam tangan dengan nomor seri yang sama |
| US-03 | Admin | melihat dan mencatat riwayat servis per jam tangan | bisa melacak kapan servis terakhir dilakukan dan kapan harus servis berikutnya |
| US-04 | Admin | menerima pengingat saat garansi atau servis mendekati jatuh tempo | tidak melewatkan kesempatan untuk menghubungi pelanggan atau menjadwalkan servis |
| US-05 | Pelanggan | melihat katalog jam tangan yang tersedia dengan filter tipe mesin | bisa menemukan jam tangan sesuai preferensi dengan cepat |

### Kriteria Penerimaan per User Story:

**US-01 — Kelola Data Jam Tangan:**
- Admin dapat mengisi form dengan field: nama, merek, model, tipe mesin (Automatic/Quartz/Solar), harga, stok, nomor seri, dan masa garansi opsional
- Harga harus berupa angka positif (> 0)
- Stok harus berupa angka non-negatif (>= 0)
- Semua field wajib diisi kecuali masa garansi
- Setelah simpan, jam tangan muncul di daftar dan dashboard

**US-02 — Nomor Seri Unik:**
- Saat admin memasukkan nomor seri yang sudah ada, sistem menolak dengan pesan "Nomor seri sudah digunakan"
- Saat edit jam tangan, nomor seri sendiri tidak dianggap duplikat

**US-03 — Riwayat Servis:**
- Admin dapat melihat riwayat servis per jam tangan di halaman detail
- Admin dapat mencatat servis baru: tanggal, tipe servis (Ringan/Berkala/Besar), deskripsi, biaya, dan tanggal servis berikutnya
- Riwayat ditampilkan dalam urutan kronologis terbalik (terbaru di atas)

**US-04 — Pengingat:**
- Sistem menampilkan daftar jam tangan dengan garansi atau servis yang akan jatuh tempo dalam 7 hari
- Pengingat ditampilkan di halaman terpisah dan diringkas di dashboard
- Setiap item pengingat menampilkan nama jam tangan, jenis (garansi/servis), dan tanggal jatuh tempo

**US-05 — Katalog Pelanggan:**
- Pelanggan dapat melihat semua jam tangan yang stok-nya > 0
- Pelanggan dapat memfilter berdasarkan tipe mesin (Semua, Automatic, Quartz, Solar)
- Pelanggan dapat mencari berdasarkan nama atau merek
- Pelanggan dapat melihat detail jam tangan dan membuat pesanan

---

## 4. Kebutuhan Fungsional dan Prioritas

### Kebutuhan Fungsional Utama:

| Kode | Kebutuhan | Prioritas | User Story |
|------|-----------|-----------|------------|
| KF-01 | Autentikasi (login & register dengan email/password) | Must | (pendukung semua US) |
| KF-02 | CRUD data jam tangan dengan validasi | Must | US-01 |
| KF-03 | Validasi nomor seri unik | Must | US-02 |
| KF-04 | Riwayat servis per jam tangan (catat & tampilkan) | Must | US-03 |
| KF-05 | Katalog jam tangan untuk pelanggan dengan filter & pencarian | Must | US-05 |
| KF-06 | Pengingat garansi & servis (jatuh tempo <= 7 hari) | Should | US-04 |
| KF-07 | Transaksi/pesanan pelanggan | Should | US-05 |
| KF-08 | Dashboard ringkasan (total jam, stok, garansi aktif, stok habis) | Should | (pendukung operasional) |
| KF-09 | Detail jam tangan dengan info garansi | Should | US-01, US-05 |
| KF-10 | Integrasi Firebase (Auth + Firestore) | Won't (fase UAS) | — |
| K11 | Pembayaran online | Won't | — |
| K12 | Integrasi WhatsApp untuk notifikasi pelanggan | Won't | — |

### Penjelasan prioritas (MoSCoW):

- **Must:** Fitur inti yang harus ada untuk UTS — autentikasi, CRUD jam tangan, validasi nomor seri, riwayat servis, dan katalog. Tanpa fitur ini, aplikasi tidak berfungsi sebagai sistem manajemen toko jam tangan.
- **Should:** Fitur pendukung yang meningkatkan nilai aplikasi — pengingat, transaksi, dan dashboard ringkasan. Sudah diimplementasi di kode, ditampilkan sebagai nilai tambah.
- **Won't (fase UAS):** Integrasi Firebase (Auth + Firestore), pembayaran online, dan notifikasi WhatsApp — direncanakan untuk fase implementasi Pertemuan 9-15 menuju UAS.

---

## 5. User Flow

### Alur Admin (utama):

```
Login → Dashboard → Data Jam Tangan → Form Tambah/Edit Jam Tangan
                                   → Detail Jam Tangan → Riwayat Servis → Catat Servis
                                   → (kembali ke daftar)
                → Pengingat → (klik item) → Detail Jam Tangan
```

### Alur Pelanggan:

```
Login/Register → Dashboard (katalog singkat) → Data Jam Tangan (katalog lengkap)
                                              → Detail Jam Tangan → Buat Pesanan
                                              → (kembali ke katalog)
              → Transaksi saya (riwayat)
```

### Detail alur dari login sampai proses utama selesai:

1. **Login** — pengguna memasukkan email & password. Jika salah, muncul SnackBar error. Jika benar, masuk ke Dashboard.
2. **Dashboard** — admin melihat ringkasan (total jam, stok, garansi aktif, stok habis) + quick actions (tambah jam, transaksi) + pengingat servis terdekat. Pelanggan melihat katalog singkat.
3. **Data Jam Tangan** — admin melihat daftar lengkap dengan pencarian & filter. Pelanggan melihat katalog.
4. **Form Tambah Jam** — admin mengisi form (8 field). Jika validasi gagal, pesan error muncul di tiap field. Jika sukses, SnackBar "Jam tangan ditambahkan" dan kembali ke daftar.
5. **Detail Jam** — melihat info lengkap + garansi + riwayat servis.
6. **Pengingat** — melihat daftar garansi/servis yang akan jatuh tempo.

---

## 6. Sitemap / Daftar Halaman

| Kode | Halaman | Tipe | Prioritas | File |
|------|---------|------|-----------|------|
| H1 | Login | Must | Must | lib/screens/login_screen.dart |
| H2 | Register | Must | Must | lib/screens/register_screen.dart |
| H3 | Dashboard | Must | Must | lib/screens/dashboard_screen.dart |
| H4 | Data Jam Tangan (daftar/katalog) | Must | Must | lib/screens/watch_list_screen.dart |
| H5 | Form Tambah/Edit Jam Tangan | Must | Must | lib/screens/watch_form_screen.dart |
| H6 | Detail Jam Tangan | Should | Should | lib/screens/watch_detail_screen.dart |
| H7 | Pengingat | Should | Should | lib/screens/reminder_screen.dart |
| H8 | Riwayat Servis | Must | Must | lib/screens/service_history_screen.dart |
| H9 | Transaksi (daftar) | Should | Should | lib/screens/transaction_screen.dart |
| H10 | Form Transaksi/Pesanan | Should | Should | lib/screens/transaction_form_screen.dart |
| H11 | Main Shell (navigasi) | Must | Must | lib/screens/main_shell.dart |

### Navigasi:

- **BottomNavigationBar** (mobile) / **NavigationRail** (web >= 600px) — 3 destinasi utama: Dashboard, Data Jam, Pengingat
- **Navigator.push/pop** — navigasi ke halaman anak (Form Jam, Detail Jam, Form Transaksi, dll)
- **Navigator.pushAndRemoveUntil** — dari Login ke MainShell (reset stack)

---

## 7. Wireframe / Figma

**Tautan Figma:** https://www.figma.com/design/dR2XS04F45XfPhO9x2LBrD/23.01.55.0005---SI-Manajemen-Jam-Tangan-Wireframe-Minggu-4?node-id=0-1&t=Wm5CuiVQ7ukApOV4-1

Wireframe dibuat di Minggu 4 untuk semua halaman Must (5 halaman mobile + 2 halaman web responsif). Wireframe mencakup:

- **Mobile (5 halaman Must):** Login, Dashboard, Data Jam Tangan, Form Jam Tangan, Riwayat Servis
- **Web responsif (minimal 2 halaman):** Dashboard (dengan NavigationRail), Data Jam Tangan
- **Style guide (diselaraskan ke Figma):** Latar `#151515`, kartu `#1B1B1B`, border `#4A4A4A`, aksen emas `#C9A227`, teks utama `#FFFFFF`, teks sekunder `#A0A0A0`, status (berhasil `#4CAF50`, menunggu `#ED8B00`, galat `#EF5350`). Rincian sampling warna: `docs/DESIGN_GUIDE_FIGMA.md`
- **Tipografi:** Judul 24px, Subjudul 18px, Isi 16px, Caption 14px

### Kesesuaian wireframe dengan aplikasi:

| Wireframe Figma | Aplikasi Flutter | Sesuai? |
|-----------------|------------------|---------|
| Login dengan email/password | LoginScreen (2 TextFormField + validator) | Ya |
| Dashboard dengan kartu ringkasan | DashboardScreen (GridView 4 kartu) | Ya |
| Daftar jam tangan dengan kartu | WatchListScreen (ListView + WatchCard) | Ya |
| Form tambah jam dengan field lengkap | WatchFormScreen (8 field, 4 jenis input) | Ya |
| Detail jam dengan riwayat servis | WatchDetailScreen + ServiceHistoryScreen | Ya |
| Web dengan sidebar | AppScaffold NavigationRail (>= 600px) | Ya |
| Empty state | EmptyState widget di 4+ screen | Ya (ditambahkan setelah revisi) |

---

## 8. Tech Stack

| Komponen | Teknologi | Status |
|----------|-----------|--------|
| Framework | Flutter 3.47.7 (channel stable) | Terpasang |
| Bahasa pemrograman | Dart 3.13.5 | Terpasang |
| State management | Provider (ChangeNotifier) | Terimplementasi |
| Target platform | Web (Chrome) — mobile responsive | Terdeteksi |
| Desain UI | Figma | Selesai (wireframe Minggu 4) |
| Version control | Git 2.55.0 + GitHub | Terpasang (3 commit) |
| Backend (rencana UAS) | Firebase Spark (gratis) | Rencana Pertemuan 9-15 |
| Database (rencana UAS) | Cloud Firestore | Rencana Pertemuan 9-15 |
| Autentikasi (rencana UAS) | Firebase Authentication | Rencana Pertemuan 9-15 |
| Hosting (rencana UAS) | Firebase Hosting | Rencana Pertemuan 9-15 |

### Arsitektur saat ini (fase lokal/mock):

```
UI Layer (screens/)
    ↕ (Provider)
State Layer (providers/ — ChangeNotifier)
    ↕
Data Layer (repositories/ — mock_data.dart)
    ↕
Model Layer (models/ — Watch, UserAccount, ServiceRecord, Transaction)
```

### Rencana migrasi ke Firebase:

1. **Pertemuan 9-10:** Setup Firebase project (Spark plan), tambah dependency `firebase_core`, `cloud_firestore`, `firebase_auth`
2. **Pertemuan 11-12:** Migrasi AuthRepository → Firebase Auth (email/password)
3. **Pertemuan 13-14:** Migrasi WatchRepository, ServiceRepository, TransactionRepository → Firestore (ganti mock_data dengan query Firestore)
4. **Pertemuan 15:** Deploy ke Firebase Hosting, finalisasi

---

## 9. Rancangan Database Firestore

### Collections dan Fields:

#### Collection: `users`

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| uid | String (document ID) | Ya | UID dari Firebase Auth |
| name | String | Ya | Nama lengkap pengguna |
| email | String | Ya | Email (dari Firebase Auth) |
| role | String | Ya | "admin" atau "customer" |
| createdAt | Timestamp | Ya | Tanggal dibuat |

**Catatan:** Password tidak disimpan di Firestore — ditangani oleh Firebase Auth.

#### Collection: `watches`

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| id | String (document ID) | Ya | Auto-generated ID Firestore |
| name | String | Ya | Nama jam tangan |
| brand | String | Ya | Merek |
| model | String | Ya | Model/kode |
| movementType | String | Ya | "automatic", "quartz", atau "solar" |
| price | Number | Ya | Harga dalam Rupiah (> 0) |
| stock | Number | Ya | Jumlah stok (>= 0) |
| serialNumber | String | Ya | Nomor seri unik |
| imageUrl | String | Tidak | URL gambar (opsional) |
| warrantyStart | Timestamp | Tidak | Awal masa garansi |
| warrantyEnd | Timestamp | Tidak | Akhir masa garansi |
| createdAt | Timestamp | Ya | Tanggal ditambahkan |

**Index:** `serialNumber` (unique check di aplikasi sebelum write)

#### Collection: `service_records`

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| id | String (document ID) | Ya | Auto-generated ID |
| watchId | String | Ya | Referensi ke watches.id |
| serviceDate | Timestamp | Ya | Tanggal servis |
| serviceType | String | Ya | "routine", "minor", atau "major" |
| description | String | Ya | Deskripsi pekerjaan |
| cost | Number | Tidak | Biaya servis |
| nextServiceDate | Timestamp | Tidak | Tanggal servis berikutnya |

**Index:** `watchId` (untuk query riwayat per jam tangan), `nextServiceDate` (untuk pengingat)

#### Collection: `transactions`

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| id | String (document ID) | Ya | Auto-generated ID |
| watchId | String | Ya | Referensi ke watches.id |
| watchName | String | Ya | Nama jam (snapshot) |
| quantity | Number | Ya | Jumlah dibeli |
| unitPrice | Number | Ya | Harga satuan (snapshot) |
| totalPrice | Number | Ya | Total harga |
| transactionDate | Timestamp | Ya | Tanggal transaksi |
| customerName | String | Ya | Nama pemesan |
| userId | String | Ya | UID pengguna yang membuat |
| status | String | Ya | "pending", "completed", atau "cancelled" |

**Index:** `userId` (untuk riwayat transaksi pelanggan), `transactionDate` (untuk sorting)

### Relasi antar collection:

```
users (uid)
  │
  ├── watches (id) ──┬── service_records (watchId)
  │                  │
  │                  └── transactions (watchId)
  │
  └── transactions (userId)
```

- **users → watches:** Tidak langsung (admin mengelola semua watch, tidak ada ownership per user)
- **watches → service_records:** One-to-many (satu jam tangan punya banyak catatan servis)
- **watches → transactions:** One-to-many (satu jam tangan bisa dibeli berkali-kali)
- **users → transactions:** One-to-many (satu pengguna punya banyak transaksi)

### Aturan keamanan (Security Rules) — rencana:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: bisa baca profil sendiri
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    // Watches: semua yang login bisa baca; hanya admin bisa tulis
    match /watches/{watchId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    // Service records: baca untuk yang login; tulis untuk admin
    match /service_records/{recordId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    // Transactions: baca transaksi sendiri atau semua untuk admin
    match /transactions/{txId} {
      allow read: if request.auth != null
        && (resource.data.userId == request.auth.uid
            || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
    }
  }
}
```

---

## 10. Data Simulasi

Saat ini aplikasi menggunakan mock data di `lib/repositories/mock_data.dart`:

| Entitas | Jumlah | Contoh |
|---------|--------|--------|
| Users | 2 | Admin (admin@chronostore.id/admin123), Pelanggan (pelanggan@chronostore.id/pelanggan123) |
| Watches | 6 | Seiko 5 Sports, Casio G-Shock, Citizen Eco-Drive, Timex Expedition, Orient Bambino, Casio Edifice |
| Service records | 4 | Servis untuk Seiko, Citizen, dan Orient |
| Transactions | 2 | Timex Expedition (completed), Casio G-Shock (pending) |

---

## 11. Kendala yang Dialami dan Pelajaran

1. **Android SDK tidak terpasang** — `flutter doctor` menunjukkan [X] Android toolchain. Tidak menghalangi karena target UTS adalah web (Chrome). Rencana: install Android SDK sebelum UAS untuk testing di emulator mobile.

2. **Visual Studio (desktop Windows) tidak terpasang** — desktop build tidak tersedia. Tidak diperlukan untuk UTS.

3. **Skor Figma Minggu 4: 83/100** — perlu perbaikan: (1) tambah frame keadaan kosong/galat, (2) samakan menu web dengan mobile, (3) lengkapi prototipe klik. Di kode Flutter, empty state sudah diimplementasi — perbaikan Figma akan dilakukan sebelum UTS.

4. **Repository belum di-push ke GitHub** — git repo lokal sudah ada 3 commit, perlu di-push ke remote. Akan dilakukan sebelum batas akhir UTS.

5. **Test coverage terbatas** — hanya 1 widget test. Rencana: tambah 9 test cases untuk validasi dan alur form.

---

## 12. Rencana Pertemuan 9-15

| Pertemuan | Rencana |
|-----------|---------|
| 9 | Setup Firebase project (Spark plan), tambah dependency, konfigurasi firebase_options.dart |
| 10 | Migrasi AuthRepository → Firebase Auth (email/password), sesi login dengan Firebase |
| 11 | Migrasi WatchRepository → Firestore (CRUD watches, cek serialNumber unik via query) |
| 12 | Migrasi ServiceRepository dan TransactionRepository → Firestore |
| 13 | Implementasi security rules, optimasi query (index, pagination) |
| 14 | Polish UI, tambah animasi, handle loading/error state dari Firestore |
| 15 | Deploy ke Firebase Hosting, finalisasi, persiapan UAS |
