# ChronoStore — Video UTS

Video presentasi UTS untuk project **ChronoStore**, dibuat dengan **Remotion** (React) dan narasi **edge-tts** (gratis, tanpa API key).

**Isi video:** masalah, target pengguna, dan scope project.
**Durasi:** 3 menit 23 detik · 1920×1080 · 30 fps · MP4 (H.264)

---

## Hasil

| Berkas | Keterangan |
|--------|------------|
| `out/chronostore-uts.mp4` | Video final siap dikumpulkan |
| `out/preview-scene*.png` | Still per scene untuk review cepat |

---

## Struktur

```
uts-video/
├── scripts/
│   ├── script.json          # teks narasi per scene (sumber kebenaran)
│   └── generate-tts.py      # edge-tts → MP3 + manifest durasi
├── public/audio/            # 8 MP3 narasi + berkas timing
├── src/
│   ├── index.ts             # registerRoot
│   ├── Root.tsx             # registrasi Composition
│   ├── Video.tsx            # timeline: Sequence + Audio
│   ├── theme.ts             # warna, font, ukuran
│   ├── lib/anim.ts          # helper animasi (fadeUp, popIn, slideIn)
│   ├── generated/manifest.json   # durasi tiap scene (auto-generated)
│   ├── components/          # Backdrop, SceneShell, Type
│   └── scenes/              # Scene01 … Scene08
└── out/                     # hasil render
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

Edit `scripts/script.json`, lalu regenerasi audio + durasi:

```bash
python scripts/generate-tts.py
```

Script ini menulis `public/audio/sceneNN.mp3` dan memperbarui
`src/generated/manifest.json`. Durasi scene dihitung dari timestamp
yang dikirim edge-tts, jadi visual tidak akan pernah melenceng dari suara.

### 4. Pratinjau di browser

```bash
npm run studio
```

### 5. Render video

```bash
npm run render
```

Hasil: `out/chronostore-uts.mp4`

Render pertama akan mengunduh Chrome Headless (~120 MB) sekali saja.

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

## Scene

| # | Scene | Durasi | Isi |
|---|-------|--------|-----|
| 1 | Pembuka | 18,3 s | Judul, identitas, kelas |
| 2 | Tiga Masalah | 15,4 s | Ringkasan tiga akar masalah |
| 3 | Masalah 1 | 25,3 s | Stok & nomor seri manual, nomor ganda |
| 4 | Masalah 2 | 24,0 s | Spesifikasi tipe mesin tersebar |
| 5 | Masalah 3 | 24,0 s | Servis & garansi terlewat |
| 6 | Target Pengguna | 32,9 s | Persona admin dan pelanggan |
| 7 | Scope | 50,3 s | Prioritas MoSCoW |
| 8 | Penutup | 12,9 s | Tagline + tautan GitHub |

---

## Palet

| Peran | Warna |
|-------|-------|
| Latar | `#12100C` |
| Aksen emas | `#C9A227` |
| Teks utama | `#F5F1E8` |
| Teks sekunder | `#A69E8D` |
| Status galat | `#C62828` |

Font: **Playfair Display** (judul) dan **Inter** (isi), dimuat lewat
`@remotion/google-fonts` dengan fallback ke Georgia / Segoe UI.
