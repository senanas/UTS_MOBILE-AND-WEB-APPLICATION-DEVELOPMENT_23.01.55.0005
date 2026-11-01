import { loadFont as loadInter } from "@remotion/google-fonts/Inter";
import { loadFont as loadPlayfair } from "@remotion/google-fonts/PlayfairDisplay";

const inter = loadInter("normal", {
  weights: ["400", "500", "600", "700"],
  subsets: ["latin"],
});

const playfair = loadPlayfair("normal", {
  weights: ["400", "500", "600", "700"],
  subsets: ["latin"],
});

/** Serif display face for headlines. Falls back gracefully if the webfont
 *  cannot be fetched at render time. */
export const FONT_DISPLAY = `${playfair.fontFamily}, Georgia, "Times New Roman", serif`;

/** Sans face for body copy and labels. */
export const FONT_SANS = `${inter.fontFamily}, "Segoe UI", system-ui, -apple-system, sans-serif`;

export const COLORS = {
  // Diselaraskan dengan design guideline Figma Minggu 4
  // (lihat docs/DESIGN_GUIDE_FIGMA.md)
  bg: "#151515",
  bgRaised: "#1B1B1B",
  bgCard: "#1F1F1F",
  gold: "#C9A227",
  goldBright: "#E8C55A",
  goldDim: "#7A6420",
  goldTint: "#2E2714",
  cream: "#FFFFFF",
  muted: "#A0A0A0",
  dim: "#6E6E6E",
  hairline: "rgba(201, 162, 39, 0.28)",
  hairlineSoft: "rgba(255, 255, 255, 0.14)",
  error: "#EF5350",
  errorSoft: "rgba(239, 83, 80, 0.16)",
  warning: "#ED8B00",
  success: "#4CAF50",
} as const;

export const SIZES = {
  eyebrow: 22,
  h1: 96,
  h2: 66,
  h3: 40,
  lead: 34,
  body: 28,
  small: 24,
  tiny: 20,
} as const;
