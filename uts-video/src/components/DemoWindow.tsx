import type React from "react";
import { AbsoluteFill, Img, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONT_SANS } from "../theme";
import { fadeUp, progress } from "../lib/anim";

type Frame = { file: string; t: number };
type Action = { t: number; kind: "move" | "click" | "type"; x: number; y: number };

export type SegmentMeta = {
  name: string;
  width: number;
  height: number;
  durationMs: number;
  frames: Frame[];
  actions: Action[];
};

/** Last frame whose timestamp is <= t (frames are sorted by time). */
const pickFrame = (frames: Frame[], t: number): Frame => {
  if (frames.length === 0) {
    return { file: "f00000.jpg", t: 0 };
  }
  let lo = 0;
  let hi = frames.length - 1;
  let best = 0;
  while (lo <= hi) {
    const mid = (lo + hi) >> 1;
    if (frames[mid].t <= t) {
      best = mid;
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }
  return frames[best];
};

/** Last action whose timestamp is <= t. */
const pickAction = (actions: Action[], t: number): Action | null => {
  let lo = 0;
  let hi = actions.length - 1;
  let best = -1;
  while (lo <= hi) {
    const mid = (lo + hi) >> 1;
    if (actions[mid].t <= t) {
      best = mid;
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }
  return best >= 0 ? actions[best] : null;
};

/** Most recent click still inside its pulse window. */
const pickPulse = (actions: Action[], t: number, windowMs = 420): Action | null => {
  for (let i = actions.length - 1; i >= 0; i -= 1) {
    if (actions[i].t > t) continue;
    if (actions[i].kind === "click" && t - actions[i].t < windowMs) return actions[i];
    if (t - actions[i].t >= windowMs) break;
  }
  return null;
};

/**
 * A real screen recording of the running app, dressed in a browser window.
 *
 * The capture is a timed JPEG sequence, not a video file, because headless
 * Chrome cannot encode one. Frames are selected by elapsed time so playback
 * speed is decoupled from the (variable) capture rate. The pointer is drawn
 * here because headless screenshots never include it.
 */
export const DemoWindow: React.FC<{
  segment: SegmentMeta;
  leadInSeconds?: number;
  caption?: string;
}> = ({ segment, leadInSeconds = 0.4, caption }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const CONTENT_W = 1337;
  const CONTENT_H = 940;
  const CHROME = 38;

  const elapsedMs = (frame / fps - leadInSeconds) * 1000;
  const clamped = Math.max(0, elapsedMs);

  const shot = pickFrame(segment.frames, clamped);
  const action = pickAction(segment.actions, clamped);
  const pulse = pickPulse(segment.actions, clamped);

  const k = CONTENT_W / 1280; // CSS px -> window px

  const cx = action ? action.x * k : 640 * k;
  const cy = action ? action.y * k : 470 * k;
  const pulseP = pulse ? progress(clamped - pulse.t, 0, 420) : 0;

  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <div
        style={{
          width: CONTENT_W,
          borderRadius: 14,
          overflow: "hidden",
          border: `1px solid ${COLORS.hairlineSoft}`,
          backgroundColor: COLORS.bgRaised,
          boxShadow: "0 40px 120px rgba(0,0,0,0.6)",
          ...fadeUp(frame, 0, 24, 16),
        }}
      >
        {/* window chrome */}
        <div
          style={{
            height: CHROME,
            display: "flex",
            alignItems: "center",
            gap: 10,
            padding: "0 18px",
            backgroundColor: COLORS.bgCard,
            borderBottom: `1px solid ${COLORS.hairlineSoft}`,
          }}
        >
          {["#EF5350", "#ED8B00", "#4CAF50"].map((c) => (
            <div
              key={c}
              style={{ width: 11, height: 11, borderRadius: "50%", backgroundColor: c, opacity: 0.7 }}
            />
          ))}
          <div
            style={{
              marginLeft: 14,
              padding: "5px 16px",
              borderRadius: 6,
              backgroundColor: "rgba(255,255,255,0.06)",
              fontFamily: FONT_SANS,
              fontSize: 14,
              letterSpacing: 0.4,
              color: COLORS.muted,
            }}
          >
            localhost:8130 — ChronoStore
          </div>
          <div style={{ flex: 1 }} />
          <div
            style={{
              fontFamily: FONT_SANS,
              fontSize: 13,
              letterSpacing: 2.4,
              textTransform: "uppercase",
              color: COLORS.dim,
            }}
          >
            {caption ?? "Chrome"}
          </div>
        </div>

        {/* captured screen */}
        <div style={{ position: "relative", width: CONTENT_W, height: CONTENT_H }}>
          <Img
            src={staticFile(`demo/${segment.name}/${shot.file}`)}
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover",
              display: "block",
            }}
          />

          {/* click pulse */}
          {pulse ? (
            <div
              style={{
                position: "absolute",
                left: cx - 26,
                top: cy - 26,
                width: 52,
                height: 52,
                borderRadius: "50%",
                border: `2px solid ${COLORS.gold}`,
                opacity: (1 - pulseP) * 0.9,
                transform: `scale(${0.5 + pulseP * 1.5})`,
              }}
            />
          ) : null}

          {/* synthetic pointer */}
          <svg
            width="26"
            height="34"
            viewBox="0 0 26 34"
            style={{
              position: "absolute",
              left: cx - 3,
              top: cy - 2,
              filter: "drop-shadow(0 3px 6px rgba(0,0,0,0.55))",
            }}
          >
            <path
              d="M2 1 L2 25 L8.6 19 L12.6 29 L17.4 27 L13.4 17.4 L22 17 Z"
              fill="#FFFFFF"
              stroke="#151515"
              strokeWidth="1.6"
              strokeLinejoin="round"
            />
          </svg>
        </div>
      </div>
    </AbsoluteFill>
  );
};
