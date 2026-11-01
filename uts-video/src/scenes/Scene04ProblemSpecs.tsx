import type React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Chip, Eyebrow, Heading, Lead } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { fadeUp, popIn } from "../lib/anim";

const TYPES = [
  {
    label: "Automatic",
    note: "Servis 2 tahun sekali",
    left: 10,
    top: 78,
    rotate: -5,
  },
  {
    label: "Quartz",
    note: "Ganti baterai 1–2 tahun",
    left: 500,
    top: 12,
    rotate: 3.6,
  },
  {
    label: "Solar",
    note: "Cek sel surya berkala",
    left: 990,
    top: 88,
    rotate: -2.4,
  },
];

const CONSEQUENCES = [
  "Perawatan berbeda",
  "Sulit menjawab pelanggan",
  "Jadwal servis keliru",
];

export const Scene04ProblemSpecs: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={30} glowY={36} />

      <AbsoluteFill style={{ padding: "96px 140px" }}>
        <div style={{ maxWidth: 1060 }}>
          <Eyebrow delay={6}>Masalah 02</Eyebrow>
          <Heading delay={16} size={62} style={{ marginTop: 24 }}>
            Spesifikasi tipe mesin tidak terorganisir
          </Heading>
          <Lead delay={30} style={{ marginTop: 24, maxWidth: 900 }}>
            Automatic, quartz, dan solar butuh perawatan berbeda. Ketika datanya
            tersebar, admin sulit menjawab pelanggan dan menjadwalkan servis.
          </Lead>
        </div>

        {/* ---------- scattered spec cards ---------- */}
        <div
          style={{
            position: "relative",
            width: 1420,
            height: 380,
            marginTop: 52,
            marginLeft: "auto",
            marginRight: "auto",
          }}
        >
          {/* misaligned container outline */}
          <div
            style={{
              position: "absolute",
              left: -14,
              top: 6,
              width: 1448,
              height: 330,
              border: "1px dashed rgba(201,162,39,0.26)",
              borderRadius: 10,
              transform: "rotate(0.7deg)",
              ...fadeUp(frame, 26, 20, 26),
            }}
          />

          {TYPES.map((item, index) => (
            <div
              key={item.label}
              style={{
                position: "absolute",
                left: item.left,
                top: item.top,
                width: 420,
                padding: "38px 38px 40px",
                backgroundColor: COLORS.bgRaised,
                border: `1px solid ${COLORS.hairlineSoft}`,
                borderRadius: 6,
                transform: `rotate(${item.rotate}deg)`,
                boxShadow: "0 24px 60px rgba(0,0,0,0.45)",
                ...popIn(frame, fps, 34 + index * 9),
              }}
            >
              <div
                style={{
                  fontFamily: FONT_DISPLAY,
                  fontSize: 48,
                  fontWeight: 500,
                  color: COLORS.cream,
                  letterSpacing: 0.4,
                }}
              >
                {item.label}
              </div>
              <div
                style={{
                  marginTop: 18,
                  height: 1,
                  width: 60,
                  backgroundColor: COLORS.gold,
                }}
              />
              <div
                style={{
                  marginTop: 18,
                  fontFamily: FONT_SANS,
                  fontSize: 24,
                  lineHeight: 1.5,
                  color: COLORS.muted,
                }}
              >
                {item.note}
              </div>
            </div>
          ))}
        </div>

        <div
          style={{
            marginTop: 6,
            textAlign: "center",
            fontFamily: FONT_SANS,
            fontSize: 22,
            letterSpacing: 1.2,
            color: COLORS.dim,
            ...fadeUp(frame, 62, 14, 22),
          }}
        >
          Tersebar di buku, nota, dan ingatan.
        </div>

        <div
          style={{
            display: "flex",
            gap: 14,
            justifyContent: "center",
            marginTop: 26,
            flexWrap: "wrap",
          }}
        >
          {CONSEQUENCES.map((item, index) => (
            <Chip key={item} delay={70 + index * 8} tone="error">
              {item}
            </Chip>
          ))}
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
