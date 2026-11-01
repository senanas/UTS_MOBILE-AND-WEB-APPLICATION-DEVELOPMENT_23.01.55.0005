import type React from "react";
import {
  AbsoluteFill,
  Audio,
  Sequence,
  staticFile,
  useVideoConfig,
} from "remotion";
import manifest from "./generated/manifest-plan.json";
import {
  Plan01TechStack,
  Plan02Firestore,
  Plan03DataFlow,
  Plan04Roadmap,
  Plan05Closing,
} from "./scenes/PlanScenes";
import { COLORS } from "./theme";

type SceneProps = { durationInFrames: number };

const SCENES: Record<string, React.FC<SceneProps>> = {
  techStack: Plan01TechStack,
  firestore: Plan02Firestore,
  dataFlow: Plan03DataFlow,
  roadmap: Plan04Roadmap,
  planClosing: Plan05Closing,
};

/** Bagian 6 UTS: rencana teknis, rancangan Firestore, dan penutup. */
export const ChronoStoreUTSPlan: React.FC = () => {
  const { fps } = useVideoConfig();

  let cursor = 0;
  const timeline = manifest.scenes.map((scene) => {
    const start = cursor;
    cursor += scene.durationInFrames;
    return { scene, start };
  });

  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg }}>
      {timeline.map(({ scene, start }) => {
        const Component = SCENES[scene.key];
        if (!Component) {
          return null;
        }

        const leadInFrames = Math.round(scene.leadInSeconds * fps);

        return (
          <Sequence
            key={scene.id}
            from={start}
            durationInFrames={scene.durationInFrames}
            name={scene.label}
          >
            <Component durationInFrames={scene.durationInFrames} />
            <Sequence from={leadInFrames} name={`narration-${scene.id}`}>
              <Audio src={staticFile(scene.audio)} />
            </Sequence>
          </Sequence>
        );
      })}
    </AbsoluteFill>
  );
};
