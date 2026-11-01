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
  bg: "#12100C",
  bgRaised: "#1B1813",
  bgCard: "#211D16",
  gold: "#C9A227",
  goldBright: "#E8C55A",
  goldDim: "#7A6420",
  cream: "#F5F1E8",
  muted: "#A69E8D",
  dim: "#6B6455",
  hairline: "rgba(201, 162, 39, 0.22)",
  hairlineSoft: "rgba(245, 241, 232, 0.10)",
  error: "#C62828",
  errorSoft: "rgba(198, 40, 40, 0.16)",
  warning: "#ED8B00",
  success: "#2E7D32",
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
