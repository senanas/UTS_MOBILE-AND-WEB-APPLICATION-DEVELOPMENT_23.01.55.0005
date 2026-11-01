import type React from "react";
import {
  AbsoluteFill,
  Audio,
  Sequence,
  staticFile,
  useVideoConfig,
} from "remotion";
import manifest from "./generated/manifest.json";
import { Scene01Opening } from "./scenes/Scene01Opening";
import { Scene02ProblemOverview } from "./scenes/Scene02ProblemOverview";
import { Scene03ProblemSerial } from "./scenes/Scene03ProblemSerial";
import { Scene04ProblemSpecs } from "./scenes/Scene04ProblemSpecs";
import { Scene05ProblemService } from "./scenes/Scene05ProblemService";
import { Scene06TargetUsers } from "./scenes/Scene06TargetUsers";
import { Scene07Scope } from "./scenes/Scene07Scope";
import { Scene08Closing } from "./scenes/Scene08Closing";
import { COLORS } from "./theme";

type SceneProps = { durationInFrames: number };

const SCENES: Record<string, React.FC<SceneProps>> = {
  opening: Scene01Opening,
  problemOverview: Scene02ProblemOverview,
  problemSerial: Scene03ProblemSerial,
  problemSpecs: Scene04ProblemSpecs,
  problemService: Scene05ProblemService,
  targetUsers: Scene06TargetUsers,
  scope: Scene07Scope,
  closing: Scene08Closing,
};

export const ChronoStoreUTS: React.FC = () => {
  const { fps } = useVideoConfig();

  // Scene start offsets are derived from the durations measured by edge-tts,
  // so picture and narration can never drift apart.
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
