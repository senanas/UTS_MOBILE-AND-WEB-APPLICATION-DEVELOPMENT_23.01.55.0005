import type React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Chip, Eyebrow, GoldRule, Heading, Lead } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { fadeUp, popIn, progress, slideIn } from "../lib/anim";

/* ------------------------------------------------------------------ */
/* Shared stage                                                        */
/* ------------------------------------------------------------------ */

const Stage: React.FC<{
  children: React.ReactNode;
  padding?: string;
  glowX?: number;
  glowY?: number;
  grid?: boolean;
  align?: "flex-start" | "center";
}> = ({ children, padding = "86px 140px", glowX = 50, glowY = 36, grid, align = "center" }) => (
  <AbsoluteFill style={{ padding, justifyContent: align, flexDirection: "column" }}>
    <Backdrop glowX={glowX} glowY={glowY} grid={grid} />
    {children}
  </AbsoluteFill>
);

const Shell: React.FC<{ d: number; children: React.ReactNode }> = ({ d, children }) => (
  <SceneShell durationInFrames={d}>{children}</SceneShell>
);

/* ------------------------------------------------------------------ */
/* 01 — Opening                                                        */
/* ------------------------------------------------------------------ */

const AGENDA = [
  "Pembuka",
  "Masalah & Pengguna",
  "Kebutuhan",
  "Rancangan",
  "Demo Prototype",
  "Rencana Teknis",
];

export const Opening: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();

  return (
    <Shell d={durationInFrames}>
      <Stage glowY={44}>
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            textAlign: "center",
            gap: 26,
          }}
        >
          <GoldRule delay={4} width={90} thickness={2} />

          <div
            style={{
              fontFamily: FONT_SANS,
              fontSize: 20,
              fontWeight: 600,
              letterSpacing: 5.5,
              textTransform: "uppercase",
              color: COLORS.gold,
              ...fadeUp(frame, 10, 14, 22),
            }}
          >
            UTS — Mobile and Web Application Development
          </div>

          <h1
            style={{
              margin: 0,
              fontFamily: FONT_DISPLAY,
              fontSize: 128,
              fontWeight: 500,
              letterSpacing: 6,
              lineHeight: 1,
              color: COLORS.cream,
              ...fadeUp(frame, 18, 34, 30),
            }}
          >
            ChronoStore
          </h1>

          <div
            style={{
              fontFamily: FONT_SANS,
              fontSize: 30,
              letterSpacing: 0.6,
              color: COLORS.muted,
              ...fadeUp(frame, 28, 20, 24),
            }}
          >
            Sistem Informasi Manajemen Toko Jam Tangan
          </div>

          <div
            style={{
              marginTop: 6,
              fontFamily: FONT_SANS,
              fontSize: 19,
              letterSpacing: 3.6,
              textTransform: "uppercase",
              color: COLORS.dim,
              ...fadeUp(frame, 40, 14, 22),
            }}
          >
            Maheswari Shafa Helga · 23.01.55.0005 · Kelas A1
          </div>
        </div>

        {/* agenda strip */}
        <div
          style={{
            position: "absolute",
            left: 140,
            right: 140,
            bottom: 74,
            display: "flex",
            gap: 12,
          }}
        >
          {AGENDA.map((label, i) => (
            <div
              key={label}
              style={{
                flex: 1,
                padding: "16px 10px",
                borderTop: `2px solid ${i === 0 ? COLORS.gold : COLORS.hairlineSoft}`,
                textAlign: "center",
                ...fadeUp(frame, 56 + i * 6, 12, 18),
              }}
            >
              <div
                style={{
                  fontFamily: FONT_SANS,
                  fontSize: 13,
                  fontWeight: 700,
                  letterSpacing: 2.6,
                  color: i === 0 ? COLORS.gold : COLORS.dim,
                }}
              >
                {String(i + 1).padStart(2, "0")}
              </div>
              <div
                style={{
                  marginTop: 7,
                  fontFamily: FONT_SANS,
                  fontSize: 16,
                  letterSpacing: 0.4,
                  color: i === 0 ? COLORS.cream : COLORS.muted,
                }}
              >
                {label}
              </div>
            </div>
          ))}
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 02 — Problem                                                        */
/* ------------------------------------------------------------------ */

const PROBLEMS = [
  {
    no: "01",
    title: "Stok & Nomor Seri",
    where: "Dicatat di buku",
    body: "Nomor seri bisa tercatat ganda dan jumlah stok tidak akurat.",
    tags: ["Nomor ganda", "Stok salah"],
  },
  {
    no: "02",
    title: "Spesifikasi Mesin",
    where: "Tersebar di nota",
    body: "Automatic, quartz, dan solar butuh perawatan yang berbeda.",
    tags: ["Data tersebar", "Servis keliru"],
  },
  {
    no: "03",
    title: "Servis & Garansi",
    where: "Tidak terkelola",
    body: "Garansi terlewat dan pelanggan kehilangan hak servisnya.",
    tags: ["Garansi lewat", "Hak hilang"],
  },
];

export const Problem: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <Shell d={durationInFrames}>
      <Stage glowX={50} glowY={30}>
        <Eyebrow delay={4}>Bagian 2 — Masalah</Eyebrow>
        <Heading delay={14} size={62} style={{ marginTop: 20 }}>
          Satu akar, tiga wujud
        </Heading>
        <Lead delay={26} style={{ marginTop: 16, maxWidth: 1180 }}>
          Pencatatan toko jam tangan masih manual dan tersebar di banyak tempat.
        </Lead>

        <div style={{ display: "flex", gap: 26, marginTop: 52 }}>
          {PROBLEMS.map((p, i) => (
            <div
              key={p.no}
              style={{
                flex: 1,
                padding: "32px 32px 30px",
                border: `1px solid ${COLORS.hairlineSoft}`,
                borderRadius: 10,
                backgroundColor: COLORS.bgRaised,
                ...popIn(frame, fps, 38 + i * 10),
              }}
            >
              <div
                style={{
                  fontFamily: FONT_DISPLAY,
                  fontSize: 46,
                  fontWeight: 500,
                  color: COLORS.goldDim,
                  lineHeight: 1,
                }}
              >
                {p.no}
              </div>
              <div
                style={{
                  marginTop: 18,
                  fontFamily: FONT_SANS,
                  fontSize: 27,
                  fontWeight: 700,
                  color: COLORS.cream,
                }}
              >
                {p.title}
              </div>
              <div
                style={{
                  marginTop: 8,
                  fontFamily: FONT_SANS,
                  fontSize: 17,
                  letterSpacing: 2.4,
                  textTransform: "uppercase",
                  color: COLORS.error,
                }}
              >
                {p.where}
              </div>
              <div
                style={{
                  marginTop: 18,
                  fontFamily: FONT_SANS,
                  fontSize: 21,
                  lineHeight: 1.55,
                  color: COLORS.muted,
                  minHeight: 98,
                }}
              >
                {p.body}
              </div>
              <div style={{ display: "flex", gap: 10, marginTop: 20, flexWrap: "wrap" }}>
                {p.tags.map((t, ti) => (
                  <Chip key={t} delay={54 + i * 10 + ti * 5} tone="error">
                    {t}
                  </Chip>
                ))}
              </div>
            </div>
          ))}
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 03 — Why it matters                                                 */
/* ------------------------------------------------------------------ */

const FACTS = [
  { k: "Puluhan juta", v: "nilai satu unit jam tangan" },
  { k: "Bukti servis", v: "menentukan harga jual kembali" },
  { k: "Puluhan unit", v: "dikelola satu admin setiap hari" },
];

export const Why: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <Shell d={durationInFrames}>
      <Stage glowX={30} glowY={40}>
        <div style={{ display: "flex", gap: 90, alignItems: "center" }}>
          <div style={{ flex: 1.15 }}>
            <Eyebrow delay={4}>Mengapa penting</Eyebrow>
            <h1
              style={{
                margin: 0,
                marginTop: 24,
                fontFamily: FONT_DISPLAY,
                fontSize: 62,
                fontWeight: 500,
                lineHeight: 1.22,
                letterSpacing: -0.6,
                color: COLORS.cream,
                ...fadeUp(frame, 14, 26, 26),
              }}
            >
              Jam tangan bukan
              <br />
              barang murah.
            </h1>
            <Lead delay={30} style={{ marginTop: 26, maxWidth: 660, fontSize: 25 }}>
              Nilai jualnya bergantung pada bukti nomor seri dan riwayat servis.
              Kalau catatan itu hilang, nilai aset pelanggan ikut hilang.
            </Lead>
          </div>

          <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 18 }}>
            {FACTS.map((f, i) => (
              <div
                key={f.k}
                style={{
                  display: "flex",
                  alignItems: "baseline",
                  gap: 22,
                  padding: "24px 28px",
                  border: `1px solid ${COLORS.hairlineSoft}`,
                  borderRadius: 8,
                  backgroundColor: COLORS.bgRaised,
                  ...popIn(frame, fps, 34 + i * 9),
                }}
              >
                <div
                  style={{
                    fontFamily: FONT_DISPLAY,
                    fontSize: 32,
                    fontWeight: 500,
                    color: COLORS.gold,
                    whiteSpace: "nowrap",
                  }}
                >
                  {f.k}
                </div>
                <div
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 19,
                    lineHeight: 1.45,
                    color: COLORS.muted,
                  }}
                >
                  {f.v}
                </div>
              </div>
            ))}

            <div
              style={{
                marginTop: 6,
                fontFamily: FONT_SANS,
                fontSize: 17,
                letterSpacing: 3,
                textTransform: "uppercase",
                color: COLORS.dim,
                ...fadeUp(frame, 62, 12, 20),
              }}
            >
              Pengguna utama → admin / pemilik toko
            </div>
          </div>
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 04 — Personas                                                       */
/* ------------------------------------------------------------------ */

export const Persona: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const cards = [
    {
      badge: "Pengguna Utama",
      name: "Andi",
      meta: "34 tahun · Pemilik toko",
      gold: true,
      needs: [
        "Kelola ±60 unit dengan nomor seri berbeda",
        "Cari satu unit dalam hitungan detik",
        "Pengingat garansi otomatis",
      ],
    },
    {
      badge: "Pengguna Sekunder",
      name: "Siti",
      meta: "28 tahun · Calon pembeli",
      gold: false,
      needs: [
        "Jelajah katalog yang tersedia",
        "Bandingkan spesifikasi tipe mesin",
        "Pesan tanpa harus datang ke toko",
      ],
    },
  ];

  return (
    <Shell d={durationInFrames}>
      <Stage glowX={70} glowY={34}>
        <Eyebrow delay={4}>Persona</Eyebrow>
        <Heading delay={14} size={60} style={{ marginTop: 20 }}>
          Dua orang, dua kebutuhan
        </Heading>

        <div style={{ display: "flex", gap: 32, marginTop: 46 }}>
          {cards.map((c, i) => (
            <div
              key={c.name}
              style={{
                flex: 1,
                padding: "34px 36px",
                border: `1px solid ${c.gold ? COLORS.hairline : COLORS.hairlineSoft}`,
                borderRadius: 12,
                backgroundColor: c.gold ? COLORS.goldTint : COLORS.bgRaised,
                ...popIn(frame, fps, 30 + i * 12),
              }}
            >
              <div
                style={{
                  fontFamily: FONT_SANS,
                  fontSize: 15,
                  fontWeight: 700,
                  letterSpacing: 3.4,
                  textTransform: "uppercase",
                  color: c.gold ? COLORS.gold : COLORS.dim,
                }}
              >
                {c.badge}
              </div>

              <div
                style={{
                  marginTop: 16,
                  fontFamily: FONT_DISPLAY,
                  fontSize: 54,
                  fontWeight: 500,
                  color: COLORS.cream,
                  lineHeight: 1,
                }}
              >
                {c.name}
              </div>
              <div
                style={{
                  marginTop: 10,
                  fontFamily: FONT_SANS,
                  fontSize: 19,
                  color: COLORS.muted,
                }}
              >
                {c.meta}
              </div>

              <div style={{ marginTop: 26, display: "grid", gap: 13 }}>
                {c.needs.map((n, ni) => (
                  <div
                    key={n}
                    style={{
                      display: "flex",
                      gap: 13,
                      fontFamily: FONT_SANS,
                      fontSize: 20,
                      lineHeight: 1.5,
                      color: c.gold ? COLORS.cream : COLORS.muted,
                      ...fadeUp(frame, 50 + i * 10 + ni * 6, 10, 16),
                    }}
                  >
                    <span style={{ color: COLORS.gold, flexShrink: 0 }}>—</span>
                    <span>{n}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 05 — User stories                                                   */
/* ------------------------------------------------------------------ */

const STORIES = [
  { id: "US-01", who: "Admin", want: "kelola data jam tangan lengkap", so: "data produk selalu akurat" },
  { id: "US-02", who: "Admin", want: "nomor seri divalidasi unik", so: "tidak ada nomor ganda" },
  { id: "US-03", who: "Admin", want: "catat riwayat servis per unit", so: "jadwal servis terlacak" },
  { id: "US-04", who: "Admin", want: "pengingat garansi jatuh tempo", so: "tidak ada hak pelanggan yang hilang" },
  { id: "US-05", who: "Pelanggan", want: "katalog dengan filter mesin", so: "cepat menemukan pilihan" },
];

export const Stories: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();

  return (
    <Shell d={durationInFrames}>
      <Stage glowX={44} glowY={32}>
        <Eyebrow delay={4}>Bagian 3 — Kebutuhan</Eyebrow>
        <Heading delay={14} size={60} style={{ marginTop: 20 }}>
          Lima user story
        </Heading>

        <div style={{ marginTop: 44, display: "grid", gap: 13 }}>
          {STORIES.map((s, i) => (
            <div
              key={s.id}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 26,
                padding: "21px 28px",
                border: `1px solid ${COLORS.hairlineSoft}`,
                borderRadius: 8,
                backgroundColor: COLORS.bgRaised,
                ...slideIn(frame, 30 + i * 8, -1, 34, 22),
              }}
            >
              <div
                style={{
                  width: 92,
                  flexShrink: 0,
                  fontFamily: FONT_SANS,
                  fontSize: 17,
                  fontWeight: 700,
                  letterSpacing: 1.6,
                  color: COLORS.gold,
                }}
              >
                {s.id}
              </div>
              <div
                style={{
                  flex: 1,
                  fontFamily: FONT_SANS,
                  fontSize: 22,
                  lineHeight: 1.4,
                  color: COLORS.muted,
                }}
              >
                Sebagai <strong style={{ color: COLORS.cream }}>{s.who}</strong>, saya ingin{" "}
                <strong style={{ color: COLORS.cream }}>{s.want}</strong>, sehingga{" "}
                <span style={{ color: COLORS.muted }}>{s.so}</span>.
              </div>
            </div>
          ))}
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 06 — MoSCoW                                                         */
/* ------------------------------------------------------------------ */

const MOSCOW = [
  {
    label: "Must",
    tone: COLORS.gold,
    tint: COLORS.goldTint,
    border: COLORS.hairline,
    items: ["Autentikasi", "CRUD jam + nomor seri unik", "Riwayat servis", "Katalog pelanggan"],
    note: "Tanpa ini aplikasi tidak berfungsi",
  },
  {
    label: "Should",
    tone: COLORS.muted,
    tint: COLORS.bgRaised,
    border: COLORS.hairlineSoft,
    items: ["Dashboard ringkasan", "Pengingat garansi", "Transaksi"],
    note: "Nilai tambah, sudah ada di kode",
  },
  {
    label: "Won't",
    tone: COLORS.dim,
    tint: COLORS.bgRaised,
    border: COLORS.hairlineSoft,
    items: ["Integrasi Firebase", "Pembayaran online", "Notifikasi WhatsApp"],
    note: "Fase UAS",
  },
];

export const Moscow: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <Shell d={durationInFrames}>
      <Stage glowX={56} glowY={30}>
        <Eyebrow delay={4}>Prioritas</Eyebrow>
        <Heading delay={14} size={58} style={{ marginTop: 18 }}>
          MoSCoW
        </Heading>

        <div style={{ display: "flex", gap: 26, marginTop: 42 }}>
          {MOSCOW.map((col, i) => (
            <div
              key={col.label}
              style={{
                flex: 1,
                padding: "32px 30px 34px",
                border: `1px solid ${col.border}`,
                borderRadius: 10,
                backgroundColor: col.tint,
                ...popIn(frame, fps, 28 + i * 11),
              }}
            >
              <div
                style={{
                  fontFamily: FONT_DISPLAY,
                  fontSize: 40,
                  fontWeight: 500,
                  color: col.tone,
                }}
              >
                {col.label}
              </div>
              <div
                style={{
                  marginTop: 7,
                  fontFamily: FONT_SANS,
                  fontSize: 16,
                  color: COLORS.dim,
                  letterSpacing: 0.3,
                }}
              >
                {col.note}
              </div>

              <div style={{ marginTop: 24, display: "grid", gap: 14 }}>
                {col.items.map((it, ii) => (
                  <div
                    key={it}
                    style={{
                      display: "flex",
                      gap: 12,
                      fontFamily: FONT_SANS,
                      fontSize: 21,
                      lineHeight: 1.5,
                      color: i === 0 ? COLORS.cream : COLORS.muted,
                      ...fadeUp(frame, 46 + i * 10 + ii * 5, 9, 15),
                    }}
                  >
                    <span style={{ color: col.tone, flexShrink: 0 }}>·</span>
                    <span>{it}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 07 — User flow                                                      */
/* ------------------------------------------------------------------ */

type Node = { label: string; x: number; y: number; w: number; accent?: boolean };

const FLOW_NODES: Node[] = [
  { label: "Login", x: 0, y: 96, w: 180 },
  { label: "Dashboard", x: 250, y: 96, w: 200, accent: true },
  { label: "Data Jam", x: 520, y: 96, w: 200, accent: true },
  { label: "Form Jam", x: 790, y: 24, w: 200 },
  { label: "Detail Jam", x: 790, y: 168, w: 200 },
  { label: "Riwayat Servis", x: 1050, y: 168, w: 230, accent: true },
  { label: "Pengingat", x: 250, y: 288, w: 200 },
  { label: "Detail Jam", x: 790, y: 288, w: 200 },
];

export const Flow: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const p = progress(frame, 30, 60);

  return (
    <Shell d={durationInFrames}>
      <Stage padding="80px 140px" glowX={50} glowY={40} grid>
        <Eyebrow delay={4}>Bagian 4 — Rancangan</Eyebrow>
        <Heading delay={14} size={58} style={{ marginTop: 18 }}>
          User flow
        </Heading>

        <div style={{ position: "relative", height: 420, marginTop: 40 }}>
          {/* connectors — Pengingat branches off Dashboard, not Data Jam */}
          <svg
            width="1280"
            height="420"
            style={{ position: "absolute", inset: 0, opacity: p }}
          >
            <defs>
              <marker id="ah" markerWidth="9" markerHeight="9" refX="7" refY="4.5" orient="auto">
                <path d="M0 0 L9 4.5 L0 9 Z" fill={COLORS.hairline} />
              </marker>
            </defs>
            {[
              "M180 126 H250",
              "M450 126 H520",
              "M720 118 L790 54",
              "M720 136 L790 198",
              "M990 198 H1050",
              "M350 156 V288",
              "M450 318 H790",
            ].map((d) => (
              <path
                key={d}
                d={d}
                stroke={COLORS.hairline}
                strokeWidth="1.6"
                fill="none"
                markerEnd="url(#ah)"
              />
            ))}
          </svg>

          {FLOW_NODES.map((n, i) => (
            <div
              key={`${n.label}-${n.x}-${n.y}`}
              style={{
                position: "absolute",
                left: n.x,
                top: n.y,
                width: n.w,
                padding: "18px 14px",
                borderRadius: 8,
                border: `1px solid ${n.accent ? COLORS.hairline : COLORS.hairlineSoft}`,
                backgroundColor: n.accent ? COLORS.goldTint : COLORS.bgRaised,
                textAlign: "center",
                fontFamily: FONT_SANS,
                fontSize: 20,
                fontWeight: 600,
                color: n.accent ? COLORS.gold : COLORS.cream,
                ...fadeUp(frame, 34 + i * 6, 14, 18),
              }}
            >
              {n.label}
            </div>
          ))}
        </div>

        <div
          style={{
            marginTop: 4,
            fontFamily: FONT_SANS,
            fontSize: 19,
            color: COLORS.muted,
            ...fadeUp(frame, 92, 10, 20),
          }}
        >
          Semua jalur kembali ke daftar — tidak ada halaman buntu.
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 08 — Sitemap                                                        */
/* ------------------------------------------------------------------ */

const PAGES = [
  { code: "H1", name: "Login", must: true },
  { code: "H2", name: "Register", must: true },
  { code: "H3", name: "Dashboard", must: true },
  { code: "H4", name: "Data Jam Tangan", must: true },
  { code: "H5", name: "Form Jam", must: true },
  { code: "H6", name: "Detail Jam", must: false },
  { code: "H7", name: "Pengingat", must: false },
  { code: "H8", name: "Riwayat Servis", must: true },
  { code: "H9", name: "Transaksi", must: false },
  { code: "H10", name: "Form Transaksi", must: false },
  { code: "H11", name: "Main Shell", must: false },
];

export const Sitemap: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();

  return (
    <Shell d={durationInFrames}>
      <Stage glowX={46} glowY={34}>
        <Eyebrow delay={4}>Sitemap</Eyebrow>
        <Heading delay={14} size={58} style={{ marginTop: 18 }}>
          Sebelas halaman
        </Heading>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(4, 1fr)",
            gap: 14,
            marginTop: 44,
          }}
        >
          {PAGES.map((pg, i) => (
            <div
              key={pg.code}
              style={{
                padding: "20px 22px",
                borderRadius: 8,
                border: `1px solid ${pg.must ? COLORS.hairline : COLORS.hairlineSoft}`,
                backgroundColor: pg.must ? COLORS.goldTint : COLORS.bgRaised,
                ...fadeUp(frame, 28 + i * 5, 14, 18),
              }}
            >
              <div
                style={{
                  fontFamily: FONT_SANS,
                  fontSize: 13,
                  fontWeight: 700,
                  letterSpacing: 2.2,
                  color: pg.must ? COLORS.gold : COLORS.dim,
                }}
              >
                {pg.code}
              </div>
              <div
                style={{
                  marginTop: 7,
                  fontFamily: FONT_SANS,
                  fontSize: 21,
                  fontWeight: 600,
                  color: pg.must ? COLORS.cream : COLORS.muted,
                }}
              >
                {pg.name}
              </div>
            </div>
          ))}

          <div
            style={{
              padding: "20px 22px",
              borderRadius: 8,
              border: `1px dashed ${COLORS.hairlineSoft}`,
              display: "flex",
              flexDirection: "column",
              justifyContent: "center",
              ...fadeUp(frame, 86, 14, 18),
            }}
          >
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 15,
                lineHeight: 1.5,
                color: COLORS.dim,
              }}
            >
              6 Must · 5 Should
            </div>
          </div>
        </div>

        <div
          style={{
            marginTop: 30,
            display: "flex",
            gap: 14,
            ...fadeUp(frame, 94, 10, 20),
          }}
        >
          <Chip delay={94} tone="gold">
            NavigationRail / BottomNavigationBar
          </Chip>
          <Chip delay={100}>push &amp; pop untuk halaman anak</Chip>
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 09 — Wireframe to app                                               */
/* ------------------------------------------------------------------ */

const SWATCHES = [
  { hex: "#151515", role: "Latar" },
  { hex: "#1B1B1B", role: "Kartu" },
  { hex: "#C9A227", role: "Aksen" },
  { hex: "#FFFFFF", role: "Teks" },
];

export const Wireframe: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <Shell d={durationInFrames}>
      <Stage glowX={38} glowY={36}>
        <Eyebrow delay={4}>Wireframe → aplikasi</Eyebrow>
        <Heading delay={14} size={56} style={{ marginTop: 18 }}>
          Rancangan tidak berhenti di Figma
        </Heading>

        <div style={{ display: "flex", gap: 56, marginTop: 48, alignItems: "flex-start" }}>
          <div style={{ flex: 1 }}>
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 15,
                fontWeight: 700,
                letterSpacing: 3,
                textTransform: "uppercase",
                color: COLORS.dim,
                ...fadeUp(frame, 26, 10, 16),
              }}
            >
              Palet dari file Figma
            </div>

            <div style={{ display: "flex", gap: 16, marginTop: 20 }}>
              {SWATCHES.map((s, i) => (
                <div key={s.hex} style={{ ...popIn(frame, fps, 32 + i * 8) }}>
                  <div
                    style={{
                      width: 108,
                      height: 108,
                      borderRadius: 8,
                      backgroundColor: s.hex,
                      border: `1px solid ${COLORS.hairlineSoft}`,
                    }}
                  />
                  <div
                    style={{
                      marginTop: 12,
                      fontFamily: FONT_SANS,
                      fontSize: 16,
                      fontWeight: 600,
                      color: COLORS.cream,
                    }}
                  >
                    {s.role}
                  </div>
                  <div
                    style={{
                      marginTop: 3,
                      fontFamily: FONT_SANS,
                      fontSize: 14,
                      letterSpacing: 0.8,
                      color: COLORS.dim,
                    }}
                  >
                    {s.hex}
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div style={{ flex: 1.1, display: "grid", gap: 14 }}>
            {[
              "Palet, radius, dan tipografi diambil dari Figma Minggu 4",
              "Nilai yang sama dipakai di aplikasi Flutter",
              "Video ini memakai token warna yang identik",
            ].map((t, i) => (
              <div
                key={t}
                style={{
                  display: "flex",
                  gap: 14,
                  padding: "20px 24px",
                  border: `1px solid ${COLORS.hairlineSoft}`,
                  borderRadius: 8,
                  backgroundColor: COLORS.bgRaised,
                  fontFamily: FONT_SANS,
                  fontSize: 20,
                  lineHeight: 1.5,
                  color: COLORS.muted,
                  ...fadeUp(frame, 44 + i * 9, 12, 18),
                }}
              >
                <span style={{ color: COLORS.gold, flexShrink: 0 }}>—</span>
                <span>{t}</span>
              </div>
            ))}
          </div>
        </div>
      </Stage>
    </Shell>
  );
};

/* ------------------------------------------------------------------ */
/* 10 — Closing                                                        */
/* ------------------------------------------------------------------ */

const KENDALA = [
  "Android SDK belum terpasang — uji di Chrome",
  "Skor Figma 83/100, sudah diperbaiki",
];

const PELAJARAN = [
  "Aturan validasi ditetapkan sejak awal",
  "Repository pattern memisahkan lapisan data",
];

export const FullClosing: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <Shell d={durationInFrames}>
      <Stage glowY={38}>
        <Eyebrow delay={4}>Kendala &amp; pelajaran</Eyebrow>
        <Heading delay={14} size={56} style={{ marginTop: 18 }}>
          Apa yang belum selesai
        </Heading>

        <div style={{ display: "flex", gap: 30, marginTop: 40 }}>
          <div
            style={{
              flex: 1,
              padding: "28px 30px",
              border: `1px solid ${COLORS.hairlineSoft}`,
              borderRadius: 10,
              backgroundColor: COLORS.bgRaised,
              ...popIn(frame, fps, 28),
            }}
          >
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 15,
                fontWeight: 700,
                letterSpacing: 3.2,
                textTransform: "uppercase",
                color: COLORS.warning,
              }}
            >
              Kendala
            </div>
            <div style={{ marginTop: 20, display: "grid", gap: 14 }}>
              {KENDALA.map((k, i) => (
                <div
                  key={k}
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 21,
                    lineHeight: 1.5,
                    color: COLORS.muted,
                    ...fadeUp(frame, 40 + i * 7, 10, 16),
                  }}
                >
                  {k}
                </div>
              ))}
            </div>
          </div>

          <div
            style={{
              flex: 1,
              padding: "28px 30px",
              border: `1px solid ${COLORS.hairline}`,
              borderRadius: 10,
              backgroundColor: COLORS.goldTint,
              ...popIn(frame, fps, 38),
            }}
          >
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 15,
                fontWeight: 700,
                letterSpacing: 3.2,
                textTransform: "uppercase",
                color: COLORS.gold,
              }}
            >
              Pelajaran
            </div>
            <div style={{ marginTop: 20, display: "grid", gap: 14 }}>
              {PELAJARAN.map((k, i) => (
                <div
                  key={k}
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 21,
                    lineHeight: 1.5,
                    color: COLORS.cream,
                    ...fadeUp(frame, 48 + i * 7, 10, 16),
                  }}
                >
                  {k}
                </div>
              ))}
            </div>
          </div>
        </div>

        <div style={{ marginTop: 44, ...fadeUp(frame, 68, 14, 22) }}>
          <div style={{ height: 1, width: "100%", backgroundColor: COLORS.hairlineSoft }} />
          <div
            style={{
              marginTop: 26,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 24,
            }}
          >
            <GoldRule delay={68} width={60} thickness={2} />
            <span
              style={{
                fontFamily: FONT_DISPLAY,
                fontSize: 46,
                fontWeight: 500,
                color: COLORS.cream,
                letterSpacing: 2,
              }}
            >
              Terima kasih
            </span>
            <GoldRule delay={68} width={60} thickness={2} />
          </div>
          <div
            style={{
              marginTop: 16,
              textAlign: "center",
              fontFamily: FONT_SANS,
              fontSize: 16,
              letterSpacing: 3.6,
              textTransform: "uppercase",
              color: COLORS.dim,
            }}
          >
            Maheswari Shafa Helga · 23.01.55.0005 · Kelas A1
          </div>
        </div>
      </Stage>
    </Shell>
  );
};
