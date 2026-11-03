import type React from "react";
import { Composition } from "remotion";
import manifest from "./generated/manifest.json";
import manifestPlan from "./generated/manifest-plan.json";
import manifestFull from "./generated/manifest-full.json";
import { ChronoStoreUTS } from "./Video";
import { ChronoStoreUTSPlan } from "./PlanVideo";
import { ChronoStoreUTSFull } from "./FullVideo";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="ChronoStoreUTSFull"
        component={ChronoStoreUTSFull}
        durationInFrames={manifestFull.totalFrames}
        fps={manifestFull.fps}
        width={manifestFull.width}
        height={manifestFull.height}
      />
      <Composition
        id="ChronoStoreUTS"
        component={ChronoStoreUTS}
        durationInFrames={manifest.totalFrames}
        fps={manifest.fps}
        width={manifest.width}
        height={manifest.height}
      />
      <Composition
        id="ChronoStoreUTSPlan"
        component={ChronoStoreUTSPlan}
        durationInFrames={manifestPlan.totalFrames}
        fps={manifestPlan.fps}
        width={manifestPlan.width}
        height={manifestPlan.height}
      />
    </>
  );
};
