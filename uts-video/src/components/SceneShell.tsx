import type React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { sceneOpacity } from "../lib/anim";

/**
 * Wraps every scene so it cross-fades on the dark ground instead of
 * hard-cutting. Audio is rendered by the timeline, not here.
 */
export const SceneShell: React.FC<{
  durationInFrames: number;
  children: React.ReactNode;
}> = ({ durationInFrames, children }) => {
  const frame = useCurrentFrame();
  const opacity = sceneOpacity(frame, durationInFrames);

  return (
    <AbsoluteFill style={{ opacity }}>
      {children}
    </AbsoluteFill>
  );
};
