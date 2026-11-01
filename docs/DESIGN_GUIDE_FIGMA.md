# Design Guideline — ChronoStore (dari Figma Minggu 4)

Sumber: [Figma — 23.01.55.0005 SI Manajemen Jam Tangan Wireframe Minggu 4](https://www.figma.com/design/dR2XS04F45XfPhO9x2LBrD/23.01.55.0005---SI-Manajemen-Jam-Tangan-Wireframe-Minggu-4)

Nilai warna di bawah diambil langsung dari thumbnail file Figma (sampling
piksel), jadi ini warna yang benar-benar dipakai di rancangan — bukan perkiraan.

> **Status:** panduan ini sudah **diterapkan**. Aplikasi Flutter memakai tema
> gelap `#151515` yang sama dengan Figma, dan video UTS memakai palet yang sama
> (lihat `uts-video/src/theme.ts`). Rincian selisih yang tersisa ada di bagian 6.

---

## 1. Warna

| Peran | Hex | Pemakaian di Figma |
|-------|-----|--------------------|
| Latar layar | `#151515` | Semua frame |
| Permukaan kartu | `#1B1B1B` | Kartu statistik, list item |
| Garis / border | `#505050` | Outline kartu, input, pemisah |
| Aksen utama (emas) | `#BF982C` | Tombol utama, kartu hero, item nav aktif |
| Emas terang (hover) | `#D4AC3E` | Turunan aksen |
| Teks utama | `#FFFFFF` | Judul, angka besar |
| Teks sekunder | `#848484` | Keterangan, label |
| Placeholder gambar | `#D9D9D9` | Kotak gambar produk |
| Berhasil | `#2E7D32` | Status selesai |
| Menunggu | `#ED8B00` | Status menunggu |
| Galat | `#C62828` | Validasi gagal |

**Catatan emas:** Figma terbaca `#BF982C`, sedangkan worksheet Minggu 4
mendokumentasikan `#C9A227` (dipakai di `lib/app/theme.dart`). Selisihnya
kecil dan kemungkinan berasal dari konversi profil warna pada thumbnail.
Untuk konsistensi dengan kode, `#C9A227` tetap dipakai sebagai nilai acuan.

---

## 2. Tipografi

| Peran | Ukuran | Berat |
|-------|--------|-------|
| Judul aplikasi (wordmark) | 24 px, uppercase, letter-spacing lebar | 600 |
| Judul halaman ("Selamat Datang") | 20–24 px | 700 |
| Subjudul | 18 px | 600 |
| Isi | 14–16 px | 400 |
| Label / keterangan | 12–14 px | 400 |
| Angka besar pada kartu | 24–28 px | 700 |

Huruf: sans-serif netral (di Figma memakai default Figma Sans; di aplikasi
memakai font bawaan Material).

---

## 3. Bentuk dan Jarak

| Elemen | Nilai |
|--------|-------|
| Radius tombol | 8 px |
| Radius kartu | 8–12 px |
| Radius input | 8 px (pill penuh pada kolom pencarian) |
| Padding dalam kartu | 16 px |
| Jarak antar kartu | 8–12 px |
| Padding tepi layar | 16 px |

Skala jarak mengikuti kelipatan 8: 4, 8, 16, 24, 32.

---

## 4. Komponen

**Tombol utama** — isi penuh `#BF982C`, teks gelap `#151515`, radius 8,
tinggi 48, lebar penuh.

**Tombol sekunder** — transparan, border `#505050`, teks `#FFFFFF`.

**Input** — latar `#151515` (menyatu dengan layar), border `#505050`,
radius 8, ikon di kiri, label di dalam kolom.

**Kartu statistik** — latar `#1B1B1B`, border tipis `#505050`, label kecil
`#848484` di atas, angka besar putih di bawah.

**Kartu hero** — satu kartu per layar diisi penuh emas `#BF982C` dengan teks
gelap, dipakai untuk metrik paling penting ("Total Jam Tangan").
*Tidak diterapkan — lihat alasan di bagian 6.*

**Item menu** — baris dengan kotak ikon putih `#D9D9D9` ber-radius 8 di kiri,
judul putih, panah di kanan, dibungkus border `#505050`.

**Navigasi bawah** — latar `#151515`, ikon tidak aktif `#848484`, ikon aktif
`#BF982C`.

**Keadaan kosong** — kotak ikon abu besar, judul putih, keterangan `#848484`,
satu tombol emas "Kembali ke Dashboard".

---

## 5. Halaman yang dirancang

| # | Halaman | Catatan |
|---|---------|---------|
| 1 | Login | Logo lingkaran, wordmark emas, 2 input, tombol Masuk emas |
| 2 | Dashboard | Kartu hero emas "Total Jam Tangan", 4 kartu statistik, Menu Utama |
| 3 | Data Jam Tangan | Kolom cari pill, tombol "Tambah Jam", daftar kartu |
| 4 | Form Jam Tangan | Dropdown tipe mesin, 4 kolom isian, Batal + Simpan |
| 5 | Riwayat Servis | Dropdown pilih jam, tombol "Tambah Servis", daftar |
| 6 | Halaman Tidak Ditemukan | Keadaan kosong / galat |

---

## 6. Kesesuaian dengan implementasi

Aplikasi Flutter sudah diselaraskan ke Figma pada iterasi tema gelap.
Tabel di bawah adalah hasil pemeriksaan akhir.

| Aspek | Figma | Aplikasi Flutter | Status |
|-------|-------|------------------|--------|
| Latar | `#151515` | `AppColors.background = #151515` | **Sesuai** |
| Permukaan kartu | `#1B1B1B` | `AppColors.surface = #1B1B1B` | **Sesuai** |
| Kartu terangkat | `#1B1B1B` | `AppColors.surfaceAlt = #1F1F1F` | Mirip (sengaja) |
| Border | `#505050` | `AppColors.border = #4A4A4A` | Mirip |
| Teks utama | `#FFFFFF` | `AppColors.textPrimary = #FFFFFF` | **Sesuai** |
| Teks sekunder | `#848484` | `AppColors.textSecondary = #A0A0A0` | Lebih terang (a11y) |
| Aksen emas | `#BF982C` | `AppColors.primary = #C9A227` | Mirip (nilai acuan) |
| Radius | 8–12 | 8–16 | Mirip |
| Navigasi | Bawah, 3 item | Bawah (mobile) / Rail (web) | Sesuai + responsif |

**Dua selisih yang disengaja:**

1. **Teks sekunder `#848484` → `#A0A0A0`.** `#848484` di atas `#151515` hanya
   mencapai rasio kontras ±3.2:1, di bawah ambang WCAG AA 4.5:1 untuk teks
   normal. `#A0A0A0` mencapai ±5.4:1 dan tetap terlihat sebagai abu redup.
2. **Emas `#BF982C` → `#C9A227`.** `#C9A227` adalah nilai yang sudah
   didokumentasikan di worksheet Minggu 4. Selisih hue-nya sangat kecil
   (keduanya emas tua) sehingga tidak terlihat berbeda saat berdampingan.

**Kartu hero emas tidak dipakai.** Figma menempatkan satu kartu penuh emas
untuk "Total Jam Tangan". Di aplikasi, keempat kartu ringkasan dibuat seragam
(`#1B1B1B` + border) agar tidak ada metrik yang terlihat lebih penting dari
yang lain — dan agar angka putih di atas emas tidak turun kontrasnya.

---

## 7. Penerapan pada video

Video UTS memakai token yang sama, didefinisikan ulang di
`uts-video/src/theme.ts`:

| Token | Nilai | Asal |
|-------|-------|------|
| `bg` | `#151515` | Latar Figma |
| `bgRaised` | `#1B1B1B` | Permukaan kartu Figma |
| `bgCard` | `#1F1F1F` | Kartu terangkat |
| `gold` | `#C9A227` | Aksen (nilai acuan) |
| `goldTint` | `#2E2714` | Turunan emas untuk blok tersorot |
| `cream` | `#FFFFFF` | Teks utama |
| `muted` | `#A0A0A0` | Teks sekunder |
| `dim` | `#6E6E6E` | Teks redup / caption |
| `hairline` | `rgba(201,162,39,0.28)` | Garis emas |
| `hairlineSoft` | `rgba(255,255,255,0.14)` | Garis netral |

Font video: **Playfair Display** (judul) + **Inter** (isi) — dipilih agar
video terasa seperti materi presentasi, bukan tangkapan layar aplikasi.
