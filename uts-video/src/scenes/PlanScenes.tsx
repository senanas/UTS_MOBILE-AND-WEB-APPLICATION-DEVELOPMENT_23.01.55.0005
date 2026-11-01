import React, { Fragment } from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Chip, Eyebrow, GoldRule, Heading, Lead } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { fadeUp, popIn, progress, slideIn } from "../lib/anim";

/* ------------------------------------------------------------------ */
/* 01 — Tech stack                                                     */
/* ------------------------------------------------------------------ */

const GROUPS = [
  {
    title: "Aplikasi",
    note: "Sudah berjalan",
    live: true,
    items: [
      { name: "Flutter", desc: "Framework antarmuka" },
      { name: "Dart", desc: "Bahasa pemrograman" },
      { name: "Provider", desc: "Pengelola state" },
    ],
  },
  {
    title: "Backend",
    note: "Rencana Pertemuan 9–15",
    live: false,
    items: [
      { name: "Firebase Auth", desc: "Login pengguna" },
      { name: "Cloud Firestore", desc: "Basis data" },
      { name: "Firebase Hosting", desc: "Publikasi" },
    ],
  },
];

export const Plan01TechStack: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={30} glowY={32} grid />
      <AbsoluteFill style={{ padding: "96px 140px", justifyContent: "center" }}>
        <Eyebrow delay={6}>Rencana Teknis</Eyebrow>
        <Heading delay={16} size={62} style={{ marginTop: 24 }}>
          Tech stack
        </Heading>
        <Lead delay={30} style={{ marginTop: 22, maxWidth: 1000 }}>
          Flutter untuk antarmuka, Provider untuk state, Firebase paket Spark
          yang gratis untuk backend.
        </Lead>

        <div style={{ display: "flex", gap: 36, marginTop: 56 }}>
          {GROUPS.map((group, gi) => (
            <div
              key={group.title}
              style={{
                flex: 1,
                border: `1px solid ${COLORS.hairlineSoft}`,
                borderRadius: 10,
                backgroundColor: COLORS.bgRaised,
                padding: "30px 34px 34px",
                ...popIn(frame, fps, 38 + gi * 12),
              }}
            >
              <div
                style={{
                  display: "flex",
                  alignItems: "baseline",
                  justifyContent: "space-between",
                }}
              >
                <span
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 20,
                    fontWeight: 700,
                    letterSpacing: 3.4,
                    textTransform: "uppercase",
                    color: group.live ? COLORS.gold : COLORS.dim,
                  }}
                >
                  {group.title}
                </span>
                <span
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 17,
                    color: COLORS.dim,
                  }}
                >
                  {group.note}
                </span>
              </div>

              <div style={{ marginTop: 18 }}>
                <GoldRule delay={48 + gi * 12} width={54} thickness={2} />
              </div>

              <div style={{ marginTop: 24, display: "grid", gap: 18 }}>
                {group.items.map((item, ii) => (
                  <div
                    key={item.name}
                    style={{
                      display: "flex",
                      alignItems: "baseline",
                      gap: 16,
                      ...fadeUp(frame, 56 + gi * 12 + ii * 6, 10, 18),
                    }}
                  >
                    <div
                      style={{
                        width: 5,
                        height: 5,
                        backgroundColor: group.live
                          ? COLORS.gold
                          : COLORS.dim,
                        marginBottom: 6,
                        flexShrink: 0,
                      }}
                    />
                    <div style={{ flex: 1 }}>
                      <div
                        style={{
                          fontFamily: FONT_SANS,
                          fontSize: 27,
                          fontWeight: 600,
                          color: group.live ? COLORS.cream : COLORS.muted,
                        }}
                      >
                        {item.name}
                      </div>
                      <div
                        style={{
                          fontFamily: FONT_SANS,
                          fontSize: 19,
                          color: COLORS.dim,
                          marginTop: 2,
                        }}
                      >
                        {item.desc}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};

/* ------------------------------------------------------------------ */
/* 02 — Firestore schema                                               */
/* ------------------------------------------------------------------ */

const COLLECTIONS = [
  {
    name: "users",
    fields: ["uid", "name", "email", "role"],
  },
  {
    name: "watches",
    fields: [
      "name",
      "brand",
      "model",
      "movementType",
      "price",
      "stock",
      "serialNumber",
      "warrantyEnd",
    ],
  },
  {
    name: "service_records",
    fields: ["watchId", "serviceDate", "serviceType", "cost", "nextServiceDate"],
  },
  {
    name: "transactions",
    fields: [
      "watchId",
      "quantity",
      "unitPrice",
      "totalPrice",
      "userId",
      "status",
    ],
  },
];

export const Plan02Firestore: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={70} glowY={34} />
      <AbsoluteFill style={{ padding: "92px 130px", justifyContent: "center" }}>
        <Eyebrow delay={6}>Basis Data</Eyebrow>
        <Heading delay={16} size={58} style={{ marginTop: 22 }}>
          Rancangan Firestore
        </Heading>
        <Lead delay={30} style={{ marginTop: 20, maxWidth: 1040 }}>
          Empat collection, field mengikuti kebutuhan bisnis — bukan acak.
        </Lead>

        <div
          style={{
            display: "flex",
            gap: 22,
            marginTop: 48,
            alignItems: "stretch",
          }}
        >
          {COLLECTIONS.map((col, ci) => (
            <div
              key={col.name}
              style={{
                flex: 1,
                border: `1px solid ${COLORS.hairlineSoft}`,
                borderRadius: 8,
                backgroundColor: COLORS.bgRaised,
                overflow: "hidden",
                ...popIn(frame, fps, 36 + ci * 9),
              }}
            >
              <div
                style={{
                  padding: "18px 22px",
                  borderBottom: `1px solid ${COLORS.hairlineSoft}`,
                  backgroundColor: COLORS.bgCard,
                }}
              >
                <div
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 21,
                    fontWeight: 700,
                    letterSpacing: 0.6,
                    color: COLORS.gold,
                  }}
                >
                  {col.name}
                </div>
              </div>

              <div style={{ padding: "20px 22px 26px", display: "grid", gap: 10 }}>
                {col.fields.map((f, fi) => (
                  <div
                    key={f}
                    style={{
                      fontFamily: FONT_SANS,
                      fontSize: 20,
                      color: COLORS.cream,
                      letterSpacing: 0.2,
                      opacity: 0.78,
                      ...fadeUp(frame, 50 + ci * 9 + fi * 4, 8, 16),
                    }}
                  >
                    {f}
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        <div
          style={{
            marginTop: 34,
            display: "flex",
            gap: 14,
            ...fadeUp(frame, 96, 10, 20),
          }}
        >
          <Chip delay={96} tone="gold">
            watches 1 — N service_records
          </Chip>
          <Chip delay={102} tone="gold">
            watches 1 — N transactions
          </Chip>
          <Chip delay={108} tone="gold">
            users 1 — N transactions
          </Chip>
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};

/* ------------------------------------------------------------------ */
/* 03 — Data flow                                                      */
/* ------------------------------------------------------------------ */

const LAYERS = [
  { name: "Layar", desc: "lib/screens", state: "tetap" },
  { name: "Provider", desc: "ChangeNotifier", state: "tetap" },
  { name: "Repository", desc: "mock data → Firestore", state: "diganti" },
  { name: "Firestore", desc: "cloud database", state: "baru" },
];

export const Plan03DataFlow: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={50} glowY={36} grid />
      <AbsoluteFill style={{ padding: "110px 130px", justifyContent: "center" }}>
        <Eyebrow delay={6}>Arsitektur</Eyebrow>
        <Heading delay={16} size={58} style={{ marginTop: 22 }}>
          Alur data berlapis
        </Heading>
        <Lead delay={30} style={{ marginTop: 20, maxWidth: 1080 }}>
          Hanya lapisan Repository yang berubah saat pindah ke Firebase.
        </Lead>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            marginTop: 76,
          }}
        >
          {LAYERS.map((layer, li) => {
            const changed = layer.state !== "tetap";
            return (
              <Fragment key={layer.name}>
                <div
                  style={{
                    flex: 1,
                    padding: "34px 26px",
                    borderRadius: 8,
                    border: `1px solid ${
                      changed ? COLORS.hairline : COLORS.hairlineSoft
                    }`,
                    backgroundColor: changed
                      ? COLORS.goldTint
                      : COLORS.bgRaised,
                    textAlign: "center",
                    ...popIn(frame, fps, 38 + li * 10),
                  }}
                >
                  <div
                    style={{
                      fontFamily: FONT_DISPLAY,
                      fontSize: 36,
                      fontWeight: 500,
                      color: changed ? COLORS.gold : COLORS.cream,
                    }}
                  >
                    {layer.name}
                  </div>
                  <div
                    style={{
                      marginTop: 8,
                      fontFamily: FONT_SANS,
                      fontSize: 19,
                      color: COLORS.muted,
                    }}
                  >
                    {layer.desc}
                  </div>
                  <div
                    style={{
                      marginTop: 14,
                      fontFamily: FONT_SANS,
                      fontSize: 15,
                      fontWeight: 700,
                      letterSpacing: 2.2,
                      textTransform: "uppercase",
                      color: changed ? COLORS.gold : COLORS.muted,
                    }}
                  >
                    {layer.state}
                  </div>
                </div>

                {li < LAYERS.length - 1 ? (
                  <div
                    style={{
                      width: 34,
                      textAlign: "center",
                      fontFamily: FONT_SANS,
                      fontSize: 26,
                      color: COLORS.dim,
                      ...fadeUp(frame, 46 + li * 10, 8, 16),
                    }}
                  >
                    →
                  </div>
                ) : null}
              </Fragment>
            );
          })}
        </div>

        <div
          style={{
            marginTop: 54,
            fontFamily: FONT_SANS,
            fontSize: 22,
            color: COLORS.muted,
            ...fadeUp(frame, 96, 10, 20),
          }}
        >
          Layar dan Provider tidak perlu disentuh — inilah alasan repository
          pattern dipakai sejak awal.
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};

/* ------------------------------------------------------------------ */
/* 04 — Roadmap                                                        */
/* ------------------------------------------------------------------ */

const PHASES = [
  { weeks: "9–10", title: "Setup Firebase & autentikasi", done: false },
  { weeks: "11–12", title: "Firestore: watches, services, transactions", done: false },
  { weeks: "13", title: "Security rules & optimasi query", done: false },
  { weeks: "14", title: "Poles UI, keadaan memuat & galat", done: false },
  { weeks: "15", title: "Publikasi ke Firebase Hosting", done: false },
];

export const Plan04Roadmap: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const rail = progress(frame, 34, 44);

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={28} glowY={34} />
      <AbsoluteFill style={{ padding: "88px 140px", justifyContent: "center" }}>
        <Eyebrow delay={6}>Rencana</Eyebrow>
        <Heading delay={16} size={58} style={{ marginTop: 22 }}>
          Pertemuan 9 sampai 15
        </Heading>

        <div style={{ position: "relative", marginTop: 56 }}>
          {PHASES.map((phase, pi) => (
            <div
              key={phase.weeks}
              style={{
                display: "flex",
                alignItems: "center",
                marginBottom: pi === PHASES.length - 1 ? 0 : 30,
                ...slideIn(frame, 40 + pi * 9, 1, 26, 22),
              }}
            >
              <div
                style={{
                  width: 110,
                  paddingRight: 22,
                  textAlign: "right",
                  fontFamily: FONT_SANS,
                  fontSize: 24,
                  fontWeight: 700,
                  letterSpacing: 1.6,
                  color: COLORS.gold,
                  flexShrink: 0,
                }}
              >
                {phase.weeks}
              </div>

              <div
                style={{
                  width: 24,
                  position: "relative",
                  alignSelf: "stretch",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                }}
              >
                {pi < PHASES.length - 1 && (
                  <div
                    style={{
                      position: "absolute",
                      left: "50%",
                      top: "50%",
                      width: 1,
                      height: "calc(50% + 30px)",
                      backgroundColor: COLORS.hairline,
                      transformOrigin: "top center",
                      transform: `scaleY(${rail})`,
                    }}
                  />
                )}
                <div
                  style={{
                    position: "relative",
                    width: 13,
                    height: 13,
                    borderRadius: "50%",
                    border: `2px solid ${COLORS.gold}`,
                    backgroundColor: COLORS.bg,
                  }}
                />
              </div>

              <div
                style={{
                  flex: 1,
                  marginLeft: 22,
                  padding: "20px 28px",
                  border: `1px solid ${COLORS.hairlineSoft}`,
                  borderRadius: 6,
                  backgroundColor: COLORS.bgRaised,
                  fontFamily: FONT_SANS,
                  fontSize: 25,
                  color: COLORS.cream,
                }}
              >
                {phase.title}
              </div>
            </div>
          ))}
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};

/* ------------------------------------------------------------------ */
/* 05 — Closing                                                        */
/* ------------------------------------------------------------------ */

const KENDALA = [
  "Android SDK belum terpasang — uji di Chrome",
  "Skor Figma 83/100, sudah diperbaiki",
];

const PELAJARAN = [
  "Aturan validasi ditetapkan sejak awal",
  "Repository pattern memudahkan migrasi",
];

export const Plan05Closing: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowY={40} />
      <AbsoluteFill style={{ padding: "104px 140px", justifyContent: "center" }}>
        <Eyebrow delay={6}>Refleksi</Eyebrow>
        <Heading delay={16} size={58} style={{ marginTop: 22 }}>
          Kendala dan pelajaran
        </Heading>

        <div style={{ display: "flex", gap: 36, marginTop: 52 }}>
          <div
            style={{
              flex: 1,
              padding: "34px 36px",
              border: `1px solid ${COLORS.hairlineSoft}`,
              borderRadius: 10,
              backgroundColor: COLORS.bgRaised,
              ...popIn(frame, fps, 36),
            }}
          >
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 19,
                fontWeight: 700,
                letterSpacing: 3.2,
                textTransform: "uppercase",
                color: COLORS.warning,
              }}
            >
              Kendala
            </div>
            <div style={{ marginTop: 24, display: "grid", gap: 18 }}>
              {KENDALA.map((k, i) => (
                <div
                  key={k}
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 24,
                    lineHeight: 1.5,
                    color: COLORS.muted,
                    ...fadeUp(frame, 48 + i * 8, 10, 18),
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
              padding: "34px 36px",
              border: `1px solid ${COLORS.hairline}`,
              borderRadius: 10,
              backgroundColor: COLORS.goldTint,
              ...popIn(frame, fps, 46),
            }}
          >
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 19,
                fontWeight: 700,
                letterSpacing: 3.2,
                textTransform: "uppercase",
                color: COLORS.gold,
              }}
            >
              Pelajaran
            </div>
            <div style={{ marginTop: 24, display: "grid", gap: 18 }}>
              {PELAJARAN.map((p, i) => (
                <div
                  key={p}
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 24,
                    lineHeight: 1.5,
                    color: COLORS.cream,
                    ...fadeUp(frame, 58 + i * 8, 10, 18),
                  }}
                >
                  {p}
                </div>
              ))}
            </div>
          </div>
        </div>

        <div
          style={{
            marginTop: 64,
            ...fadeUp(frame, 82, 14, 24),
          }}
        >
          <div
            style={{
              height: 1,
              width: "100%",
              backgroundColor: COLORS.hairlineSoft,
            }}
          />
          <div
            style={{
              marginTop: 32,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 24,
            }}
          >
            <GoldRule delay={82} width={64} thickness={2} />
            <span
              style={{
                fontFamily: FONT_DISPLAY,
                fontSize: 50,
                fontWeight: 500,
                color: COLORS.cream,
                letterSpacing: 2,
              }}
            >
              Terima kasih
            </span>
            <GoldRule delay={82} width={64} thickness={2} />
          </div>
          <div
            style={{
              marginTop: 20,
              textAlign: "center",
              fontFamily: FONT_SANS,
              fontSize: 17,
              letterSpacing: 4,
              textTransform: "uppercase",
              color: COLORS.dim,
            }}
          >
            Maheswari Shafa Helga · 23.01.55.0005 · Kelas A1
          </div>
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
