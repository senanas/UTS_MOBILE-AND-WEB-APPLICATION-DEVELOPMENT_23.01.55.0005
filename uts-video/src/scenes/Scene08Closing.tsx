import type React from "react";
import { AbsoluteFill, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { GoldRule, Lead } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { fadeUp } from "../lib/anim";

export const Scene08Closing: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const ring = spring({
    frame: frame - 30,
    fps,
    config: { damping: 200, mass: 1.6, stiffness: 55 },
  });

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowY={46} />

      <AbsoluteFill
        style={{
          alignItems: "center",
          justifyContent: "center",
          padding: 120,
        }}
      >
        <div
          style={{
            position: "absolute",
            width: 660,
            height: 660,
            borderRadius: "50%",
            border: "1px solid rgba(201,162,39,0.14)",
            transform: `scale(${0.9 + 0.1 * ring})`,
            opacity: ring,
          }}
        />

        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 30,
            textAlign: "center",
          }}
        >
          <GoldRule delay={4} width={80} thickness={2} />

          <Lead
            delay={12}
            size={36}
            color={COLORS.muted}
            style={{ maxWidth: 1120, letterSpacing: 0.3 }}
          >
            Dari pencatatan manual menuju satu sistem terpusat.
          </Lead>

          <h1
            style={{
              margin: 0,
              marginTop: 8,
              fontFamily: FONT_DISPLAY,
              fontSize: 132,
              fontWeight: 500,
              letterSpacing: 7,
              lineHeight: 1,
              color: COLORS.cream,
              ...fadeUp(frame, 26, 36, 32),
            }}
          >
            ChronoStore
          </h1>

          <div
            style={{
              marginTop: 10,
              fontFamily: FONT_SANS,
              fontSize: 21,
              letterSpacing: 1.2,
              color: COLORS.gold,
              ...fadeUp(frame, 46, 16, 26),
            }}
          >
            github.com/senanas/UTS_MOBILE-AND-WEB-APPLICATION-DEVELOPMENT_23.01.55.0005
          </div>

          <div
            style={{
              marginTop: 26,
              fontFamily: FONT_SANS,
              fontSize: 18,
              letterSpacing: 3.8,
              textTransform: "uppercase",
              color: COLORS.muted,
              ...fadeUp(frame, 58, 12, 24),
            }}
          >
            Maheswari Shafa Helga · 23.01.55.0005 · Kelas A1
          </div>

          <div
            style={{
              marginTop: 18,
              fontFamily: FONT_SANS,
              fontSize: 17,
              letterSpacing: 5,
              textTransform: "uppercase",
              color: COLORS.dim,
              ...fadeUp(frame, 68, 12, 24),
            }}
          >
            Terima kasih
          </div>
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
