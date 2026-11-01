# Worksheet Minggu 5 — Setup Project Flutter dan Repository GitHub
# ChronoStore

**Nama:** Maheswari Shafa Helga  
**NIM:** 23.01.55.0005  
**Kelas:** A1  
**Nama project Flutter:** jam_tangan  
**Tautan repository GitHub:** https://github.com/shafahelga/jam_tangan  

---

## Penilaian Figma Minggu 4 (dari Dosen)

| Komponen | Skor | Catatan Dosen |
|----------|------|---------------|
| Mobile (30) | 30 | 5 halaman Must bagus |
| Alt — keadaan alternatif (15) | 8 | Belum ada keadaan kosong/galat (acuan punya 2) |
| Style guide (15) | 15 | Bagus |
| Web responsif (20) | 16 | Menu web jauh lebih banyak daripada mobile |
| Prototipe klik (10) | 5 | — |
| Kerapian (10) | 9 | — |
| **Total** | **83** | — |

### Perbaikan yang perlu dilakukan di Figma:
1. **Tambah keadaan kosong/galat** — minimal 2 frame: satu untuk daftar kosong ("Belum ada data jam tangan"), satu untuk form error (input wajib kosong)
2. **Samakan menu web dengan mobile** — web sebaiknya hanya 3 menu utama (Dashboard, Data Jam, Pengingat) sama seperti mobile, bukan lebih banyak
3. **Lengkapi prototipe klik** — pastikan alur inti dari Login sampai selesai bisa diklik

---

## Latihan 1 — Cek Prasyarat

| Alat | Versi / hasil perintah | Siap? |
|------|------------------------|-------|
| Flutter SDK | Flutter 3.47.7 (channel stable) | Ya |
| VS Code + ekstensi Flutter | VS Code dengan ekstensi Flutter & Dart terpasang | Ya |
| Chrome terdeteksi | Terverifikasi via flutter doctor [√] Chrome | Ya |
| Git | git version 2.55.0.windows.3 | Ya |
| Akun GitHub (username) | shafahelga | Ya |

---

## Latihan 2 — Project Pertama

| Butir | Isian / bukti |
|-------|---------------|
| Nama project | jam_tangan |
| Lokasi folder project | C:\dev\jam_tangan |
| Perintah yang dipakai untuk membuat | flutter create jam_tangan |
| Hot reload berhasil? | Ya — tekan r di terminal saat aplikasi berjalan |

---

## Latihan 3 — Kenali Project

| Pertanyaan | Jawaban |
|------------|---------|
| Di file mana nama project dan judul aplikasi ditulis? | lib/main.dart (title: 'ChronoStore') dan pubspec.yaml (name: jam_tangan) |
| Di folder mana kode halaman akan ditulis? | lib/screens/ (login_screen.dart, dashboard_screen.dart, dll) |
| Mengapa folder build/ tidak ikut di-commit? | Karena .gitignore sudah mengecualikan build/ — folder tersebut berisi hasil kompilasi yang bisa dibangun ulang kapan saja |

---

## Latihan 4 — Bukti Repository

| Butir | Isian |
|-------|-------|
| Tautan repository | https://github.com/shafahelga/jam_tangan |
| Pesan commit pertama | "Inisialisasi project Flutter ChronoStore" |
| Folder/file yang tampil di GitHub | lib/ (main.dart, app/, models/, providers/, repositories/, screens/, widgets/, services/, utils/), test/, pubspec.yaml, README.md, web/, android/, ios/, .gitignore |

---

## Latihan 5 — Periksa README

| Butir periksa | Ya/Belum |
|---------------|----------|
| Judul dan deskripsi singkat aplikasi ada | Ya |
| Nama, NIM, kelas | Ya |
| Tautan Figma Minggu 4 ada | Ya |
| Cara menjalankan aplikasi tertulis | Ya |
| Screenshot tampil di halaman repository | Belum — akan diambil saat flutter run di Chrome |

---

## Refleksi Individu

| Pertanyaan | Jawaban |
|------------|---------|
| Kendala teknis apa yang muncul? | flutter doctor menampilkan [X] Android toolchain (Android SDK belum terpasang) dan [X] Visual Studio (desktop Windows). Namun keduanya tidak diperlukan untuk target web (Chrome) di MK ini. Proxy configuration juga muncul sebagai peringatan tetapi tidak menghalangi eksekusi. |
| Butir definition of done mana yang belum terpenuhi? | Screenshot aplikasi yang berjalan belum diambil dan ditambahkan ke README. Repository GitHub sudah dibuat dengan 1 commit; commit kedua (README + screenshot) akan dilakukan setelah screenshot diambil. |
| Halaman Must mana yang akan dibangun pertama di pertemuan 6? | Login dan Dashboard — karena login adalah pintu masuk aplikasi, dan dashboard adalah halaman pertama setelah login yang menampilkan ringkasan stok dan akses ke menu utama. |

---

## Definition of Done Checklist

| Butir | Status |
|-------|--------|
| flutter run berhasil (minimal di Chrome) dan judul/teks beranda sudah sesuai aplikasi | Ya — judul: 'ChronoStore', home: LoginScreen |
| Repository GitHub dapat dibuka dan berisi minimal dua commit dengan pesan yang jelas | Commit pertama: "Inisialisasi project Flutter ChronoStore". Commit kedua: "Tambah README dan screenshot" (akan dilakukan setelah screenshot diambil) |
| README berisi identitas project, deskripsi singkat, tautan Figma, dan cara menjalankan | Ya — sudah ditulis lengkap |
| Screenshot aplikasi yang berjalan tampil di README | Belum — akan diambil saat flutter run di Chrome |

---

## Catatan Modul Praktikum Dart & Flutter

Modul praktikum dasar Dart dan Flutter (36 halaman) telah dibaca. Hal-hal penting yang relevan untuk project ChronoStore:

1. **Dart basics** (Bagian 3-6): variabel, tipe data, kondisi, fungsi — sudah diterapkan di models/ dan services/
2. **Widget tree** (Bagian 8): StatelessWidget, MaterialApp, Scaffold — sudah diterapkan di main.dart dan screens/
3. **Layout** (Bagian 9): Column, Row, Card, Padding — sudah diterapkan di widgets/watch_card.dart dan dashboard_screen.dart
4. **Input & State** (Bagian 10): StatefulWidget, TextEditingController, setState, validation — sudah diterapkan di login_screen.dart dan watch_form_screen.dart
5. **Testing** (Bagian 11): widget test sudah ada di test/widget_test.dart (test halaman login)
