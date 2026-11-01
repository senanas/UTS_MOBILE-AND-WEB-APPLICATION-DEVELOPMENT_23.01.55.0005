import type React from "react";
import { Composition } from "remotion";
import manifest from "./generated/manifest.json";
import manifestPlan from "./generated/manifest-plan.json";
import { ChronoStoreUTS } from "./Video";
import { ChronoStoreUTSPlan } from "./PlanVideo";

export const RemotionRoot: React.FC = () => {
  return (
    <>
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
