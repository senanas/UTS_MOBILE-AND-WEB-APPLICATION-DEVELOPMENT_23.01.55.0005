# Narasi Video UTS — ChronoStore

**Video utama:** 3 menit 23 detik · 8 scene · **Suara:** id-ID-GadisNeural (edge-tts)
**Tema video:** Masalah, Target Pengguna, dan Scope
**Lampiran:** naskah video rencana teknis (2 menit 46 detik · 5 scene)

Teks di bawah identik dengan yang dibacakan di video, jadi bisa dipakai untuk
latihan atau untuk merekam ulang dengan suara sendiri.

---

## Scene 1 — Pembuka · 18 detik

> ChronoStore. Sistem informasi manajemen toko jam tangan. Proyek individu mata kuliah Mobile and Web Application Development. Saya Maheswari Shafa Helga, kelas A satu.

**Di layar:** judul ChronoStore, subjudul, nama · NIM · kelas.

---

## Scene 2 — Tiga Masalah · 15 detik

> Toko jam tangan menghadapi tiga masalah utama dalam operasional sehari-hari. Ketiganya berakar pada satu hal yang sama: pencatatan yang masih manual dan tersebar di banyak tempat.

**Di layar:** angka besar "03" dan tiga kartu: Stok & Nomor Seri, Spesifikasi Mesin, Servis & Garansi.

---

## Scene 3 — Masalah 1: Stok & Nomor Seri · 25 detik

> Masalah pertama, pencatatan stok dan nomor seri yang masih manual. Setiap jam tangan memiliki nomor seri unik untuk keperluan garansi dan autentikasi. Tanpa sistem terpusat, nomor seri bisa tercatat ganda, jumlah stok tidak akurat, dan pencarian satu unit tertentu memakan waktu lama.

**Di layar:** tabel "Catatan Stok — Buku Manual"; dua baris dengan nomor seri
`SK-SRPD65-001` yang sama menyala merah dan diberi label **DUPLIKAT**; angka stok
berubah-ubah. Muncul tiga chip: Nomor seri ganda · Stok tidak akurat · Pencarian lambat.

---

## Scene 4 — Masalah 2: Spesifikasi · 24 detik

> Masalah kedua, informasi tipe mesin tidak terorganisir. Mesin automatic, quartz, dan solar membutuhkan perawatan yang berbeda. Ketika data spesifikasi tersebar di buku dan catatan lepas, admin sulit menjawab pertanyaan pelanggan dan menentukan jadwal servis yang tepat.

**Di layar:** tiga kartu miring — Automatic, Quartz, Solar — di dalam kotak putus-putus
yang tidak sejajar. Keterangan: "Tersebar di buku, nota, dan ingatan."
Chip: Perawatan berbeda · Sulit menjawab pelanggan · Jadwal servis keliru.

---

## Scene 5 — Masalah 3: Servis & Garansi · 24 detik

> Masalah ketiga, riwayat servis dan pengingat garansi yang tidak terkelola. Garansi memiliki masa berlaku, dan servis berkala harus dijadwalkan. Tanpa pengingat, masa garansi terlewat, pelanggan kehilangan hak servisnya, dan toko kehilangan potensi pendapatan.

**Di layar:** garis waktu Agu 2025 → Feb 2027; penanda **GARANSI BERAKHIR** dan
**SERVIS TERLEWAT** berada sebelum penanda **HARI INI** — area di antaranya diberi
bayangan merah. Chip: Garansi terlewat · Hak servis hilang · Pendapatan hilang.

---

## Scene 6 — Target Pengguna · 33 detik

> Pengguna utama ChronoStore adalah admin atau pemilik toko, seperti Andi, tiga puluh empat tahun, yang setiap hari mengelola puluhan jam tangan dengan nomor seri dan masa garansi yang berbeda-beda. Ia membutuhkan pencarian cepat dan pengingat otomatis. Pengguna sekunder adalah pelanggan, seperti Siti, yang ingin melihat katalog, membandingkan spesifikasi, dan memesan tanpa harus datang ke toko.

**Di layar:** dua kartu persona berdampingan.

| | Pengguna Utama | Pengguna Sekunder |
|---|---|---|
| Nama | Andi, 34 tahun | Siti, 28 tahun |
| Peran | Admin / Pemilik Toko | Pelanggan |
| Kebutuhan | Kelola puluhan unit · pencarian cepat · pengingat garansi | Jelajah katalog · bandingkan spesifikasi · pesan tanpa ke toko |

---

## Scene 7 — Scope (MoSCoW) · 50 detik

> Ruang lingkup ChronoStore disusun dengan metode MoSCoW. Prioritas Must atau wajib: autentikasi, kelola data jam tangan dengan validasi nomor seri unik, riwayat servis, dan katalog untuk pelanggan. Ini fitur inti yang membuat aplikasi berfungsi. Prioritas Should atau sebaiknya: dashboard ringkasan, pengingat garansi, dan transaksi. Nilainya tinggi, tetapi aplikasi tetap berjalan tanpanya. Di luar cakupan UTS: integrasi Firebase, pembayaran online, dan notifikasi WhatsApp. Ketiganya masuk rencana fase implementasi menuju UAS.

**Di layar:** tiga kolom.

| Must (Wajib) | Should (Sebaiknya) | Won't (Di luar UTS) |
|---|---|---|
| Autentikasi pengguna | Dashboard ringkasan | Integrasi Firebase |
| Data jam tangan + validasi nomor seri unik | Pengingat garansi | Pembayaran online |
| Riwayat servis per unit | Transaksi pesanan | Notifikasi WhatsApp |
| Katalog untuk pelanggan | | |

Catatan kaki: *Fitur di luar cakupan UTS direncanakan pada Pertemuan 9–15 menuju UAS.*

---

## Scene 8 — Penutup · 13 detik

> Dari pencatatan manual, menuju satu sistem yang terpusat. ChronoStore. Repository dan detail lengkap tersedia di GitHub.

**Di layar:** tagline, judul ChronoStore, `github.com/senanas/UTS_MOBILE-AND-WEB-APPLICATION-DEVELOPMENT_23.01.55.0005`, "Terima kasih".

---

## Catatan untuk UTS

Video utama ini menjawab **Bagian 2 dan 3** dari Brief UTS (masalah & pengguna,
kebutuhan & prioritas). Untuk **Bagian 6 (rencana teknis)** sudah tersedia
video kedua: `uts-video/out/chronostore-uts-plan.mp4` (2:46) — naskahnya ada di
lampiran bawah.

Kalau ingin menyusun satu video utuh di bawah 10 menit, gabungkan berurutan:

1. `chronostore-uts.mp4` (3:23) — pembuka, masalah, target, scope
2. Rekaman layar `flutter run -d chrome` (±3:30) — demo form & validasi
3. `chronostore-uts-plan.mp4` (2:46) — arsitektur, Firestore, roadmap

Total ±9:39, masih di bawah batas 10 menit.

---

# Lampiran — Narasi Video Rencana (`ChronoStoreUTSPlan`)

**Durasi total:** 2 menit 46 detik · 5 scene.

## Plan 1 — Tech Stack · 25 detik

> Tech stack ChronoStore. Flutter dan Dart untuk antarmuka yang berjalan di mobile maupun web. Provider sebagai pengelola state. Untuk backend, Firebase paket Spark yang gratis: Authentication untuk login, Cloud Firestore untuk basis data, dan Hosting untuk publikasi.

**Di layar:** dua kartu — "Aplikasi" (sudah berjalan) dan "Backend" (rencana Pertemuan 9–15).

## Plan 2 — Rancangan Firestore · 48 detik

> Rancangan basis data Firestore terdiri dari empat collection. Users menyimpan uid, nama, email, dan role. Watches menyimpan nama, merek, model, tipe mesin, harga, stok, nomor seri unik, dan masa garansi. Service records menyimpan watch id, tanggal servis, jenis servis, biaya, dan jadwal berikutnya. Transactions menyimpan watch id, jumlah, harga satuan, total, user id, dan status. Satu watch memiliki banyak service record dan banyak transaksi.

**Di layar:** empat kartu collection sejajar + tiga chip relasi 1—N.

## Plan 3 — Alur Data · 26 detik

> Alurnya berlapis. Layar memanggil Provider, Provider memanggil Repository, dan Repository berbicara ke Firestore. Saat ini Repository masih memakai data simulasi. Pada fase berikutnya hanya lapisan Repository yang diganti, layar dan Provider tidak perlu diubah.

**Di layar:** empat kotak berantai — Layar · Provider (TETAP) → Repository (DIGANTI) → Firestore (BARU), kotak yang berubah diberi latar emas.

## Plan 4 — Rencana Pertemuan 9–15 · 37 detik

> Rencana Pertemuan sembilan sampai lima belas. Sembilan dan sepuluh, menyiapkan Firebase dan memindahkan autentikasi. Sebelas dan dua belas, memindahkan data jam tangan, servis, dan transaksi ke Firestore. Tiga belas, menulis aturan keamanan dan mengoptimalkan query. Empat belas, merapikan tampilan serta menangani keadaan memuat dan galat. Lima belas, publikasi ke Firebase Hosting.

**Di layar:** garis waktu vertikal 9–10 · 11–12 · 13 · 14 · 15.

## Plan 5 — Kendala & Penutup · 31 detik

> Kendala yang saya hadapi: Android SDK belum terpasang, sehingga pengujian dilakukan di Chrome. Nilai Figma Minggu empat delapan puluh tiga, dan sudah saya perbaiki dengan menambahkan keadaan kosong serta menyelaraskan tema aplikasi dengan rancangan. Pelajarannya, menetapkan aturan validasi sejak awal membuat implementasi jauh lebih cepat. Terima kasih.

**Di layar:** kartu Kendala dan Pelajaran, lalu penutup "Terima kasih" + identitas.
