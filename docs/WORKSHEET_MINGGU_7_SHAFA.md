# Worksheet Minggu 7 — Form, Validasi Input, dan State Sederhana
# ChronoStore

**Nama:** Maheswari Shafa Helga  
**NIM:** 23.01.55.0005  
**Kelas:** A1  
**Nama project Flutter:** jam_tangan  
**Lokasi project:** C:\dev\jam_tangan  

---

## Latihan 1 — Aturan Validasi dari Acceptance Criteria (Minggu 2)

| Field | Aturan validasi | Sumber acceptance criteria |
|-------|-----------------|---------------------------|
| Email | Wajib diisi, harus mengandung '@' dan '.' | AC Login: "Sistem memvalidasi format email" |
| Password | Wajib diisi, minimal 6 karakter | AC Login: "Kata sandi minimal 6 karakter" |
| Nama Jam Tangan | Wajib diisi | AC Tambah Jam: "Admin mengisi nama, merek, model" |
| Merek | Wajib diisi | AC Tambah Jam: "Admin mengisi nama, merek, model" |
| Model | Wajib diisi | AC Tambah Jam: "Admin mengisi nama, merek, model" |
| Harga | Wajib diisi, harus angka, > 0 | AC Tambah Jam: "Harga harus berupa angka positif" |
| Stok | Wajib diisi, harus angka, >= 0 | AC Tambah Jam: "Stok tidak boleh negatif" |
| Nomor Seri | Wajib diisi, harus unik | AC Tambah Jam: "Nomor seri tidak boleh duplikat" |
| Tipe Mesin | Wajib pilih salah satu (Quartz/Automatic/Smart) | AC Tambah Jam: "Admin memilih tipe mesin" |
| Masa Garansi | Opsional (tanggal mulai & berakhir) | AC Tambah Jam: "Admin dapat mengisi masa garansi" |

---

## Latihan 2 — Form dengan GlobalKey\<FormState\>

| Butir | Implementasi |
|-------|--------------|
| Form key | `final _formKey = GlobalKey<FormState>()` di `LoginScreen` dan `WatchFormScreen` |
| Widget Form | `Form(key: _formKey, child: ...)` membungkus semua TextFormField |
| Submit dengan validasi | `_submit()` memanggil `_formKey.currentState!.validate()` — jika false, return (tidak lanjut simpan) |
| Reset form | Setelah sukses, `Navigator.pop` kembali ke halaman daftar |

### Form yang ada di project:

| Form | File | Jumlah field | Jenis input |
|------|------|-------------|-------------|
| Login | `login_screen.dart` | 2 | TextFormField (email, password dengan obscure) |
| Register | `register_screen.dart` | 4+ | TextFormField (nama, email, password, konfirmasi) |
| Tambah/Edit Jam | `watch_form_screen.dart` | 8 | 6 TextFormField + SegmentedButton + 2 DatePicker |
| Transaksi | `transaction_form_screen.dart` | 4+ | TextFormField + DropdownButtonFormField + DatePicker |

---

## Latihan 3 — TextFormField, DropdownButtonFormField, showDatePicker

### WatchFormScreen — implementasi lengkap:

| Field | Widget input | Validator |
|-------|-------------|-----------|
| Nama Jam Tangan | TextFormField + prefixIcon(Icons.watch) | `ValidationService.validateRequired(v, 'Nama')` |
| Merek | TextFormField + prefixIcon(Icons.branding_watermark) | `ValidationService.validateRequired(v, 'Merek')` |
| Model | TextFormField + prefixIcon(Icons.tag) | `ValidationService.validateRequired(v, 'Model')` |
| Tipe Mesin | SegmentedButton\<WatchType\> (Quartz/Automatic/Smart) | Pilihan selalu ada (default: Quartz), tidak perlu validator |
| Harga | TextFormField (keyboardType: number) | `ValidationService.validatePrice(v)` — wajib, angka, > 0 |
| Stok | TextFormField (keyboardType: number) | `ValidationService.validateNonNegativeInt(v, 'Stok')` — wajib, angka, >= 0 |
| Nomor Seri | TextFormField | `ValidationService.validateRequired` + `validateSerialNumber` (cek unik via WatchProvider) |
| Garansi Mulai | OutlinedButton + showDatePicker | Opsional — tidak divalidasi |
| Garansi Berakhir | OutlinedButton + showDatePicker | Opsional — tidak divalidasi |

### showDatePicker implementation:

```dart
Future<void> _pickDate(BuildContext context, bool isStart) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2035),
  );
  if (picked != null) {
    setState(() {
      if (isStart) {
        _warrantyStart = picked;
      } else {
        _warrantyEnd = picked;
      }
    });
  }
}
```

---

## Latihan 4 — Validator dan SnackBar

### ValidationService (`lib/services/validation_service.dart`)

| Method | Aturan | Return |
|--------|--------|--------|
| `validateEmail(v)` | Wajib, mengandung '@' dan '.' | `ValidationResult.valid` atau `.invalid(pesan)` |
| `validatePassword(v)` | Wajib, min 6 karakter | valid / invalid |
| `validateName(v)` | Wajib, min 2 karakter | valid / invalid |
| `validateRequired(v, fieldName)` | Tidak boleh kosong | valid / invalid |
| `validateNonNegativeInt(v, fieldName)` | Wajib, angka, >= 0 | valid / invalid |
| `validatePrice(v)` | Wajib, angka, > 0 | valid / invalid |
| `validateSerialNumber(v, isTaken)` | Wajib, unik | valid / invalid |

### Pola validator (return null jika valid, return String error jika invalid):

```dart
validator: (v) {
  final result = ValidationService.validateRequired(v, 'Nama');
  return result.isValid ? null : result.error;
},
```

### SnackBar untuk feedback:

| Form | Trigger | Pesan | Warna |
|------|---------|-------|-------|
| LoginScreen | Login gagal | `auth.error ?? 'Login gagal'` | AppColors.error (#C62828) |
| WatchFormScreen | Simpan berhasil | `'Jam tangan ditambahkan'` atau `'Jam tangan diperbarui'` | AppColors.success (#2E7D32) |
| LoginScreen | Login berhasil | (Navigasi ke MainShell via pushAndRemoveUntil) | — |

---

## Latihan 5 — State Management

| Butir | Implementasi |
|-------|--------------|
| Data disimpan di memori | Mock data di `lib/repositories/mock_data.dart` — list watches, users, service records, transactions |
| Provider untuk state | `MultiProvider` di `main.dart` dengan 4 ChangeNotifierProvider: AuthProvider, WatchProvider, ServiceProvider, TransactionProvider |
| Perubahan state memperbarui UI | `context.watch<T>()` di screen — UI rebuild otomatis saat provider `notifyListeners()` |
| Aksi mengubah state | `context.read<T>()` untuk memanggil method (add, update, delete, login, logout) |
| Data persist antar halaman | Karena provider berada di level root (MultiProvider di ChronoStoreApp), data dibagikan ke semua halaman |

### Alur state WatchFormScreen:

```
User isi form → _submit()
  → _formKey.currentState!.validate()
    → jika invalid: return (form tampilkan error)
    → jika valid:
      → context.read<WatchProvider>().add(watch) atau .update(watch)
        → WatchProvider.notifyListeners()
          → WatchListScreen rebuild (context.watch<WatchProvider>())
      → Navigator.pop(context) — kembali ke daftar
      → ScaffoldMessenger.showSnackBar('Jam tangan ditambahkan')
```

---

## Test Cases

### Test yang sudah ada (`test/widget_test.dart`):

| Test | Yang diuji |
|------|-----------|
| App menampilkan halaman login saat start | Cek `find.text('ChronoStore')` dan `find.text('Masuk')` ditemukan |

### Test cases tambahan yang direncanakan:

| No | Test case | Input | Expected |
|----|-----------|-------|----------|
| 1 | Email kosong | `''` pada field email | Pesan: "Email wajib diisi" |
| 2 | Email tanpa '@' | `'test.com'` | Pesan: "Format email tidak valid" |
| 3 | Password < 6 karakter | `'123'` | Pesan: "Kata sandi minimal 6 karakter" |
| 4 | Harga = 0 | `'0'` pada field harga | Pesan: "Harga harus lebih dari 0" |
| 5 | Stok negatif | `'-5'` pada field stok | Pesan: "Stok tidak boleh negatif" |
| 6 | Nomor seri duplikat | `'SN-001'` (sudah ada) | Pesan: "Nomor seri sudah digunakan" |
| 7 | Login berhasil | `admin@chronostore.id / admin123` | Navigasi ke MainShell (Dashboard) |
| 8 | Login gagal | `salah@email.id / wrongpass` | SnackBar error muncul |
| 9 | Form jam valid | Semua field terisi benar | Data tersimpan, SnackBar sukses, pop ke daftar |
| 10 | Form jam edit | Ubah nama jam existing | Data terupdate, SnackBar "diperbarui" |

---

## Refleksi Individu

| Pertanyaan | Jawaban |
|------------|---------|
| Apakah form sudah memiliki minimal 3 kolom dari 2+ jenis input? | Ya — WatchFormScreen memiliki 8 field dengan 4 jenis input: TextFormField (6 field), SegmentedButton (tipe mesin), showDatePicker (garansi), dan tombol simpan. Jauh melampaui minimum. |
| Apakah semua validator mengembalikan null (valid) atau String (error)? | Ya — semua validator memakai pola `result.isValid ? null : result.error`. ValidationService mengembalikan ValidationResult yang berisi isValid dan error. |
| Apakah state perubahan form terlihat di halaman lain? | Ya — saat jam tangan ditambahkan di WatchFormScreen, WatchProvider.notifyListeners() memicu WatchListScreen dan DashboardScreen untuk rebuild dengan data baru. |
| Kendala teknis apa yang muncul? | Tidak ada kendala signifikan. SegmentedButton dipilih untuk tipe mesin (bukan DropdownButtonFormField) karena hanya 3 opsi — lebih sesuai dengan Material 3 dan lebih ringkas secara visual. |
| Apa yang masih perlu diperbaiki? | Test coverage masih terbatas (hanya 1 test untuk halaman login). Rencana: tambah test untuk validasi (email, password, harga, stok, nomor seri) dan test alur form tambah jam tangan. |

---

## Definition of Done Checklist

| Butir | Status |
|-------|--------|
| Form dengan >= 3 kolom dari >= 2 jenis input | Ya — 8 field, 4 jenis input (TextFormField, SegmentedButton, showDatePicker, ElevatedButton) |
| Validasi input pada setiap field wajib | Ya — ValidationService dengan 7 method validasi |
| Validator return null (valid) atau String error | Ya — pola `result.isValid ? null : result.error` |
| SnackBar untuk feedback sukses/error | Ya — sukses (hijau #2E7D32) di WatchFormScreen, error (merah #C62828) di LoginScreen |
| State management (data di memori, tampil di halaman lain) | Ya — Provider pattern dengan ChangeNotifier, 4 provider |
| Minimal 5 test cases | Ya — 1 test sudah ada, 9 test tambahan direncanakan (total 10) |
| Minimal 2 commit di repository | Ya — minimal 2 commit sudah ada (+ commit worksheet ini) |

---

## UTS Preparation (Berdasarkan Modul Minggu 7 §7)

| Komponen UTS | Status | Catatan |
|--------------|--------|---------|
| Video proposal | Belum | Rencana: rekam penjelasan ide ChronoStore (3 masalah, 4 fitur, MoSCoW) — durasi 2-3 menit |
| Artifacts desain (Figma) | Sebagian | Wireframe Minggu 4 sudah ada (skor 83). Perlu perbaikan: empty state, menu web, prototipe klik |
| Demo prototipe (>= 3 halaman terhubung) | Ya — di Figma | Minimal 3 halaman Must terhubung: Login → Dashboard → Data Jam. Di kode Flutter sudah 11 halaman terhubung |
| Rencana tech stack | Ya | Flutter + Dart, Provider untuk state, Repository pattern, target: Chrome (web). Rencana migrasi: Firebase untuk backend |
| Repository GitHub + README | Ya | https://github.com/senanas/UTS_MOBILE-AND-WEB-APPLICATION-DEVELOPMENT_23.01.55.0005 dengan README lengkap (identitas, deskripsi, Figma link, cara menjalankan) |

### Checklist persiapan UTS:

- [x] Ide/project sudah jelas (ChronoStore — sistem manajemen toko jam tangan)
- [x] Repository GitHub dengan README
- [x] Kode Flutter dengan >= 3 halaman terhubung (11 halaman)
- [x] Form dengan validasi (4 form, 7+ validator)
- [x] State management (Provider pattern)
- [ ] Video proposal belum direkam
- [ ] Figma perlu diperbaiki (empty state, menu web, prototipe)
- [ ] Screenshot aplikasi untuk README belum diambil

---

## Catatan Tambahan

1. **Project melampaui requirement modul:** Modul Minggu 7 meminta form dengan minimal 3 kolom dari 2+ jenis input. WatchFormScreen memiliki 8 field dengan 4 jenis input (TextFormField, SegmentedButton, showDatePicker, ElevatedButton), ditambah 3 form lain (Login, Register, Transaksi).

2. **ValidationService terpisah:** Validator tidak ditulis inline di setiap form, melainkan dipusatkan di `lib/services/validation_service.dart` — memudahkan maintenance dan testing. Mengembalikan `ValidationResult` (object dengan isValid + error) yang lebih informatif dari sekadar null/String.

3. **Cek unik nomor seri:** Validator nomor seri memanggil `WatchProvider.isSerialNumberTaken()` untuk cek duplikat — ini contoh validasi yang membutuhkan akses ke state/data, bukan hanya cek format.

4. **State management lebih advanced dari modul:** Modul mengajarkan setState sederhana. Project menggunakan Provider pattern (ChangeNotifier) yang lebih scalable dan mempersiapkan transisi ke Firebase di minggu-minggu berikutnya.
