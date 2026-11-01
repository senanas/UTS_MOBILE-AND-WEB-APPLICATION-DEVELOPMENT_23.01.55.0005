import type React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Eyebrow, Heading, Lead } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { popIn, slideIn } from "../lib/anim";

type Persona = {
  badge: string;
  initial: string;
  name: string;
  role: string;
  points: string[];
  primary: boolean;
};

const PERSONAS: Persona[] = [
  {
    badge: "Pengguna Utama",
    initial: "A",
    name: "Andi, 34 tahun",
    role: "Admin / Pemilik Toko",
    points: [
      "Mengelola puluhan unit setiap hari",
      "Butuh pencarian cepat dan akurat",
      "Butuh pengingat garansi otomatis",
    ],
    primary: true,
  },
  {
    badge: "Pengguna Sekunder",
    initial: "S",
    name: "Siti, 28 tahun",
    role: "Pelanggan",
    points: [
      "Menjelajah katalog yang tersedia",
      "Membandingkan spesifikasi mesin",
      "Memesan tanpa harus datang ke toko",
    ],
    primary: false,
  },
];

export const Scene06TargetUsers: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={50} glowY={30} />

      <AbsoluteFill style={{ padding: "92px 140px" }}>
        <div style={{ maxWidth: 1200 }}>
          <Eyebrow delay={6}>Target Pengguna</Eyebrow>
          <Heading delay={16} size={62} style={{ marginTop: 24 }}>
            Siapa yang memakai ChronoStore
          </Heading>
          <Lead delay={30} style={{ marginTop: 22, maxWidth: 980 }}>
            Satu aplikasi, dua peran yang berbeda kebutuhan.
          </Lead>
        </div>

        <div style={{ display: "flex", gap: 34, marginTop: 62 }}>
          {PERSONAS.map((persona, index) => (
            <div
              key={persona.name}
              style={{
                flex: 1,
                padding: "42px 44px 46px",
                backgroundColor: persona.primary
                  ? COLORS.bgRaised
                  : COLORS.bgCard,
                border: `1px solid ${
                  persona.primary ? COLORS.hairline : COLORS.hairlineSoft
                }`,
                borderRadius: 8,
                ...slideIn(frame, 36 + index * 14, index === 0 ? -1 : 1, 60, 28),
              }}
            >
              <div
                style={{
                  display: "inline-block",
                  padding: "8px 18px",
                  borderRadius: 4,
                  fontFamily: FONT_SANS,
                  fontSize: 16,
                  fontWeight: 700,
                  letterSpacing: 2.6,
                  textTransform: "uppercase",
                  backgroundColor: persona.primary
                    ? COLORS.gold
                    : "transparent",
                  color: persona.primary ? COLORS.bg : COLORS.gold,
                  border: persona.primary
                    ? "1px solid transparent"
                    : `1px solid ${COLORS.hairline}`,
                }}
              >
                {persona.badge}
              </div>

              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 24,
                  marginTop: 34,
                }}
              >
                <div
                  style={{
                    width: 92,
                    height: 92,
                    borderRadius: "50%",
                    border: `1px solid ${
                      persona.primary ? COLORS.gold : COLORS.hairlineSoft
                    }`,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontFamily: FONT_DISPLAY,
                    fontSize: 42,
                    fontWeight: 500,
                    color: persona.primary ? COLORS.gold : COLORS.muted,
                    flexShrink: 0,
                    ...popIn(frame, fps, 46 + index * 14),
                  }}
                >
                  {persona.initial}
                </div>

                <div>
                  <div
                    style={{
                      fontFamily: FONT_DISPLAY,
                      fontSize: 44,
                      fontWeight: 500,
                      color: COLORS.cream,
                      lineHeight: 1.15,
                    }}
                  >
                    {persona.name}
                  </div>
                  <div
                    style={{
                      marginTop: 8,
                      fontFamily: FONT_SANS,
                      fontSize: 21,
                      letterSpacing: 1.6,
                      textTransform: "uppercase",
                      color: COLORS.dim,
                    }}
                  >
                    {persona.role}
                  </div>
                </div>
              </div>

              <div
                style={{
                  marginTop: 30,
                  height: 1,
                  backgroundColor: COLORS.hairlineSoft,
                }}
              />

              <div style={{ marginTop: 26, display: "grid", gap: 16 }}>
                {persona.points.map((point) => (
                  <div
                    key={point}
                    style={{
                      display: "flex",
                      alignItems: "flex-start",
                      gap: 16,
                    }}
                  >
                    <div
                      style={{
                        width: 16,
                        height: 1,
                        backgroundColor: COLORS.gold,
                        marginTop: 15,
                        flexShrink: 0,
                      }}
                    />
                    <div
                      style={{
                        fontFamily: FONT_SANS,
                        fontSize: 24,
                        lineHeight: 1.5,
                        color: COLORS.muted,
                      }}
                    >
                      {point}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
