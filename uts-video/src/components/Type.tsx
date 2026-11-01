import type React from "react";
import { interpolate, useCurrentFrame } from "remotion";
import { COLORS, FONT_DISPLAY, FONT_SANS, SIZES } from "../theme";
import { fadeUp, progress } from "../lib/anim";

/** Small uppercase kicker with a short gold tick before it. */
export const Eyebrow: React.FC<{
  children: React.ReactNode;
  delay?: number;
  style?: React.CSSProperties;
}> = ({ children, delay = 0, style }) => {
  const frame = useCurrentFrame();
  const tick = progress(frame, delay, 22);

  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 18,
        ...fadeUp(frame, delay, 16, 22),
        ...style,
      }}
    >
      <div
        style={{
          width: 46 * tick,
          height: 2,
          backgroundColor: COLORS.gold,
        }}
      />
      <span
        style={{
          fontFamily: FONT_SANS,
          fontSize: SIZES.eyebrow,
          fontWeight: 600,
          letterSpacing: 6,
          textTransform: "uppercase",
          color: COLORS.gold,
        }}
      >
        {children}
      </span>
    </div>
  );
};

/** Serif headline. */
export const Heading: React.FC<{
  children: React.ReactNode;
  delay?: number;
  size?: number;
  color?: string;
  style?: React.CSSProperties;
}> = ({ children, delay = 0, size = SIZES.h2, color = COLORS.cream, style }) => {
  const frame = useCurrentFrame();

  return (
    <h1
      style={{
        margin: 0,
        fontFamily: FONT_DISPLAY,
        fontSize: size,
        fontWeight: 500,
        lineHeight: 1.1,
        letterSpacing: -0.8,
        color,
        ...fadeUp(frame, delay, 28, 26),
        ...style,
      }}
    >
      {children}
    </h1>
  );
};

/** Supporting paragraph. */
export const Lead: React.FC<{
  children: React.ReactNode;
  delay?: number;
  size?: number;
  color?: string;
  style?: React.CSSProperties;
}> = ({ children, delay = 0, size = SIZES.body, color = COLORS.muted, style }) => {
  const frame = useCurrentFrame();

  return (
    <p
      style={{
        margin: 0,
        fontFamily: FONT_SANS,
        fontSize: size,
        fontWeight: 400,
        lineHeight: 1.62,
        color,
        ...fadeUp(frame, delay, 22, 24),
        ...style,
      }}
    >
      {children}
    </p>
  );
};

/** Thin gold rule that draws itself outwards from the left. */
export const GoldRule: React.FC<{
  delay?: number;
  width?: number;
  thickness?: number;
  color?: string;
}> = ({ delay = 0, width = 120, thickness = 3, color = COLORS.gold }) => {
  const frame = useCurrentFrame();
  const w = interpolate(
    progress(frame, delay, 28),
    [0, 1],
    [0, width],
  );

  return (
    <div
      style={{
        width: w,
        height: thickness,
        backgroundColor: color,
        borderRadius: thickness,
      }}
    />
  );
};

/** Outline pill used for consequences and feature lists. */
export const Chip: React.FC<{
  children: React.ReactNode;
  delay?: number;
  tone?: "default" | "error" | "gold";
}> = ({ children, delay = 0, tone = "default" }) => {
  const frame = useCurrentFrame();

  const palette = {
    default: {
      border: COLORS.hairlineSoft,
      color: COLORS.muted,
      background: "rgba(245,241,232,0.03)",
    },
    error: {
      border: "rgba(198,40,40,0.45)",
      color: "#E88A8A",
      background: COLORS.errorSoft,
    },
    gold: {
      border: COLORS.hairline,
      color: COLORS.goldBright,
      background: "rgba(201,162,39,0.08)",
    },
  }[tone];

  return (
    <div
      style={{
        padding: "16px 30px",
        border: `1px solid ${palette.border}`,
        borderRadius: 100,
        backgroundColor: palette.background,
        fontFamily: FONT_SANS,
        fontSize: SIZES.small,
        fontWeight: 500,
        color: palette.color,
        whiteSpace: "nowrap",
        ...fadeUp(frame, delay, 18, 22),
      }}
    >
      {children}
    </div>
  );
};
