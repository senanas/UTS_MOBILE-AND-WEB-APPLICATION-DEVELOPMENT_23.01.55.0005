import type React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Eyebrow, Heading, Lead } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { fadeUp, popIn, progress } from "../lib/anim";

const PROBLEMS = [
  {
    no: "01",
    title: "Stok & Nomor Seri",
    body: "Dicatat manual di buku, rawan tercatat ganda.",
  },
  {
    no: "02",
    title: "Spesifikasi Mesin",
    body: "Data automatic, quartz, solar tersebar.",
  },
  {
    no: "03",
    title: "Servis & Garansi",
    body: "Tanpa pengingat, mudah terlewat.",
  },
];

export const Scene02ProblemOverview: React.FC<{
  durationInFrames: number;
}> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const watermark = progress(frame, 4, 46);

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={72} glowY={34} grid />

      {/* Oversized editorial numeral */}
      <div
        style={{
          position: "absolute",
          right: 90,
          top: -110,
          fontFamily: FONT_DISPLAY,
          fontSize: 620,
          fontWeight: 600,
          lineHeight: 1,
          color: "rgba(201,162,39,0.055)",
          opacity: watermark,
          transform: `translateY(${(1 - watermark) * 40}px)`,
          userSelect: "none",
        }}
      >
        03
      </div>

      <AbsoluteFill
        style={{
          padding: "0 140px",
          justifyContent: "center",
        }}
      >
        <div style={{ maxWidth: 980 }}>
          <Eyebrow delay={6}>Diagnosis</Eyebrow>
          <Heading delay={16} style={{ marginTop: 26 }}>
            Tiga masalah,
            <br />
            satu akar yang sama
          </Heading>
          <Lead delay={30} style={{ marginTop: 26, maxWidth: 780 }}>
            Operasional toko berjalan di atas pencatatan manual yang tersebar di
            banyak tempat.
          </Lead>
        </div>

        <div
          style={{
            display: "flex",
            gap: 34,
            marginTop: 76,
          }}
        >
          {PROBLEMS.map((item, index) => (
            <div
              key={item.no}
              style={{
                flex: 1,
                padding: "44px 40px 48px",
                backgroundColor: COLORS.bgCard,
                border: `1px solid ${COLORS.hairlineSoft}`,
                borderRadius: 6,
                ...popIn(frame, fps, 44 + index * 11),
              }}
            >
              <div
                style={{
                  fontFamily: FONT_DISPLAY,
                  fontSize: 46,
                  fontWeight: 500,
                  color: COLORS.gold,
                  lineHeight: 1,
                }}
              >
                {item.no}
              </div>
              <div
                style={{
                  marginTop: 26,
                  height: 1,
                  backgroundColor: COLORS.hairlineSoft,
                }}
              />
              <div
                style={{
                  marginTop: 26,
                  fontFamily: FONT_SANS,
                  fontSize: 30,
                  fontWeight: 600,
                  color: COLORS.cream,
                  letterSpacing: 0.2,
                }}
              >
                {item.title}
              </div>
              <div
                style={{
                  marginTop: 14,
                  fontFamily: FONT_SANS,
                  fontSize: 23,
                  lineHeight: 1.55,
                  color: COLORS.muted,
                }}
              >
                {item.body}
              </div>
            </div>
          ))}
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
