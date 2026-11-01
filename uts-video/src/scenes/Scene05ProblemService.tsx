import type React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Chip, Eyebrow, Heading, Lead } from "../components/Type";
import { COLORS, FONT_SANS } from "../theme";
import { fadeUp, progress } from "../lib/anim";

const TICKS = [
  { at: 4, label: "Agu 2025" },
  { at: 26, label: "Feb 2026" },
  { at: 48, label: "Agu 2026" },
  { at: 70, label: "Feb 2027" },
];

const CONSEQUENCES = [
  "Garansi terlewat",
  "Hak servis hilang",
  "Pendapatan hilang",
];

export const Scene05ProblemService: React.FC<{
  durationInFrames: number;
}> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();

  const lineGrow = progress(frame, 20, 34);
  const missedZone = progress(frame, 46, 24);
  const todayIn = progress(frame, 56, 20);

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={50} glowY={38} grid />

      <AbsoluteFill style={{ padding: "96px 140px" }}>
        <div style={{ maxWidth: 1100 }}>
          <Eyebrow delay={6}>Masalah 03</Eyebrow>
          <Heading delay={16} size={62} style={{ marginTop: 24 }}>
            Riwayat servis dan garansi tidak terkelola
          </Heading>
          <Lead delay={30} style={{ marginTop: 24, maxWidth: 940 }}>
            Garansi punya masa berlaku, servis berkala harus dijadwalkan. Tanpa
            pengingat, keduanya lewat begitu saja.
          </Lead>
        </div>

        {/* ---------- timeline ---------- */}
        <div
          style={{
            position: "relative",
            width: 1560,
            height: 330,
            marginTop: 56,
            marginLeft: "auto",
            marginRight: "auto",
          }}
        >
          {/* missed window shading */}
          <div
            style={{
              position: "absolute",
              left: "48%",
              top: 102,
              width: `${18 * missedZone}%`,
              height: 72,
              background:
                "linear-gradient(90deg, rgba(198,40,40,0.20), rgba(198,40,40,0.04))",
              borderLeft: "1px solid rgba(198,40,40,0.5)",
            }}
          />

          {/* base line */}
          <div
            style={{
              position: "absolute",
              left: 0,
              top: 140,
              width: `${lineGrow * 100}%`,
              height: 2,
              backgroundColor: COLORS.hairline,
            }}
          />

          {/* ticks */}
          {TICKS.map((tick, index) => (
            <div
              key={tick.label}
              style={{
                position: "absolute",
                left: `${tick.at}%`,
                top: 118,
                width: 1,
                height: 46,
                backgroundColor: COLORS.hairlineSoft,
                opacity: lineGrow,
              }}
            >
              <div
                style={{
                  position: "absolute",
                  top: 60,
                  left: -34,
                  width: 80,
                  textAlign: "center",
                  fontFamily: FONT_SANS,
                  fontSize: 22,
                  letterSpacing: 1.6,
                  color: COLORS.dim,
                  ...fadeUp(frame, 34 + index * 5, 10, 20),
                }}
              >
                {tick.label}
              </div>
            </div>
          ))}

          {/* warranty event */}
          <div
            style={{
              position: "absolute",
              left: "48%",
              top: 66,
              display: "flex",
              flexDirection: "column",
              alignItems: "flex-start",
              ...fadeUp(frame, 44, 16, 22),
            }}
          >
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 19,
                fontWeight: 700,
                letterSpacing: 2.4,
                color: "#E88A8A",
                whiteSpace: "nowrap",
              }}
            >
              GARANSI BERAKHIR
            </div>
            <div
              style={{
                marginTop: 8,
                width: 1,
                height: 22,
                backgroundColor: "rgba(198,40,40,0.7)",
              }}
            />
            <div
              style={{
                width: 11,
                height: 11,
                borderRadius: "50%",
                backgroundColor: COLORS.error,
                marginTop: -2,
                marginLeft: -5,
              }}
            />
          </div>

          {/* service event */}
          <div
            style={{
              position: "absolute",
              left: "56%",
              top: 212,
              display: "flex",
              flexDirection: "column",
              alignItems: "flex-start",
              ...fadeUp(frame, 50, 16, 22),
            }}
          >
            <div
              style={{
                width: 9,
                height: 9,
                borderRadius: "50%",
                border: `1px solid ${COLORS.warning}`,
                marginLeft: -4,
              }}
            />
            <div
              style={{
                marginTop: 8,
                width: 1,
                height: 18,
                backgroundColor: "rgba(237,139,0,0.55)",
              }}
            />
            <div
              style={{
                fontFamily: FONT_SANS,
                fontSize: 19,
                fontWeight: 600,
                letterSpacing: 2.2,
                color: COLORS.warning,
                whiteSpace: "nowrap",
                opacity: 0.85,
              }}
            >
              SERVIS TERLEWAT
            </div>
          </div>

          {/* today marker */}
          <div
            style={{
              position: "absolute",
              left: "66%",
              top: 46,
              height: 196,
              width: 2,
              backgroundColor: COLORS.cream,
              opacity: 0.75 * todayIn,
            }}
          >
            <div
              style={{
                position: "absolute",
                top: -36,
                left: -18,
                fontFamily: FONT_SANS,
                fontSize: 19,
                fontWeight: 700,
                letterSpacing: 2.6,
                color: COLORS.cream,
                whiteSpace: "nowrap",
                opacity: todayIn,
              }}
            >
              HARI INI
            </div>
          </div>
        </div>

        <div
          style={{
            display: "flex",
            gap: 14,
            justifyContent: "center",
            marginTop: 14,
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
