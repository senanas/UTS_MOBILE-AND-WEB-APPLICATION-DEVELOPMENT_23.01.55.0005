import type React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Eyebrow, Heading } from "../components/Type";
import { COLORS, FONT_SANS } from "../theme";
import { fadeUp, popIn } from "../lib/anim";

type Column = {
  tag: string;
  title: string;
  note: string;
  items: string[];
  tone: "must" | "should" | "wont";
};

const COLUMNS: Column[] = [
  {
    tag: "Must",
    title: "Wajib",
    note: "Inti yang membuat aplikasi berfungsi",
    items: [
      "Autentikasi pengguna",
      "Data jam tangan + validasi nomor seri unik",
      "Riwayat servis per unit",
      "Katalog untuk pelanggan",
    ],
    tone: "must",
  },
  {
    tag: "Should",
    title: "Sebaiknya",
    note: "Nilai tinggi, aplikasi tetap jalan tanpanya",
    items: ["Dashboard ringkasan", "Pengingat garansi", "Transaksi pesanan"],
    tone: "should",
  },
  {
    tag: "Won't",
    title: "Di luar UTS",
    note: "Masuk fase implementasi menuju UAS",
    items: [
      "Integrasi Firebase",
      "Pembayaran online",
      "Notifikasi WhatsApp",
    ],
    tone: "wont",
  },
];

const toneStyles = {
  must: {
    headerBg: COLORS.gold,
    headerText: COLORS.bg,
    border: COLORS.hairline,
    itemText: COLORS.cream,
    bullet: COLORS.gold,
    cardBg: COLORS.bgRaised,
  },
  should: {
    headerBg: "transparent",
    headerText: COLORS.gold,
    border: COLORS.hairline,
    itemText: COLORS.muted,
    bullet: COLORS.goldDim,
    cardBg: COLORS.bgCard,
  },
  wont: {
    headerBg: "transparent",
    headerText: COLORS.dim,
    border: COLORS.hairlineSoft,
    itemText: COLORS.dim,
    bullet: "rgba(107,100,85,0.7)",
    cardBg: "rgba(27,24,19,0.55)",
  },
} as const;

export const Scene07Scope: React.FC<{ durationInFrames: number }> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <Backdrop glowX={50} glowY={26} grid />

      <AbsoluteFill style={{ padding: "84px 140px", justifyContent: "center" }}>
        <div style={{ display: "flex", alignItems: "flex-end", gap: 40 }}>
          <div>
            <Eyebrow delay={6}>Scope</Eyebrow>
            <Heading delay={16} size={60} style={{ marginTop: 22 }}>
              Prioritas dengan MoSCoW
            </Heading>
          </div>
          <div
            style={{
              marginLeft: "auto",
              marginBottom: 10,
              fontFamily: FONT_SANS,
              fontSize: 20,
              letterSpacing: 2.4,
              textTransform: "uppercase",
              color: COLORS.dim,
              ...fadeUp(frame, 26, 12, 22),
            }}
          >
            Fase UTS
          </div>
        </div>

        <div style={{ display: "flex", gap: 28, marginTop: 54 }}>
          {COLUMNS.map((column, index) => {
            const palette = toneStyles[column.tone];

            return (
              <div
                key={column.tag}
                style={{
                  flex: 1,
                  backgroundColor: palette.cardBg,
                  border: `1px solid ${palette.border}`,
                  borderRadius: 8,
                  padding: "0 0 34px",
                  overflow: "hidden",
                  ...popIn(frame, fps, 34 + index * 12),
                }}
              >
                <div
                  style={{
                    padding: "22px 32px",
                    backgroundColor: palette.headerBg,
                    borderBottom: `1px solid ${palette.border}`,
                  }}
                >
                  <div
                    style={{
                      fontFamily: FONT_SANS,
                      fontSize: 20,
                      fontWeight: 700,
                      letterSpacing: 4,
                      textTransform: "uppercase",
                      color: palette.headerText,
                    }}
                  >
                    {column.tag}
                  </div>
                  <div
                    style={{
                      marginTop: 6,
                      fontFamily: FONT_SANS,
                      fontSize: 19,
                      color:
                        column.tone === "must"
                          ? "rgba(18,16,12,0.72)"
                          : COLORS.dim,
                    }}
                  >
                    {column.title}
                  </div>
                </div>

                <div style={{ padding: "26px 32px 0" }}>
                  <div
                    style={{
                      fontFamily: FONT_SANS,
                      fontSize: 18,
                      lineHeight: 1.5,
                      color: COLORS.dim,
                      minHeight: 54,
                    }}
                  >
                    {column.note}
                  </div>
                </div>

                <div
                  style={{
                    padding: "10px 32px 0",
                    display: "grid",
                    gap: 14,
                  }}
                >
                  {column.items.map((item, itemIndex) => (
                    <div
                      key={item}
                      style={{
                        display: "flex",
                        alignItems: "flex-start",
                        gap: 14,
                        ...fadeUp(
                          frame,
                          48 + index * 12 + itemIndex * 5,
                          10,
                          18,
                        ),
                      }}
                    >
                      <div
                        style={{
                          width: 5,
                          height: 5,
                          backgroundColor: palette.bullet,
                          marginTop: 12,
                          flexShrink: 0,
                        }}
                      />
                      <div
                        style={{
                          fontFamily: FONT_SANS,
                          fontSize: 22,
                          lineHeight: 1.45,
                          color: palette.itemText,
                        }}
                      >
                        {item}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        <div
          style={{
            marginTop: 38,
            fontFamily: FONT_SANS,
            fontSize: 20,
            letterSpacing: 0.8,
            color: COLORS.dim,
            ...fadeUp(frame, 96, 10, 20),
          }}
        >
          Fitur di luar cakupan UTS direncanakan pada Pertemuan 9–15 menuju UAS.
        </div>
      </AbsoluteFill>
    </SceneShell>
  );
};
