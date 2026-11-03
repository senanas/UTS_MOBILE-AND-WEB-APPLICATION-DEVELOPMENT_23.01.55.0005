import type React from "react";
import {
  AbsoluteFill,
  Audio,
  Sequence,
  staticFile,
  useVideoConfig,
} from "remotion";
import manifest from "./generated/manifest-full.json";
import {
  Flow,
  FullClosing,
  Moscow,
  Opening,
  Persona,
  Problem,
  Sitemap,
  Stories,
  Why,
  Wireframe,
} from "./scenes/FullScenes";
import {
  DemoLogin,
  DemoDashboard,
  DemoList,
  DemoForm,
  DemoDetail,
} from "./scenes/DemoScenes";
import { Plan01TechStack, Plan02Firestore, Plan03DataFlow, Plan04Roadmap } from "./scenes/PlanScenes";
import { COLORS } from "./theme";

type SceneProps = { durationInFrames: number };

/** Narrative scenes: one component per manifest `key`. */
const SCENES: Record<string, React.FC<SceneProps>> = {
  opening: Opening,
  problem: Problem,
  why: Why,
  persona: Persona,
  stories: Stories,
  moscow: Moscow,
  flow: Flow,
  sitemap: Sitemap,
  wireframe: Wireframe,
  // Demo scenes — animated UI mockups (no screen recording needed)
  demoLogin: DemoLogin,
  demoDashboard: DemoDashboard,
  demoList: DemoList,
  demoForm: DemoForm,
  demoDetail: DemoDetail,
  // Bagian 6 reuses the technical slides built for the earlier video.
  stack: Plan01TechStack,
  firestore: Plan02Firestore,
  dataFlow: Plan03DataFlow,
  roadmap: Plan04Roadmap,
  closing: FullClosing,
};

/** Full UTS video — covers all 6 parts from the Brief:
 *  1. Pembuka
 *  2. Masalah & Pengguna
 *  3. Kebutuhan & Prioritas
 *  4. Rancangan (user flow, sitemap, wireframe)
 *  5. Demo Prototype (animated UI mockups)
 *  6. Rencana Teknis & Penutup
 */
export const ChronoStoreUTSFull: React.FC = () => {
  const { fps } = useVideoConfig();

  // Scene start offsets come from the durations measured by edge-tts,
  // so picture and narration stay in lock-step no matter how the script
  // is edited.
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
