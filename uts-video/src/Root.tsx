import type React from "react";
import { Composition } from "remotion";
import manifest from "./generated/manifest.json";
import { ChronoStoreUTS } from "./Video";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="ChronoStoreUTS"
      component={ChronoStoreUTS}
      durationInFrames={manifest.totalFrames}
      fps={manifest.fps}
      width={manifest.width}
      height={manifest.height}
    />
  );
};
