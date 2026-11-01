import type React from "react";
import { AbsoluteFill, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { GoldRule } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { fadeUp, progress } from "../lib/anim";

export const Scene01Opening: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const ring = spring({
    frame: frame - 2,
    fps,
    config: { damping: 200, mass: 1.6, stiffness: 55 },
  });

  const settle = progress(frame, 10, 40);

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowY={44} />

      <AbsoluteFill
        style={{
          alignItems: "center",
          justifyContent: "center",
          padding: 120,
        }}
      >
        {/* Faint watch-face ring behind the wordmark */}
        <div
          style={{
            position: "absolute",
            width: 640,
            height: 640,
            borderRadius: "50%",
            border: "1px solid rgba(201,162,39,0.18)",
            transform: `scale(${0.88 + 0.12 * ring})`,
            opacity: ring * 0.9,
          }}
        />
        <div
          style={{
            position: "absolute",
            width: 780,
            height: 780,
            borderRadius: "50%",
            border: "1px solid rgba(201,162,39,0.07)",
            transform: `scale(${0.9 + 0.1 * ring})`,
            opacity: ring * 0.8,
          }}
        />

        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 30,
          }}
        >
          <GoldRule delay={6} width={90} thickness={2} />

          <h1
            style={{
              margin: 0,
              fontFamily: FONT_DISPLAY,
              fontSize: 148,
              fontWeight: 500,
              letterSpacing: 8,
              lineHeight: 1,
              color: COLORS.cream,
              ...fadeUp(frame, 12, 40, 34),
            }}
          >
            ChronoStore
          </h1>

          <div
            style={{
              fontFamily: FONT_SANS,
              fontSize: 34,
              fontWeight: 400,
              letterSpacing: 1.5,
              color: COLORS.gold,
              ...fadeUp(frame, 26, 24, 28),
            }}
          >
            Sistem Informasi Manajemen Toko Jam Tangan
          </div>

          <div
            style={{
              width: 420 * settle,
              height: 1,
              backgroundColor: COLORS.hairline,
              marginTop: 14,
            }}
          />

          <div
            style={{
              fontFamily: FONT_SANS,
              fontSize: 24,
              fontWeight: 500,
              letterSpacing: 3.5,
              textTransform: "uppercase",
              color: COLORS.muted,
              ...fadeUp(frame, 40, 18, 26),
            }}
          >
            Maheswari Shafa Helga
            <span style={{ color: COLORS.dim }}> · </span>
            23.01.55.0005
            <span style={{ color: COLORS.dim }}> · </span>
            Kelas A1
          </div>

          <div
            style={{
              fontFamily: FONT_SANS,
              fontSize: 21,
              letterSpacing: 2.4,
              textTransform: "uppercase",
              color: COLORS.dim,
              ...fadeUp(frame, 52, 14, 24),
            }}
          >
            Mobile and Web Application Development
          </div>
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
