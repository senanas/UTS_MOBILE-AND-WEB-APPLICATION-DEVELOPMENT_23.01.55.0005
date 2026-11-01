import type React from "react";
import { AbsoluteFill } from "remotion";
import { COLORS } from "../theme";

type BackdropProps = {
  /** Horizontal position of the warm key light, in percent. */
  glowX?: number;
  glowY?: number;
  /** Adds a faint editorial grid. */
  grid?: boolean;
};

/**
 * Shared stage: warm near-black ground, a soft gold key light, and a
 * vignette that keeps the eye on the centre.
 */
export const Backdrop: React.FC<BackdropProps> = ({
  glowX = 50,
  glowY = 40,
  grid = false,
}) => {
  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg }}>
      <AbsoluteFill
        style={{
          background: `radial-gradient(1250px 820px at ${glowX}% ${glowY}%, rgba(201,162,39,0.13), rgba(201,162,39,0.04) 45%, transparent 72%)`,
        }}
      />
      {grid ? (
        <AbsoluteFill
          style={{
            opacity: 0.5,
            backgroundImage: `linear-gradient(to right, rgba(255,255,255,0.04) 1px, transparent 1px)`,
            backgroundSize: "160px 100%",
            maskImage:
              "radial-gradient(1100px 700px at 50% 45%, black, transparent 78%)",
            WebkitMaskImage:
              "radial-gradient(1100px 700px at 50% 45%, black, transparent 78%)",
          }}
        />
      ) : null}
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(1600px 1000px at 50% 118%, rgba(0,0,0,0.72), transparent 62%)",
        }}
      />
    </AbsoluteFill>
  );
};
