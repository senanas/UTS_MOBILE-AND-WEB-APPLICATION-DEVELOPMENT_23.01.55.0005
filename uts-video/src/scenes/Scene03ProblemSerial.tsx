import type React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Chip, Eyebrow, Heading, Lead } from "../components/Type";
import { COLORS, FONT_SANS } from "../theme";
import { fadeUp, progress } from "../lib/anim";

type Row = {
  serial: string;
  name: string;
  stock: number;
  duplicate?: boolean;
};

const ROWS: Row[] = [
  { serial: "SK-SRPD65-001", name: "Seiko 5 Sports", stock: 5 },
  { serial: "CS-GA2100-002", name: "Casio G-Shock", stock: 8 },
  { serial: "SK-SRPD65-001", name: "Seiko 5 Sports", stock: 5, duplicate: true },
  { serial: "CZ-AW0040-003", name: "Citizen Eco-Drive", stock: 0 },
];

const CONSEQUENCES = [
  "Nomor seri ganda",
  "Stok tidak akurat",
  "Pencarian lambat",
];

export const Scene03ProblemSerial: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();

  const flagAt = 58;
  const highlight = progress(frame, flagAt, 18);
  const badge = progress(frame, flagAt + 6, 16);

  // Stock figure that never settles — the point of the scene.
  const jitter = [5, 5, 3, 5, 7, 5, 3, 4][Math.floor(frame / 9) % 8];

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={74} glowY={46} />

      <AbsoluteFill
        style={{
          padding: "0 120px",
          flexDirection: "row",
          alignItems: "center",
          gap: 90,
        }}
      >
        {/* ---------- copy ---------- */}
        <div style={{ width: 720, flexShrink: 0 }}>
          <Eyebrow delay={6}>Masalah 01</Eyebrow>
          <Heading delay={16} size={62} style={{ marginTop: 26 }}>
            Stok dan nomor seri masih dicatat manual
          </Heading>
          <Lead delay={30} style={{ marginTop: 28 }}>
            Setiap unit punya nomor seri unik untuk garansi dan autentikasi.
            Tanpa satu sistem terpusat, datanya mudah kacau.
          </Lead>

          <div style={{ display: "flex", gap: 14, marginTop: 46, flexWrap: "wrap" }}>
            {CONSEQUENCES.map((item, index) => (
              <Chip key={item} delay={62 + index * 8} tone="error">
                {item}
              </Chip>
            ))}
          </div>
        </div>

        {/* ---------- manual ledger ---------- */}
        <div
          style={{
            flex: 1,
            backgroundColor: COLORS.bgCard,
            border: `1px solid ${COLORS.hairlineSoft}`,
            borderRadius: 8,
            padding: "34px 38px 30px",
            ...fadeUp(frame, 18, 34, 26),
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "baseline",
              fontFamily: FONT_SANS,
              fontSize: 18,
              letterSpacing: 3.2,
              textTransform: "uppercase",
              color: COLORS.dim,
            }}
          >
            <span>Catatan Stok</span>
            <span>Buku Manual</span>
          </div>

          <div
            style={{
              marginTop: 22,
              height: 1,
              backgroundColor: COLORS.hairlineSoft,
            }}
          />

          {ROWS.map((row, index) => {
            const delay = 30 + index * 7;
            const isFlagged = Boolean(row.duplicate);
            const borderColor = isFlagged
              ? `rgba(198,40,40,${0.12 + 0.55 * highlight})`
              : "transparent";
            const background = isFlagged
              ? `rgba(198,40,40,${0.02 + 0.11 * highlight})`
              : "transparent";

            return (
              <div
                key={`${row.serial}-${index}`}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 22,
                  padding: "20px 18px",
                  marginTop: 4,
                  borderRadius: 5,
                  border: `1px solid ${borderColor}`,
                  backgroundColor: background,
                  ...fadeUp(frame, delay, 16, 20),
                }}
              >
                <span
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 22,
                    fontWeight: 600,
                    fontVariantNumeric: "tabular-nums",
                    letterSpacing: 1.1,
                    color: isFlagged && highlight > 0.2
                      ? "#E88A8A"
                      : COLORS.cream,
                    width: 250,
                  }}
                >
                  {row.serial}
                </span>

                <span
                  style={{
                    flex: 1,
                    fontFamily: FONT_SANS,
                    fontSize: 22,
                    color: COLORS.muted,
                  }}
                >
                  {row.name}
                </span>

                <span
                  style={{
                    fontFamily: FONT_SANS,
                    fontSize: 22,
                    fontVariantNumeric: "tabular-nums",
                    color: COLORS.dim,
                    width: 46,
                    textAlign: "right",
                  }}
                >
                  {isFlagged ? jitter : row.stock}
                </span>

                {isFlagged ? (
                  <span
                    style={{
                      fontFamily: FONT_SANS,
                      fontSize: 15,
                      fontWeight: 700,
                      letterSpacing: 2,
                      color: "#F2A0A0",
                      border: "1px solid rgba(198,40,40,0.6)",
                      borderRadius: 4,
                      padding: "5px 10px",
                      opacity: badge,
                      transform: `translateX(${interpolate(badge, [0, 1], [10, 0])}px)`,
                    }}
                  >
                    DUPLIKAT
                  </span>
                ) : (
                  <span style={{ width: 96 }} />
                )}
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
