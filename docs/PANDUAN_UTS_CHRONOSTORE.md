# Panduan UTS — Video Presentasi ChronoStore
# Mobile and Web Application Development — Kelas A1

**Deadline:** Kamis, 5 November 2026, pukul 23.59 WIB  
**Durasi video:** Maksimal 10 menit  
**Bobot:** 25% dari nilai akhir  

---

## Timeline Video (Maksimal 10 Menit)

### Bagian 1 — Pembuka (0,5 menit)

**Script:**
> "Halo, nama saya Maheswari Shafa Helga, NIM 23.01.55.0005, Kelas A1. Aplikasi yang saya buat adalah ChronoStore — Sistem Informasi Manajemen Toko Jam Tangan."

**Tampilkan:** Slide/judul dengan nama, NIM, kelas, judul aplikasi, link GitHub.

---

### Bagian 2 — Masalah & Pengguna (1,5 menit)

**Script:**
> "Pemilik toko jam tangan menghadapi tiga masalah utama:
> 1. Pencatatan stok dan nomor seri yang masih manual dan rentan kesalahan.
> 2. Informasi tipe mesin dan spesifikasi yang tidak terorganisir.
> 3. Riwayat servis dan pengingat garansi yang tidak terkelola.
>
> Pengguna utama aplikasi adalah admin atau pemilik toko seperti Andi, 34 tahun, yang setiap hari mengelola puluhan jam tangan dengan nomor seri unik dan masa garansi berbeda-beda. Sebagai pengguna sekunder, pelanggan dapat melihat katalog dan memesan."

**Tampilkan:** Slide problem statement + persona (Andi Pratama).

**Jawab pertanyaan penguji #1:** "Masalah apa yang diselesaikan aplikasi Anda?" — jawab di sini.

**Jawab pertanyaan penguji #2:** "Siapa pengguna utamanya?" — jawab di sini.

---

### Bagian 3 — Kebutuhan & Prioritas (1 menit)

**Script:**
> "Saya memiliki 5 user story utama:
> 1. Admin menambah, mengedit, menghapus data jam tangan.
> 2. Nomor seri divalidasi unik.
> 3. Admin mencatat riwayat servis per jam tangan.
> 4. Admin menerima pengingat garansi dan servis.
> 5. Pelanggan melihat katalog dengan filter.
>
> Yang diprioritaskan (Must) adalah CRUD jam tangan, validasi nomor seri, riwayat servis, dan katalog. Pengingat dan transaksi adalah Should. Integrasi Firebase dan pembayaran online adalah Won't — direncanakan untuk fase UAS."

**Tampilkan:** Tabel user story + MoSCoW.

**Jawab pertanyaan penguji #3:** "Mengapa fitur ini yang diprioritaskan?" — jawab di sini.

---

### Bagian 4 — Rancangan (2 menit)

**Script:**
> "User flow dimulai dari Login → Dashboard → Data Jam Tangan → Form Tambah/Edit → Detail → Riwayat Servis.
>
> Sitemap terdiri dari 11 halaman. Navigasi utama menggunakan BottomNavigationBar di mobile dan NavigationRail di web.
>
> Wireframe Figma dibuat di Minggu 4 dengan style guide: warna primer emas #C9A227, teks #222222, latar #F7F7F7, dan warna status untuk berhasil, menunggu, dan galat."

**Tampilkan:** User flow diagram, sitemap, screenshot Figma wireframe (Login, Dashboard, Form Jam Tangan).

---

### Bagian 5 — Demo Prototype (3,5 menit) ⭐ BAGIAN TERPENTING

**Persiapan:** Jalankan `flutter run -d chrome` sebelum rekam. Siapkan data demo.

**Demo langkah-langkah:**

1. **Tampilkan halaman Login** (~20 detik)
   - Tunjukkan judul "ChronoStore"
   - Masukkan email kosong → submit → tampilkan pesan error "Email wajib diisi"
   - Masukkan email salah format → tampilkan "Format email tidak valid"
   - Masukkan email benar: `admin@chronostore.id`, password: `admin123`
   - Klik Masuk → navigasi ke Dashboard

2. **Tampilkan Dashboard** (~30 detik)
   - Tunjukkan 4 kartu ringkasan: Total Jam (6), Total Stok (34), Garansi Aktif, Stok Habis (1)
   - Tunjukkan pengingat servis terdekat
   - Tunjukkan tombol quick action (Tambah Jam, Transaksi)
   - Tunjukkan BottomNavigationBar (Dashboard, Data Jam, Pengingat)

3. **Buka Data Jam Tangan** (~30 detik)
   - Tunjukkan daftar 6 jam tangan (Seiko, Casio, Citizen, Timex, Orient, Casio Edifice)
   - Demo pencarian: ketik "Casio" → tampilkan hasil filter
   - Demo filter tipe: klik "Automatic" → tampilkan hasil
   - Tunjukkan empty state (jika ada, hapus semua filter dan cari "zzz" → tampilkan EmptyState)

4. **Demo Form Tambah Jam** (~60 detik) ⭐ KRITIS
   - Klik FAB "Tambah"
   - Isi form:
     - Nama: "Rolex Submariner"
     - Merek: "Rolex"
     - Model: "126610LN"
     - Tipe Mesin: pilih "Automatic" (SegmentedButton)
     - Harga: "125000000"
     - Stok: "2"
     - Nomor Seri: "SK-SRPD65-001" (sudah ada!) → tampilkan pesan error "Nomor seri sudah digunakan"
     - Ganti nomor seri: "RLX-126610-007"
   - Pilih tanggal garansi via showDatePicker
   - Submit dengan field kosong (hapus Nama) → tampilkan "Nama wajib diisi"
   - Isi kembali Nama → submit → tampilkan SnackBar "Jam tangan ditambahkan"
   - Kembali ke daftar → tunjukkan Rolex Submariner muncul di daftar

5. **Demo Validasi tambahan** (~20 detik)
   - Harga = 0 → "Harga harus lebih dari 0"
   - Stok = -5 → "Stok tidak boleh negatif"

6. **Demo Detail & Responsif** (~30 detik)
   - Klik salah satu jam → tampilkan detail
   - Tunjukkan riwayat servis
   - Resize window Chrome menjadi lebar → tunjukkan NavigationRail muncul (bukan BottomNav)

**Jawab pertanyaan penguji #5:** "Tunjukkan satu validasi pada form Anda: apa aturan bisnisnya, dan diturunkan dari user story/kriteria penerimaan yang mana?" — tunjukkan validasi nomor seri unik (US-02).

**Jawab pertanyaan penguji #6:** "Apa yang terjadi bila pengguna mengirim form kosong atau data di luar batas?" — tunjukkan pesan error per field.

---

### Bagian 6 — Rencana Teknis & Penutup (1,5 menit)

**Script:**
> "Tech stack yang saya pakai: Flutter dan Dart untuk frontend, Provider untuk state management. Saat ini data disimpan di memori (mock data). Rencana untuk Pertemuan 9-15: migrasi ke Firebase — Firestore untuk database, Firebase Auth untuk autentikasi, dan Firebase Hosting untuk deployment.
>
> Rancangan database Firestore memiliki 4 collection: users (uid, name, email, role), watches (name, brand, model, movementType, price, stock, serialNumber, warrantyStart, warrantyEnd), service_records (watchId, serviceDate, serviceType, cost), dan transactions (watchId, quantity, unitPrice, totalPrice, userId, status).
>
> Kendala yang saya alami: Android SDK belum terpasang sehingga belum bisa test di emulator mobile, dan skor Figma 83/100 dengan catatan perlu menambah empty state dan menyamakan menu web. Empty state sudah saya implementasi di kode Flutter.
>
> Yang belum selesai: integrasi Firebase, test coverage tambahan, dan screenshot untuk README. Rencana: selesaikan integrasi Firebase di Pertemuan 9-15 menuju UAS."

**Jawab pertanyaan penguji #4:** "Bagaimana data akan disimpan?" — jawab di sini (mock data saat ini, Firestore rencana).

**Jawab pertanyaan penguji #7:** "Bagian mana yang belum selesai, dan apa rencana Anda?" — jawab di sini.

---

## Jawaban Pertanyaan Penguji (Siapkan Semua)

### Pertanyaan Wajib (4):

**1. Masalah apa yang diselesaikan aplikasi Anda?**
> ChronoStore menyelesaikan tiga masalah: (1) pencatatan stok dan nomor seri jam tangan yang masih manual dan rentan duplikasi, (2) informasi tipe mesin dan spesifikasi yang tidak terorganisir, (3) riwayat servis dan pengingat garansi yang tidak terkelola. Aplikasi ini menggabungkan ketiga fungsi dalam satu sistem terpusat.

**2. Siapa pengguna utamanya?**
> Pengguna utama adalah admin atau pemilik toko jam tangan, seperti Andi (34 tahun) yang mengelola puluhan jam tangan dengan nomor seri unik. Pengguna sekunder adalah pelanggan yang melihat katalog dan memesan.

**3. Mengapa fitur ini yang diprioritaskan?**
> CRUD jam tangan dengan validasi nomor seri unik adalah inti dari manajemen toko — tanpa ini, tidak ada data untuk dikelola. Riwayat servis diprioritaskan karena pelanggan jam tangan premium mengharapkan layanan purna jual. Katalog diprioritaskan karena pelanggan perlu melihat produk sebelum membeli. Pengingat dan transaksi adalah Should karena meningkatkan nilai tetapi bukan inti yang membuat aplikasi berfungsi. Integrasi Firebase adalah Won't karena fase UTS fokus pada prototype lokal; Firebase akan diimplementasi menuju UAS.

**4. Bagaimana data akan disimpan?**
> Saat ini data disimpan di memori menggunakan mock data (List di Dart) yang dikelola oleh Provider (ChangeNotifier). Rencana untuk Pertemuan 9-15: migrasi ke Cloud Firestore dengan 4 collection (users, watches, service_records, transactions). Autentikasi akan menggunakan Firebase Auth. Rancangan field sudah disiapkan dan mengikuti kebutuhan bisnis — bukan acak.

### Pertanyaan Lanjutan (3):

**5. Tunjukkan satu validasi pada form Anda: apa aturan bisnisnya, dan diturunkan dari user story/kriteria penerimaan yang mana?**
> Validasi nomor seri unik. Aturan bisnisnya: tidak boleh ada dua jam tangan dengan nomor seri yang sama. Diturunkan dari US-02: "Admin ingin nomor seri divalidasi secara unik sehingga tidak ada dua jam tangan dengan nomor seri yang sama." Implementasi: validator memanggil `WatchProvider.isSerialNumberTaken()` yang mengecek seluruh daftar watches. Saat edit, nomor seri milik jam tangan itu sendiri di-skip (`excludeId: widget.watch?.id`).

**6. Apa yang terjadi bila pengguna mengirim form kosong atau data di luar batas?**
> Form kosong: `_formKey.currentState!.validate()` mengembalikan false, submit dihentikan, setiap field wajib menampilkan pesan error di bawahnya ("Nama wajib diisi", "Email wajib diisi", dll). Data di luar batas: harga = 0 → "Harga harus lebih dari 0"; harga negatif → "Harga harus berupa angka" (jika bukan angka) atau "Harga harus lebih dari 0"; stok negatif → "Stok tidak boleh negatif"; nomor seri duplikat → "Nomor seri sudah digunakan". Tidak ada data yang masuk ke daftar jika validasi gagal.

**7. Bagian mana yang belum selesai, dan apa rencana Anda menyelesaikannya sebelum UAS?**
> Yang belum selesai: (1) Integrasi Firebase (Auth + Firestore) — direncanakan Pertemuan 9-15 dengan migrasi bertahap per repository. (2) Test coverage — saat ini 1 test, rencana tambah 9 test untuk validasi dan alur form. (3) Screenshot untuk README — akan diambil saat `flutter run -d chrome`. (4) Perbaikan Figma (empty state, menu web, prototipe) — empty state sudah di kode, tinggal samakan di Figma. (5) Push ke GitHub — akan dilakukan sebelum batas akhir UTS.

---

## Checklist Sebelum Mengumpulkan

Berdasarkan UTS Brief Bagian 7:

| No | Butir | Status | Catatan |
|----|-------|--------|---------|
| 1 | flutter run berhasil; judul aplikasi dan halaman sesuai identitas project (DoD Minggu 5) | ✅ | Judul "ChronoStore", home: LoginScreen |
| 2 | Repository dapat dibuka; commit bertahap dengan pesan jelas; README lengkap dengan screenshot (DoD Minggu 5) | ⚠️ | 3 commit lokal, belum di-push ke GitHub. Screenshot belum ada |
| 3 | Minimal 3 halaman Must terhubung; navigasi utama dan push/pop bekerja; data simulasi dan satu keadaan kosong tampil (DoD Minggu 6) | ✅ | 11 halaman terhubung, BottomNav + push/pop, EmptyState widget di 4+ screen |
| 4 | Satu form dapat diuji: minimal 3 kolom, 2 jenis input, semua kolom tervalidasi, ada pesan status, data tampil di halaman daftar (DoD Minggu 7) | ✅ | WatchFormScreen: 8 field, 4 jenis input, semua tervalidasi, SnackBar, data tampil di daftar |
| 5 | Tabel uji form minimal 5 kasus sudah dibuat dan hasilnya sesuai harapan | ✅ | 10 test cases di worksheet Minggu 7 |
| 6 | Proposal ringkas lengkap: masalah, persona, user story, kebutuhan, user flow, sitemap, wireframe, tech stack, rancangan database | ✅ | PROPOSAL_UTS_CHRONOSTORE.md |
| 7 | Video maksimal 10 menit, demo dari aplikasi yang berjalan, tautan dapat diakses dosen | ⚠️ | Belum direkam |
| 8 | Semua tautan (video, Figma, GitHub) sudah diuji dari jendela penyamaran | ⚠️ | Belum diuji |

---

## Tugas yang Masih Perlu Dilakukan Sebelum Deadline (5 November 2026)

### Prioritas 1 — Wajib sebelum rekam video:

- [ ] **Push ke GitHub** — buat repo di github.com (jika belum), lalu:
  ```bash
  cd C:\dev\jam_tangan
  git remote add origin https://github.com/shafahelga/jam_tangan.git
  git push -u origin main
  ```

- [ ] **Ambil screenshot** — jalankan `flutter run -d chrome`, screenshot:
  - Halaman Login
  - Dashboard admin
  - Daftar jam tangan
  - Form tambah jam dengan validasi error
  - Simpan sebagai `docs/screenshot-beranda.png` (minimal 1)

- [ ] **Update README** — pastikan ada screenshot, tautan Figma, cara menjalankan

### Prioritas 2 — Sebelum mengumpulkan:

- [ ] **Rekam video** — ikuti timeline di atas, maksimal 10 menit
  - Gunakan OBS Studio atau screen recorder bawaan
  - Jalankan aplikasi di Chrome (fullscreen)
  - Narasi jelas, tampilan kode/layar terbaca
  - Sebutkan nama, NIM, kelas, judul di awal

- [ ] **Upload video** — ke YouTube (unlisted) atau Google Drive, pastikan link bisa dibuka

- [ ] **Uji semua tautan** dari jendela penyamaran:
  - Link video
  - Link Figma
  - Link GitHub

### Prioritas 3 — Nilai tambah (jika waktu cukup):

- [ ] **Perbaiki Figma** — tambah 2 frame empty/error state, samakan menu web dengan mobile (3 item), lengkapi prototipe klik
- [ ] **Tambah test** — implementasi 9 test cases tambahan di `test/widget_test.dart`
- [ ] **Export proposal ke PDF** — PROPOSAL_UTS_CHRONOSTORE.md → PDF untuk dikumpulkan di E-Learning

---

## Rubrik Penilaian dan Pemetaan ke Project

| Komponen | Bobot | Indikator | Status Project | Estimasi Skor |
|----------|-------|-----------|----------------|---------------|
| A. Masalah & pengguna | 20 | Problem statement jelas, persona, 5 user story, kebutuhan fungsional | ✅ Lengkap di proposal | 18-20 |
| B. Rancangan | 20 | User flow, sitemap, wireframe, style guide, konsisten dengan demo | ✅ User flow + 11 halaman + Figma wireframe | 17-19 |
| C. Prototype Flutter | 35 | Aplikasi berjalan, 3 halaman terhubung, form 3 kolom 2 jenis input, validator, SnackBar, data tampil, empty state | ✅ 11 halaman, 8 field 4 jenis input, 7 validator, SnackBar, EmptyState | 32-35 |
| D. Rencana teknis | 10 | Tech stack (Flutter/Dart, Firebase, Firestore, Auth, Hosting), collection & field | ✅ Tech stack + 4 collection Firestore + security rules | 9-10 |
| E. Presentasi | 15 | Video runtut 10 menit, 4 pertanyaan terjawab, keputusan dijelaskan, kendala disampaikan | ⚠️ Tergantung eksekusi video | 12-14 |
| **Total** | **100** | | | **88-98** |
