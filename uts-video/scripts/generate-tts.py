"""Generate Indonesian narration with edge-tts (free, no API key).

Reads scripts/script.json, produces one MP3 per scene in public/audio/,
then writes src/generated/manifest.json with precise durations derived from
the subtitle timestamps emitted by edge-tts.

Run:  python scripts/generate-tts.py
"""

from __future__ import annotations

import asyncio
import json
import re
import sys
from pathlib import Path

import edge_tts

ROOT = Path(__file__).resolve().parent.parent
SCRIPT_FILE = ROOT / "scripts" / "script.json"
AUDIO_DIR = ROOT / "public" / "audio"
GENERATED_DIR = ROOT / "src" / "generated"
MANIFEST_FILE = GENERATED_DIR / "manifest.json"

FPS = 30
WIDTH = 1920
HEIGHT = 1080

TIMESTAMP = re.compile(r"(\d{2}):(\d{2}):(\d{2})[,.](\d{3})")

# edge-tts reports offsets/durations in 100-nanosecond units.
TICKS_PER_SECOND = 10_000_000


def last_end_seconds(subtitle_path: Path) -> float:
    """Return the end time of the final subtitle cue, in seconds.

    edge-tts >= 7 writes JSON Lines (SentenceBoundary / WordBoundary events).
    Older releases and the CLI write SRT/VTT cues. Both are supported.
    """
    if not subtitle_path.exists():
        raise FileNotFoundError(f"subtitle file missing: {subtitle_path}")

    raw = subtitle_path.read_text(encoding="utf-8")

    # --- JSON Lines format -------------------------------------------------
    tick_ends: list[float] = []
    for line in raw.splitlines():
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if "offset" in event and "duration" in event:
            end_ticks = float(event["offset"]) + float(event["duration"])
            tick_ends.append(end_ticks / TICKS_PER_SECOND)

    if tick_ends:
        return max(tick_ends)

    # --- SRT / VTT cue format ---------------------------------------------
    cue_ends: list[float] = []
    for line in raw.splitlines():
        if "-->" not in line:
            continue
        match = TIMESTAMP.search(line.split("-->", 1)[1])
        if match:
            h, m, s, ms = (int(g) for g in match.groups())
            cue_ends.append(h * 3600 + m * 60 + s + ms / 1000)

    if cue_ends:
        return max(cue_ends)

    raise ValueError(f"no timings parsed from {subtitle_path}")


async def synthesize(text: str, voice: str, rate: str, pitch: str,
                     mp3_path: Path, vtt_path: Path) -> None:
    """Render one scene, retrying a few times for network hiccups."""
    last_error: Exception | None = None
    for attempt in range(1, 4):
        try:
            communicate = edge_tts.Communicate(
                text, voice, rate=rate, pitch=pitch
            )
            await communicate.save(str(mp3_path), str(vtt_path))
            if mp3_path.exists() and mp3_path.stat().st_size > 1024:
                return
            raise RuntimeError("audio file too small or missing")
        except Exception as exc:  # noqa: BLE001 - retry any transport error
            last_error = exc
            print(f"    attempt {attempt} failed: {exc}", flush=True)
            await asyncio.sleep(1.5 * attempt)

    raise RuntimeError(f"TTS failed after 3 attempts: {last_error}")


async def main() -> int:
    config = json.loads(SCRIPT_FILE.read_text(encoding="utf-8"))
    voice = config["voice"]
    rate = config.get("rate", "+0%")
    pitch = config.get("pitch", "+0Hz")
    lead_in = float(config.get("leadInSeconds", 0.4))
    tail_out = float(config.get("tailOutSeconds", 0.55))

    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)

    print(f"voice  : {voice}")
    print(f"rate   : {rate}")
    print(f"scenes : {len(config['scenes'])}\n")

    manifest_scenes: list[dict] = []
    total_seconds = 0.0

    for index, scene in enumerate(config["scenes"], start=1):
        scene_id = scene["id"]
        mp3_path = AUDIO_DIR / f"{scene_id}.mp3"
        vtt_path = AUDIO_DIR / f"{scene_id}.vtt"

        print(f"[{index}/{len(config['scenes'])}] {scene_id} — {scene['label']}")

        await synthesize(
            scene["text"], voice, rate, pitch, mp3_path, vtt_path
        )

        audio_seconds = last_end_seconds(vtt_path)
        scene_seconds = lead_in + audio_seconds + tail_out
        frames = round(scene_seconds * FPS)

        manifest_scenes.append(
            {
                "id": scene_id,
                "key": scene["key"],
                "label": scene["label"],
                "narration": scene["text"],
                "audio": f"audio/{scene_id}.mp3",
                "audioSeconds": round(audio_seconds, 3),
                "leadInSeconds": lead_in,
                "durationInSeconds": round(scene_seconds, 3),
                "durationInFrames": frames,
            }
        )
        total_seconds += scene_seconds
        print(
            f"    audio {audio_seconds:6.2f}s  ->  scene {scene_seconds:6.2f}s "
            f"({frames} frames)"
        )

    manifest = {
        "fps": FPS,
        "width": WIDTH,
        "height": HEIGHT,
        "voice": voice,
        "rate": rate,
        "totalSeconds": round(total_seconds, 3),
        "totalFrames": sum(s["durationInFrames"] for s in manifest_scenes),
        "scenes": manifest_scenes,
    }

    MANIFEST_FILE.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    minutes = int(total_seconds // 60)
    seconds = total_seconds - minutes * 60
    print(
        f"\nDone. {manifest['totalFrames']} frames "
        f"({minutes}:{seconds:05.2f}) -> {MANIFEST_FILE.relative_to(ROOT)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
