# ChronoStore — Video UTS

Video presentasi UTS untuk project **ChronoStore**, dibuat sepenuhnya dengan kode:
**Remotion** (React) untuk visual, **edge-tts** untuk narasi (gratis, tanpa API key).

Ada **dua komposisi** di repositori ini:

| Komposisi | Berkas hasil | Durasi | Isi |
|-----------|--------------|--------|-----|
| `ChronoStoreUTS` | `out/chronostore-uts.mp4` | 3 m 23 s | **Masalah, target pengguna, scope** — video utama sesuai Brief UTS |
| `ChronoStoreUTSPlan` | `out/chronostore-uts-plan.mp4` | 2 m 46 s | Tech stack, rancangan Firestore, alur data, rencana Pertemuan 9–15 |

Keduanya 1920×1080 · 30 fps · MP4 (H.264). Palet warna mengikuti
[design guideline Figma Minggu 4](../docs/DESIGN_GUIDE_FIGMA.md).

---

## Hasil

| Berkas | Keterangan |
|--------|------------|
| `out/chronostore-uts.mp4` | Video utama — masalah, target, scope |
| `out/chronostore-uts-plan.mp4` | Video pendukung — rencana teknis |
| `out/preview-scene*.png` | Still per scene video utama |
| `out/preview-plan*.png` | Still per scene video rencana |

> Berkas MP4 tidak masuk Git (lihat `.gitignore`) karena ukurannya besar.
> Hasil akhir diunggah ke YouTube / Google Drive sesuai instruksi Brief UTS.

---

## Struktur

```
uts-video/
├── scripts/
│   ├── script.json           # narasi video utama (8 scene)
│   ├── script-plan.json      # narasi video rencana (5 scene)
│   └── generate-tts.py       # edge-tts → MP3 + manifest durasi
├── public/audio/             # 13 MP3 narasi + berkas timing
├── src/
│   ├── index.ts              # registerRoot
│   ├── Root.tsx              # registrasi kedua Composition
│   ├── Video.tsx             # timeline video utama (Sequence + Audio)
│   ├── PlanVideo.tsx         # timeline video rencana
│   ├── theme.ts              # warna, font (selaras Figma)
│   ├── lib/anim.ts           # helper animasi (fadeUp, popIn, slideIn)
│   ├── generated/
│   │   ├── manifest.json     # durasi scene video utama (auto-generated)
│   │   └── manifest-plan.json
│   ├── components/           # Backdrop, SceneShell, Type
│   └── scenes/
│       ├── Scene01…Scene08   # video utama
│       └── PlanScenes.tsx    # 5 scene video rencana
└── out/                      # hasil render
```

---

## Cara Menjalankan Ulang

### 1. Prasyarat

```bash
node --version     # >= 18 (dites di 22.22.2)
python --version   # >= 3.9
pip install edge-tts
```

### 2. Install dependency

```bash
cd uts-video
npm install
```

### 3. Ubah narasi (opsional)

Edit `scripts/script.json` (video utama) atau `scripts/script-plan.json`
(video rencana), lalu regenerasi audio + durasi:

```bash
# video utama
python scripts/generate-tts.py

# video rencana
python scripts/generate-tts.py --script scripts/script-plan.json \
    --manifest src/generated/manifest-plan.json \
    --audio-dir public/audio --prefix plan
```

Script ini menulis `public/audio/*.mp3` dan memperbarui manifest.
**Durasi scene dihitung dari timestamp yang dikirim edge-tts**, bukan
ditebak — jadi visual tidak akan pernah melenceng dari suara, berapa kali
pun narasi diubah.

### 4. Pratinjau di browser

```bash
npm run studio
```

Pilih komposisi `ChronoStoreUTS` atau `ChronoStoreUTSPlan` di panel kiri.

### 5. Render video

```bash
# video utama
npx remotion render ChronoStoreUTS out/chronostore-uts.mp4 --codec=h264 --crf=18

# video rencana
npx remotion render ChronoStoreUTSPlan out/chronostore-uts-plan.mp4 --codec=h264 --crf=18
```

Render pertama akan mengunduh Chrome Headless (~120 MB) sekali saja.

### 6. Ambil still untuk review cepat

```bash
npx remotion still ChronoStoreUTS out/preview-scene4.png --frame=1800
npx remotion still ChronoStoreUTSPlan out/preview-plan4.png --frame=3600
```

---

## Alur Produksi

```
script.json
   │
   ├─ edge-tts ──► public/audio/*.mp3
   │                  │
   │                  └─► timestamp ──► manifest.json (durasi per scene)
   │
   └─ React scenes ──────────────────► Video.tsx (Sequence + Audio)
                                          │
                                          └─► remotion render ──► MP4
```

Karena durasi tiap scene berasal dari audio asli, menambah atau mengubah
satu kalimat narasi otomatis menggeser seluruh timeline tanpa perlu
menyetel timing secara manual.

---

## Scene — Video Utama `ChronoStoreUTS`

| # | Scene | Durasi | Isi |
|---|-------|--------|-----|
| 1 | Pembuka | 18,3 s | Judul, identitas, kelas |
| 2 | Tiga Masalah | 15,4 s | Ringkasan tiga akar masalah |
| 3 | Masalah 1 | 25,3 s | Stok & nomor seri manual, nomor ganda |
| 4 | Masalah 2 | 24,0 s | Spesifikasi tipe mesin tersebar |
| 5 | Masalah 3 | 24,0 s | Servis & garansi terlewat |
| 6 | Target Pengguna | 32,9 s | Persona admin dan pelanggan |
| 7 | Scope | 50,3 s | Prioritas MoSCoW |
| 8 | Penutup | 12,9 s | Tagline, tautan GitHub, identitas |

## Scene — Video Rencana `ChronoStoreUTSPlan`

| # | Scene | Durasi | Isi |
|---|-------|--------|-----|
| 1 | Tech Stack | 24,6 s | Flutter, Dart, Provider, Firebase |
| 2 | Rancangan Firestore | 47,8 s | 4 collection + relasi |
| 3 | Alur Data | 25,9 s | Layar → Provider → Repository → Firestore |
| 4 | Rencana 9–15 | 37,1 s | Roadmap per pertemuan |
| 5 | Kendala & Penutup | 30,8 s | Refleksi, pelajaran, terima kasih |

---

## Palet

Disampel langsung dari wireframe Figma Minggu 4
(lihat [`docs/DESIGN_GUIDE_FIGMA.md`](../docs/DESIGN_GUIDE_FIGMA.md)):

| Peran | Warna |
|-------|-------|
| Latar | `#151515` |
| Permukaan kartu | `#1B1B1B` |
| Kartu terangkat | `#1F1F1F` |
| Aksen emas | `#C9A227` |
| Teks utama | `#FFFFFF` |
| Teks sekunder | `#A0A0A0` |
| Teks redup | `#6E6E6E` |
| Garis | `rgba(255,255,255,0.14)` |
| Status galat | `#EF5350` |
| Status sukses | `#4CAF50` |

Font: **Playfair Display** (judul) dan **Inter** (isi), dimuat lewat
`@remotion/google-fonts` dengan fallback ke Georgia / Segoe UI.

---

## Catatan teknis

**edge-tts 7.x menulis subtitle sebagai JSON Lines, bukan VTT/SRT.**
`generate-tts.py` menangani dua format sekaligus: ia membaca baris
`{"type":"SentenceBoundary","offset":…,"duration":…}` (satuan 100-nanosecond
tick) lalu membagi dengan `10_000_000` untuk mendapat detik. Ada fallback
ke parser SRT/VTT bila format berubah lagi di versi mendatang.

**Suara:** `id-ID-GadisNeural`, rate `-6%` — terdengar lebih tenang dan jelas
untuk konten presentasi.
