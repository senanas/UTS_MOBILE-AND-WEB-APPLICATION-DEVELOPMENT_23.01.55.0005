# Panduan Minggu 10 — Cloud Firestore (ChronoStore)

> **Status pengerjaan:** seluruh kode sudah diterapkan ke `C:\dev\jam_tangan` dan lolos
> `flutter analyze`, `flutter test` (19/19), serta `flutter build web`.
>
> **Yang masih harus kamu kerjakan sendiri** (butuh akun Firebase & browser kamu):
> **Bagian 1** (aktifkan Firestore + publish Rules di Console), **Bagian 5** (uji 5 kasus di Chrome),
> **Bagian 6** (screenshot 3 collection), dan **Bagian 8** (2 commit + push).
>
> Modul: `modul-minggu-10-firestore.docx` · Slide: `materi-ajar-minggu-10-firestore.pptx`
> Video praktikum: https://youtu.be/ibqVFb5ytyY

---

## 0. Peta konsep: contoh RoomBook → project kamu

Modul memakai aplikasi **RoomBook** (reservasi ruangan). Tugasnya **proyek individu**,
jadi entitas ERD dipetakan ke **ChronoStore**. Tiga collection wajib:

| Modul (RoomBook) | ChronoStore | Doc ID | Isi field utama |
|---|---|---|---|
| `users` | `users` | `uid` dari Firebase Auth | `id_pengguna`, `nama_lengkap`, `email`, `nomor_telepon`, `peran` (`admin`/`pelanggan`), `dibuat_pada` (Timestamp) |
| `rooms` | `watches` | kode jam (`w_1` …) | `id_jam`, `nama_jam`, `merek`, `model`, `jenis_mesin`, `harga` (int), `stok` (int), `nomor_seri`, `gambar_url`, `garansi_mulai`, `garansi_akhir`, `dibuat_pada` |
| `reservations` | `transactions` | auto-ID | `id_transaksi`, `id_pengguna`, `id_jam`, **`nama_jam`**, `nama_pelanggan`, `email_pelanggan`, `telepon_pelanggan`, `alamat_pengiriman`, `kota`, `kode_pos`, `catatan`, `jumlah`, `harga_satuan`, `ongkir`, `total_harga`, `tanggal`, `status`, `dibuat_pada` (Timestamp) |

**Kenapa `nama_jam` ikut disimpan di `transactions`?** Firestore tidak punya `JOIN`.
Kalau hanya menyimpan `id_jam`, halaman daftar transaksi harus membaca dokumen
`watches` satu per satu. Menyalin field yang sering ditampilkan disebut
**denormalisasi terkontrol** — ini yang ditanyakan pada soal refleksi modul.

**Padanan aturan bisnis "cegah jadwal bentrok":** RoomBook menolak
`ruang + tanggal + jam` yang sama. ChronoStore menolak
**`pengguna + jam tangan + tanggal` yang sama** (pesanan ganda), dan juga menolak
pesanan saat **stok tidak mencukupi**. Keduanya dijalankan sebelum dokumen ditulis.

**Catatan lingkup:** `service_records` (riwayat servis) **masih di memori** minggu ini.
Modul meminta tepat 3 collection, jadi fitur itu menyusul di Minggu 11.

---

## 1. LATIHAN 1 — Aktifkan Firestore & Security Rules (Console)

1. Buka https://console.firebase.google.com → pilih project **`jam-tangan-490e3`**
   (sama dengan Minggu 9, jangan buat project baru).
2. Menu kiri **Build → Firestore Database → Create database**.
3. Biarkan edisi **Standard**, paket **Spark** (gratis, tanpa billing account).
   Pilih lokasi terdekat, mis. `asia-southeast2 (Jakarta)`.
4. Pilih **Start in production mode** → **Create**.
5. Setelah database aktif, buka tab **Rules**, ganti seluruh isinya dengan:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

6. Klik **Publish**. Tunggu sampai status berubah (biasanya beberapa detik).

> ⚠️ Jangan biarkan `allow read, write: if true;` (Test Mode) aktif terus-menerus —
> siapa pun di internet bisa membaca/menghapus data tanpa login.

**Paket sudah terpasang** (tidak perlu diulang):

```bat
flutter pub add cloud_firestore:7.1.0
```

`pubspec.yaml` sekarang berisi `cloud_firestore: 7.1.0`, dan `firebase_core_web`
menyuntikkan `firebase-firestore-pipelines.js` otomatis — **jangan menambah script
apa pun ke `web/index.html`**.

---

## 2. Ringkasan perubahan kode (sudah diterapkan)

| File | Isi perubahan |
|---|---|
| `lib/data/data_chronostore.dart` | **Baru.** 6 jam awal untuk auto-seed + helper format tanggal. |
| `lib/services/layanan_chronostore.dart` | **Baru.** Kontrak `LayananChronoStore` + `TransaksiBentrokException`, `StokTidakCukupException`. |
| `lib/services/layanan_firestore.dart` | **Baru.** Implementasi asli: `users`/`watches`/`transactions`, WriteBatch auto-seed, cek bentrok, `runTransaction` (tulis transaksi + kurangi stok atomik), `snapshots()`, urut di Dart. |
| `lib/services/layanan_memori.dart` | **Baru.** Implementasi in-memory untuk test, tanpa Firebase. |
| `lib/models/transaction.dart` | Tambah `createdAt` (dari `dibuat_pada`) untuk pengurutan terbaru. |
| `lib/repositories/auth_repository.dart` | Peran kini dibaca dari `users/{uid}` (menggantikan SharedPreferences Minggu 9 sebagai sumber utama). |
| `lib/providers/auth_provider.dart` | Terima injeksi layanan; peran langsung benar setelah daftar/masuk. |
| `lib/providers/watch_provider.dart` | Langganan `streamDaftarJam()`; getter lama tetap sinkron, `add/update/delete` jadi async ke Firestore. |
| `lib/providers/transaction_provider.dart` | Langganan `streamSemuaTransaksi()`; `create()` jadi `Future` ke Firestore. |
| `lib/main.dart` | `Provider<LayananChronoStore>` di paling atas `MultiProvider`, diteruskan ke semua provider. |
| `lib/screens/main_shell.dart` | Memanggil `isiJamAwalJikaKosong()` sekali saat halaman utama dibuka. |
| `lib/screens/dashboard_screen.dart` | Sapaan nama dari `StreamBuilder` dokumen `users/{uid}`. |
| `lib/screens/transaction_screen.dart` | `StreamBuilder` dengan 3 keadaan (waiting / error / data), filter per user. |
| `lib/screens/transaction_form_screen.dart` | `await` + SnackBar penolakan + tombol nonaktif saat menyimpan. |
| `lib/screens/watch_form_screen.dart`, `watch_list_screen.dart` | Tulis async ke Firestore, indikator loading & pesan error Rules. |
| `test/layanan_memori_test.dart` | **Baru.** 8 unit test: seed, profil admin, simpan + stok, tolak bentrok, isolasi akun, stok habis, ubah status, real-time. |

`lib/repositories/mock_data.dart`, `watch_repository.dart`, `transaction_repository.dart`
dan `service_repository.dart` **sengaja dibiarkan** sebagai sumber data awal &
cadangan; kode UI tidak lagi memanggilnya secara langsung.

---

## 3. Menjalankan dari CMD (Windows)

```bat
cd /d C:\dev\jam_tangan
flutter pub get
flutter analyze
flutter run -d chrome
```

Wajib `-d chrome` (konfigurasi `firebase_options.dart` baru untuk web).
Saat aplikasi jalan: `r` = hot reload, `R` = hot restart, `q` = berhenti.

Unit test (matikan proxy dulu agar `flutter_tester` tidak gagal koneksi):

```bat
set HTTP_PROXY=
set HTTPS_PROXY=
set http_proxy=
set https_proxy=
flutter test --no-pub
```

Kalau `'flutter' is not recognized`:
`set PATH=C:\dev\flutter\bin;%PATH%`

Port bentrok: `flutter run -d chrome --web-port=5000`.

---

## 4. Alur data yang sekarang berjalan

```
Daftar / Masuk (Firebase Auth, Minggu 9)
        │  uid
        ▼
users/{uid}  ── dibuat sekali, menyimpan nama_lengkap + peran
        │
        ├──► Dashboard: StreamBuilder → "Selamat datang, <nama_lengkap>"
        │
MainShell dibuka
        ▼
watches/  ── WriteBatch auto-seed 6 jam (hanya kalau collection kosong)
        │
        ├──► Katalog, Detail, Dropdown: streamDaftarJam()
        ▼
Form **Checkout** → tambahTransaksi()
        │  0. Validasi form: nama, email, telepon, alamat, kota, kode pos
        │  1. where('tanggal') → cek pesanan ganda
        │  2. runTransaction: cek stok → set(transactions) → update stok
        │     field tersimpan: data pemesan + alamat + ongkir + total_harga
        ▼
transactions/ ── StreamBuilder "Transaksi Saya" (filter id_pengguna == uid)
                Detail transaksi menampilkan nama, email, telepon, alamat,
                ongkir, catatan, dan total pembayaran
```

### Halaman Checkout

Halaman checkout (`TransactionFormScreen`) menampilkan:

- **Ringkasan produk** — nama jam, merek/model, harga satuan, stok.
- **Data Pemesan** — nama lengkap & email diisi otomatis dari akun Firebase Auth,
  nomor telepon wajib diisi.
- **Alamat Pengiriman** — alamat lengkap, kota, kode pos, dan catatan opsional.
- **Jumlah** — tombol +/- dibatasi stok yang tersedia.
- **Metode Pengiriman** — Reguler (Rp 15.000), Ekspres (Rp 30.000), atau
  Ambil di toko (Gratis).
- **Rincian harga** — subtotal (harga × jumlah) + ongkir = **Total Pembayaran**.

`total_harga` yang disimpan di Firestore sudah termasuk ongkir. Semua field
checkout bersifat opsional di model (`Transaction`) supaya transaksi lama yang
belum punya field tersebut tetap terbaca — field kosong otomatis ditampilkan
sebagai string kosong.

### Riwayat Transaksi & Cadangan Lokal

Halaman **Riwayat Transaksi** (`RiwayatTransaksiScreen`) bisa dibuka dari:

- tab **Riwayat** di navigasi bawah / rail,
- tombol ikon jam di AppBar checkout, atau
- tombol **Lihat Riwayat Transaksi** di bawah form checkout.

Setelah checkout berhasil, aplikasi otomatis membuka halaman **Transaksi
Berhasil** (`CheckoutSuccessScreen`) — terpisah dari halaman riwayat. Halaman
ini menampilkan centang hijau besar, nomor pesanan, tanggal, detail produk,
data pemesan & alamat, rincian pembayaran (subtotal + ongkir = total), status
"Pesanan Diterima", serta dua tombol: **Lihat Riwayat Transaksi** dan
**Belanja Lagi** (kembali ke halaman utama).

**Cadangan lokal:** bila Firestore menolak tulis (`permission-denied` karena
Rules belum di-Publish, atau `unavailable` saat offline), pesanan **tetap
dianggap berhasil** dan disimpan ke `SharedPreferences` lewat
`TransaksiLokal`. Pesanan ini ditandai "Tersimpan di perangkat" di riwayat.
Begitu Rules benar dan aplikasi dijalankan ulang, pesanan berikutnya kembali
masuk ke Cloud Firestore. Ini membuat checkout tidak pernah gagal total
walau konfigurasi Console belum selesai.

Semua query hanya memakai **satu `.where()`** dan **tanpa `.orderBy()`**;
pengurutan terbaru memakai `list.sort(...)` di Dart. Ini sengaja untuk menghindari
error `failed-precondition ... requires an index` (lihat slide 14 & modul bab 7).

Satu detail penting: provider dibuat sejak `main()` dijalankan, padahal Rules
`request.auth != null` menolak akses sebelum login. Karena itu ketiga stream
dibungkus `_auth.authStateChanges().asyncExpand(...)` — saat belum login yang
dikirim adalah list kosong, dan begitu status login berubah langganan lama
dibatalkan lalu diganti langganan Firestore yang baru. Tanpa ini, daftar jam
akan kosong selamanya karena stream sempat error `permission-denied` di halaman
Login.

### Tampilan website (perbaikan terakhir)

Tampilan kini lebih lengkap dan konsisten di layar kecil maupun lebar:

- **Dashboard:** hero banner emas, kartu ringkasan untuk admin, dan etalase
  produk pelanggan dengan tombol **Beli** langsung.
- **Katalog / Data Jam:** grid produk responsif (1–4 kolom) memakai
  `ProductThumbnail` — gambar jaringan bila ada, ilustrasi jam + badge stok
  bila tidak ada. Tersedia pencarian, filter tipe, dan toggle aksi admin
  (edit/hapus) vs pelanggan (**Beli Sekarang** / **Lihat Detail**).
- **Checkout:** kartu produk bergambar, grup form berikon (nama, email,
  telepon, alamat, kota, kode pos, catatan), pemilih jumlah, metode pengiriman,
  dan rincian subtotal + ongkir + total. Jika Rules belum dipublish, pesanan
  tetap berhasil lewat cadangan lokal.
- **Riwayat:** kartu ringkasan (jumlah transaksi + nilai pesanan) dan tiap
  transaksi bisa dikembangkan untuk melihat detail checkout lengkap.
- **Transaksi Berhasil:** konfirmasi dengan aksen emas, nomor pesanan, serta
  blok total pembayaran yang menonjol.

Verifikasi terakhir: `flutter analyze` → *No issues found*, `flutter test
--no-pub` → **19 tests passed**, `flutter build web --no-pub` → *Built
build\web*.

---

## 5. LATIHAN 4 — Tabel uji (minimal 5 kasus)

Isi kolom **Hasil nyata** setelah benar-benar uji di Chrome. Tabel siap salin
juga ada di `README.md`.

| # | Kasus uji | Langkah | Hasil yang diharapkan | Hasil nyata |
|---|---|---|---|---|
| 1 | Tambah data valid | Login akun simulasi → buka jam → **Pesan** → isi jumlah → **Buat Pesanan** | Dokumen baru muncul di `transactions` & halaman Transaksi Saya; stok jam berkurang | |
| 2 | Tolak pesanan ganda | Ulangi pesanan **jam yang sama, akun yang sama, hari yang sama** | SnackBar "sudah Anda pesan hari ini"; jumlah dokumen tidak bertambah; form tetap terbuka | |
| 3 | Bertahan saat refresh | Tekan **F5** di Chrome | Sapaan nama, daftar jam, dan transaksi tetap tampil (data dari cloud, bukan memori) | |
| 4 | Isolasi antar akun | **Keluar** → daftar/masuk akun simulasi kedua | Transaksi akun pertama tidak muncul di akun kedua | |
| 5 | Security Rules | Di Console, ganti Rules jadi `allow read, write: if false;` → Publish → refresh (atau cek tanpa login) | Firestore mengembalikan `permission-denied`; halaman menampilkan pesan "Gagal memuat data" | |

**Kembalikan Rules ke `request.auth != null` dan Publish lagi setelah kasus 5!**

Kasus tambahan yang bagus untuk nilai lebih: daftar sebagai **Admin**, lalu cek
kanan atas terbaca `... (Admin)` dan dokumen `users/{uid}` berisi `peran: "admin"`.
Ini sekaligus menjawab pertanyaanmu minggu lalu — peran sekarang tersimpan di cloud,
jadi tidak hilang saat pindah browser.

---

## 6. Screenshot yang dikumpulkan

Simpan di folder `docs/` dengan nama ini, lalu tambahkan ke README:

| Nama file | Isi layar Console |
|---|---|
| `docs/screenshot-firestore-users.png` | Firestore Database → collection `users`, dokumen `uid` terbuka (tampak `nama_lengkap`, `peran`) |
| `docs/screenshot-firestore-watches.png` | Daftar dokumen `watches` (6 dokumen hasil auto-seed) |
| `docs/screenshot-firestore-transactions.png` | Daftar dokumen `transactions` + satu dokumen dibuka (tampak `nama_jam`, `dibuat_pada`) |

Usahakan **nama project `jam-tangan-490e3` terlihat** di pojok kiri atas Console.

Video praktikum: https://youtu.be/ibqVFb5ytyY

---

## 7. Refleksi individu (contoh jawaban, silakan disesuaikan)

| Pertanyaan | Jawaban |
|---|---|
| Field apa yang Anda denormalisasi dan mengapa? | `nama_jam` pada collection `transactions`. Firestore tidak mendukung JOIN, jadi tanpa field ini halaman Transaksi Saya harus membaca `watches/{id_jam}` untuk setiap baris. Dengan menyalin nama, daftar selesai dalam satu kali baca. Risikonya: kalau nama jam diubah, data lama tidak ikut berubah — saya terima karena nama produk jarang diedit dan Minggu 11 akan dibahas konsistensinya. |
| Kendala saat menghubungkan Firestore & solusinya? | Awalnya `permission-denied` karena database dibuat dalam production mode dan Rules belum dipublish; diperbaiki dengan `allow read, write: if request.auth != null;` lalu **Publish**. Selain itu `flutter test` sempat gagal `Invalid WebSocket upgrade request` karena variabel proxy terminal; diatasi dengan mengosongkan `HTTP_PROXY`/`HTTPS_PROXY` sebelum `flutter test`. Terakhir, nama kelas `Transaction` bentrok dengan `cloud_firestore.Transaction`, diatasi dengan `import ... hide Transaction;`. |
| Fitur edit & hapus apa yang akan ditambahkan Minggu 11? | Edit transaksi (ubah jumlah/status), batalkan pesanan dengan dialog konfirmasi, dan hapus dokumen `watches`/`service_records`. Operasi dipetakan ke RESTful: `GET` = `.snapshots()`, `POST` = `.add()/.set()`, `PUT` = `.update()`, `DELETE` = `.delete()`. |

---

## 8. Commit ≥ 2 dan push (JALUR CMD — yang disarankan)

Repository kamu saat ini **bercabang**: GitHub `main` punya commit
`8f4261b Update README.md` (dibuat lewat web), sedangkan laptop punya
`e3fca83 Hubungkan project ke Firebase` yang belum ter-push, ditambah semua
perubahan Minggu 9 & 10 yang belum di-commit. Jadi `git push` biasa akan ditolak.

Jalankan setelah tabel uji dan screenshot selesai:

```bat
cd /d C:\dev\jam_tangan

git add -A
git commit -m "Setup Cloud Firestore, Security Rules, dan model 3 collection"

git pull --rebase origin main
git push -u origin main
```

`git pull --rebase` menaruh commit kamu **di atas** commit GitHub; `-u origin main`
mengaitkan branch sehingga push berikutnya cukup `git push`.

Kalau ingin benar-benar **2 commit baru** sesuai luaran modul, pisahkan dulu:

```bat
git add pubspec.yaml pubspec.lock lib/data lib/services lib/models
git commit -m "Setup Cloud Firestore, Security Rules, dan model 3 collection"

git add lib README.md docs test
git commit -m "Simpan profil & transaksi ke Firestore, StreamBuilder, dan tabel uji"

git pull --rebase origin main
git push -u origin main
```

> **Jangan** meng-commit lewat website GitHub untuk batch yang sama. Tombol
> "Commit changes" langsung menyimpan di server, sehingga laptop jadi tertinggal
> dan push berikutnya ditolak.
>
> Perubahan README di GitHub (baris **Tautan Youtube**) dan README di laptop
> berada di bagian berbeda, jadi aman disatukan. Kalau rebase tetap konflik,
> pertahankan **kedua** baris tautan video.

Kalau `git push` minta login: GitHub sudah tidak menerima password akun — biarkan
Git Credential Manager membuka browser, atau pakai Personal Access Token.

---

## 9. Masalah umum

| Gejala / pesan | Penyebab | Solusi |
|---|---|---|
| Tombol **Buat Pesanan** terasa tidak bisa diklik | Field wajib (telepon/alamat/kota/kode pos) masih kosong sehingga `validate()` gagal tapi error-nya di atas layar; atau `_isSaving` macet saat Firestore menggantung | Sekarang muncul SnackBar + halaman otomatis gulir ke field pertama yang error. Status tombol selalu dikembalikan aktif, dan ada timeout 20 detik lalu fallback ke simpanan lokal. |
| Saat checkout muncul `"Gagal menyimpan. Periksa Rules & koneksi Firestore."` (pesan lama, generik) | Pesan lama menyembunyikan kode error asli | Sekarang SnackBar menampilkan kode asli (mis. `permission-denied`, `failed-precondition`) + saran. Baca pesan baru, lalu lihat baris yang sesuai di bawah. Cek juga console Chrome (F12) untuk log `Gagal menyimpan transaksi: ...`. |
| `[cloud_firestore/permission-denied]` | Rules masih `false` / belum dipublish / belum login | Pakai `allow read, write: if request.auth != null;` lalu **Publish** |
| `failed-precondition ... requires an index` | `.where()` digabung `.orderBy()` pada field berbeda | Hapus `.orderBy()`; urutkan dengan `.sort()` di Dart (sudah diterapkan) |
| Loading berputar terus | Database Firestore belum dibuat / koneksi putus | Build → Firestore Database di Console, cek status aktif |
| Daftar jam kosong padahal collection sudah terisi | Stream sempat `permission-denied` sebelum login | Sudah diatasi dengan `asyncExpand` pada `authStateChanges()`; lakukan **hot restart `R`** setelah publish Rules |
| `Widget test gagal karena Firebase` | Test memanggil `FirebaseFirestore.instance` | Injeksi `LayananMemori()` (sudah dipakai di `test/layanan_memori_test.dart`) |
| Sapaan masih nama lama | `users/{uid}` belum terbentuk karena akun dibuat sebelum Minggu 10 | Keluar lalu masuk kembali; `simpanProfilSaatLogin` akan membuat dokumennya |
| Tetap tampil `(Pelanggan)` walau daftar sebagai Admin — terutama `admin@chronostore.com` | Akun lama punya dokumen `users/{uid}` dengan `peran: pelanggan` dan cache lokal ikut `pelanggan`, sehingga syarat perbaikan lama (cache admin) tidak pernah terpenuhi | Sekarang `AppConstants.emailAdmin` memaksa email itu jadi **Admin** setiap login; dokumen Firestore diperbaiki otomatis (self-heal), cache disinkronkan, dan perbaikan tetap terjadi walau Rules belum dipublish. Email lain mengikuti pilihan saat daftar / nilai Firestore. |
| `operation-not-allowed` saat daftar/masuk | Penyedia Email/Password belum aktif | Authentication → Sign-in method → aktifkan Email/Password (Minggu 9) |
| `flutter test`: `Invalid WebSocket upgrade request` | Variabel proxy mengganggu `flutter_tester` | `set HTTP_PROXY=` dst., lalu `flutter test --no-pub` |
| `flutter run -d windows` / Android error | `firebase_options.dart` baru berisi konfigurasi web | Minggu ini target **Chrome** saja |

---

## 10. Batas Minggu 10 & persiapan Minggu 11

**Boleh / fokus:** paket Spark, target Chrome, Rules `request.auth != null`,
operasi **Create** (tambah profil, seed jam, tambah transaksi) dan **Read**
(StreamBuilder real-time), tabel uji ≥ 5 kasus, screenshot 3 collection, ≥ 2 commit.

**Dihindari:** billing account, Test Mode dibiarkan terbuka, dan pengembangan
fitur Update/Delete baru. Tombol edit/hapus yang **sudah ada sejak Minggu 7**
tetap berfungsi (kini menulis ke Firestore), tetapi dialog konfirmasi,
pemetaan RESTful, dan konsistensi data dibahas pekan depan.

**Minggu 11:** CRUD penuh (Edit & Hapus), dialog konfirmasi, pemetaan
`GET / POST / PUT / DELETE`, dan memindahkan `service_records` ke Firestore.
