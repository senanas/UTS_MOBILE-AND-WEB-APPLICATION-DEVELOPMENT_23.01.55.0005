import { interpolate, spring } from "remotion";

const CLAMP = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

/** 0 -> 1 progress between two frames. */
export const progress = (
  frame: number,
  start: number,
  duration: number,
): number => interpolate(frame, [start, start + duration], [0, 1], CLAMP);

/** Fade + rise into place. Returns a style object ready to spread. */
export const fadeUp = (
  frame: number,
  delay: number,
  distance = 34,
  duration = 24,
): React.CSSProperties => {
  const p = progress(frame, delay, duration);
  return {
    opacity: p,
    transform: `translateY(${(1 - p) * distance}px)`,
  };
};

/** Fade only. */
export const fadeIn = (frame: number, delay: number, duration = 20) => ({
  opacity: progress(frame, delay, duration),
});

/** Soft spring scale-in, good for cards and chips. */
export const popIn = (
  frame: number,
  fps: number,
  delay: number,
  from = 0.94,
): React.CSSProperties => {
  const s = spring({
    frame: Math.max(0, frame - delay),
    fps,
    config: { damping: 200, mass: 0.6, stiffness: 110 },
  });
  return {
    opacity: s,
    transform: `scale(${from + (1 - from) * s})`,
  };
};

/** Horizontal slide. Negative direction slides in from the left. */
export const slideIn = (
  frame: number,
  delay: number,
  direction: 1 | -1 = 1,
  distance = 70,
  duration = 26,
): React.CSSProperties => {
  const p = progress(frame, delay, duration);
  return {
    opacity: p,
    transform: `translateX(${(1 - p) * distance * direction}px)`,
  };
};

/** Width of a rule that draws itself from the centre outwards. */
export const ruleWidth = (
  frame: number,
  delay: number,
  maxWidth: number,
  duration = 30,
): number => progress(frame, delay, duration) * maxWidth;

/** Fades a whole scene in at the head and out at the tail. */
export const sceneOpacity = (
  frame: number,
  durationInFrames: number,
  fadeInFrames = 12,
  fadeOutFrames = 14,
): number =>
  interpolate(
    frame,
    [0, fadeInFrames, durationInFrames - fadeOutFrames, durationInFrames],
    [0, 1, 1, 0],
    CLAMP,
  );
