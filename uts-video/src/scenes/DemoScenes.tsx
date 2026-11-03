import type React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig, interpolate } from "remotion";
import { Backdrop } from "../components/Backdrop";
import { SceneShell } from "../components/SceneShell";
import { Eyebrow, Heading } from "../components/Type";
import { COLORS, FONT_DISPLAY, FONT_SANS } from "../theme";
import { fadeUp, progress } from "../lib/anim";

/* =========================================================== */
/* Shared Chrome browser frame                                  */
/* =========================================================== */

const BrowserFrame: React.FC<{
  children: React.ReactNode;
  caption?: string;
}> = ({ children, caption = "localhost:8130 — ChronoStore" }) => {
  const frame = useCurrentFrame();
  const CHROME = 34;
  const W = 1240;
  const H = 800;

  return (
    <div
      style={{
        width: W,
        height: H,
        borderRadius: 14,
        overflow: "hidden",
        border: `1px solid ${COLORS.hairlineSoft}`,
        backgroundColor: COLORS.bg,
        boxShadow: "0 40px 120px rgba(0,0,0,0.6)",
        ...fadeUp(frame, 0, 24, 16),
      }}
    >
      {/* window chrome */}
      <div
        style={{
          height: CHROME,
          display: "flex",
          alignItems: "center",
          gap: 10,
          padding: "0 18px",
          backgroundColor: COLORS.bgCard,
          borderBottom: `1px solid ${COLORS.hairlineSoft}`,
          flexShrink: 0,
        }}
      >
        {["#EF5350", "#ED8B00", "#4CAF50"].map((c) => (
          <div
            key={c}
            style={{ width: 11, height: 11, borderRadius: "50%", backgroundColor: c, opacity: 0.7 }}
          />
        ))}
        <div
          style={{
            marginLeft: 14,
            padding: "5px 16px",
            borderRadius: 6,
            backgroundColor: "rgba(255,255,255,0.06)",
            fontFamily: FONT_SANS,
            fontSize: 13,
            letterSpacing: 0.4,
            color: COLORS.muted,
          }}
        >
          {caption}
        </div>
      </div>
      {/* screen content */}
      <div style={{ position: "relative", width: "100%", height: H - CHROME }}>
        {children}
      </div>
    </div>
  );
};

/** Stage wrapper: fixed header band + browser window below it. */
const DemoStage: React.FC<{
  eyebrow: string;
  title: string;
  children: React.ReactNode;
  glowX?: number;
}> = ({ eyebrow, title, children, glowX = 50 }) => {
  return (
    <AbsoluteFill style={{ padding: "48px 120px 56px", flexDirection: "column" }}>
      <Backdrop glowX={glowX} glowY={26} />
      <div style={{ flexShrink: 0, marginBottom: 22 }}>
        <Eyebrow delay={4}>{eyebrow}</Eyebrow>
        <Heading delay={12} size={46} style={{ marginTop: 12 }}>
          {title}
        </Heading>
      </div>
      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
        {children}
      </div>
    </AbsoluteFill>
  );
};

/* Shared app colors - matching Flutter theme.dart */
const APP = {
  bg: "#151515",
  surface: "#1B1B1B",
  surfaceAlt: "#1F1F1F",
  border: "#4A4A4A",
  gold: "#C9A227",
  white: "#FFFFFF",
  secondary: "#A0A0A0",
  hint: "#6E6E6E",
  error: "#EF5350",
  success: "#4CAF50",
  warning: "#ED8B00",
};

/* =========================================================== */
/* Demo 1 — Login Screen                                        */
/* =========================================================== */

export const DemoLogin: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Timeline phases
  // Phase 0: empty form (0-30)
  // Phase 1: click submit with empty email -> error (30-60)
  // Phase 2: type wrong format email -> error (60-90)
  // Phase 3: type correct email + password (90-120)
  // Phase 4: click login -> success transition (120-end)

  const phase = (f: number) => {
    if (f < 30) return 0;
    if (f < 70) return 1;
    if (f < 110) return 2;
    if (f < 150) return 3;
    return 4;
  };

  const p = phase(frame);
  const emailError = p === 1 ? "Email wajib diisi" : p === 2 ? "Format email tidak valid" : "";
  const showEmail = p >= 3;
  const showPassword = p >= 3;
  const loginSuccess = p >= 4;
  const successP = loginSuccess ? progress(frame - 150, 0, 20) : 0;

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <DemoStage eyebrow="Bagian 5 — Demo Prototype" title="Login &amp; Validasi">
        <BrowserFrame>
          {/* App content */}
          <div
            style={{
              position: "absolute",
              inset: 0,
              backgroundColor: APP.bg,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              gap: 24,
              opacity: 1 - successP,
            }}
          >
            {/* Logo circle */}
            <div
              style={{
                width: 64,
                height: 64,
                borderRadius: "50%",
                border: `2px solid ${APP.gold}`,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontFamily: FONT_DISPLAY,
                fontSize: 28,
                fontWeight: 600,
                color: APP.gold,
                ...fadeUp(frame, 8, 20, 18),
              }}
            >
              C
            </div>
            {/* Wordmark */}
            <div
              style={{
                fontFamily: FONT_DISPLAY,
                fontSize: 32,
                fontWeight: 600,
                color: APP.white,
                letterSpacing: 2,
                ...fadeUp(frame, 14, 20, 18),
              }}
            >
              ChronoStore
            </div>

            {/* Email field */}
            <div style={{ width: 360, ...fadeUp(frame, 20, 20, 18) }}>
              <div
                style={{
                  padding: "12px 16px",
                  borderRadius: 8,
                  backgroundColor: APP.surface,
                  border: `1px solid ${emailError ? APP.error : APP.border}`,
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                }}
              >
                <span style={{ fontSize: 18, color: APP.secondary }}>@</span>
                <span style={{ fontFamily: FONT_SANS, fontSize: 17, color: showEmail ? APP.white : APP.hint }}>
                  {showEmail ? (p === 3 ? "admin@chronostore.id" : "salah") : "Email"}
                </span>
              </div>
              {emailError ? (
                <div
                  style={{
                    marginTop: 6,
                    fontFamily: FONT_SANS,
                    fontSize: 13,
                    color: APP.error,
                    ...fadeUp(frame, p === 1 ? 32 : 72, 10, 14),
                  }}
                >
                  {emailError}
                </div>
              ) : null}
            </div>

            {/* Password field */}
            <div style={{ width: 360, ...fadeUp(frame, 26, 20, 18) }}>
              <div
                style={{
                  padding: "12px 16px",
                  borderRadius: 8,
                  backgroundColor: APP.surface,
                  border: `1px solid ${APP.border}`,
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                }}
              >
                <span style={{ fontSize: 16, color: APP.secondary }}>🔒</span>
                <span style={{ fontFamily: FONT_SANS, fontSize: 17, color: showPassword ? APP.white : APP.hint }}>
                  {showPassword ? "••••••••" : "Kata Sandi"}
                </span>
              </div>
            </div>

            {/* Login button */}
            <div
              style={{
                width: 360,
                height: 48,
                borderRadius: 8,
                backgroundColor: APP.gold,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontFamily: FONT_SANS,
                fontSize: 18,
                fontWeight: 600,
                color: APP.bg,
                ...fadeUp(frame, 32, 20, 18),
              }}
            >
              Masuk
            </div>
          </div>

          {/* Success overlay */}
          {loginSuccess ? (
            <div
              style={{
                position: "absolute",
                inset: 0,
                backgroundColor: APP.bg,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                justifyContent: "center",
                gap: 16,
                opacity: successP,
              }}
            >
              <div style={{ fontSize: 48, color: APP.success }}>✓</div>
              <div style={{ fontFamily: FONT_SANS, fontSize: 22, color: APP.white }}>
                Login berhasil
              </div>
              <div style={{ fontFamily: FONT_SANS, fontSize: 16, color: APP.secondary }}>
                Memuat dashboard...
              </div>
            </div>
          ) : null}
        </BrowserFrame>
        </DemoStage>
    </SceneShell>
  );
};

/* =========================================================== */
/* Demo 2 — Dashboard                                           */
/* =========================================================== */

const DASH_STATS = [
  { label: "Total Jam", value: "6", accent: true },
  { label: "Total Stok", value: "34" },
  { label: "Garansi Aktif", value: "4" },
  { label: "Stok Habis", value: "1" },
];

const REMINDERS = [
  { name: "Citizen Eco-Drive", type: "Garansi berakhir", date: "28 Okt 2026", tone: "error" },
  { name: "Casio Edifice", type: "Garansi berakhir", date: "5 Nov 2026", tone: "warning" },
  { name: "Seiko 5 Sports", type: "Servis terjadwal", date: "1 Sep 2027", tone: "ok" },
];

const NAV_ITEMS = [
  { label: "Dashboard", active: true },
  { label: "Data Jam", active: false },
  { label: "Pengingat", active: false },
];

export const DemoDashboard: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <DemoStage eyebrow="Demo Prototype" title="Dashboard Admin" glowX={40}>
        <BrowserFrame>
          <div style={{ position: "absolute", inset: 0, backgroundColor: APP.bg, display: "flex" }}>
            {/* Navigation Rail */}
            <div
              style={{
                width: 64,
                backgroundColor: APP.bg,
                borderRight: `1px solid ${APP.border}`,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                paddingTop: 20,
                gap: 28,
                ...fadeUp(frame, 10, 20, 18),
              }}
            >
              {/* Logo */}
              <div
                style={{
                  width: 36,
                  height: 36,
                  borderRadius: "50%",
                  border: `1.5px solid ${APP.gold}`,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontFamily: FONT_DISPLAY,
                  fontSize: 16,
                  fontWeight: 600,
                  color: APP.gold,
                }}
              >
                C
              </div>
              {NAV_ITEMS.map((item, i) => (
                <div
                  key={item.label}
                  style={{
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    gap: 4,
                    ...fadeUp(frame, 16 + i * 6, 16, 14),
                  }}
                >
                  <div
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 8,
                      backgroundColor: item.active ? `rgba(201,162,39,0.15)` : "transparent",
                      border: item.active ? `1px solid ${APP.gold}` : "1px solid transparent",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 16,
                      color: item.active ? APP.gold : APP.secondary,
                    }}
                  >
                    {["◆", "☰", "🔔"][i]}
                  </div>
                  <div
                    style={{
                      fontFamily: FONT_SANS,
                      fontSize: 9,
                      color: item.active ? APP.gold : APP.hint,
                      letterSpacing: 0.3,
                    }}
                  >
                    {item.label}
                  </div>
                </div>
              ))}
            </div>

            {/* Main content */}
            <div style={{ flex: 1, padding: "28px 32px", overflow: "hidden" }}>
              {/* Title */}
              <div
                style={{
                  fontFamily: FONT_SANS,
                  fontSize: 22,
                  fontWeight: 600,
                  color: APP.white,
                  ...fadeUp(frame, 20, 18, 16),
                }}
              >
                Selamat Datang, Admin
              </div>
              <div
                style={{
                  fontFamily: FONT_SANS,
                  fontSize: 14,
                  color: APP.secondary,
                  marginTop: 4,
                  ...fadeUp(frame, 24, 18, 16),
                }}
              >
                Ringkasan toko jam tangan
              </div>

              {/* Stats grid */}
              <div style={{ display: "flex", gap: 16, marginTop: 24 }}>
                {DASH_STATS.map((stat, i) => (
                  <div
                    key={stat.label}
                    style={{
                      flex: 1,
                      padding: "20px 22px",
                      borderRadius: 12,
                      backgroundColor: stat.accent ? `rgba(201,162,39,0.08)` : APP.surface,
                      border: `1px solid ${stat.accent ? `rgba(201,162,39,0.3)` : APP.border}`,
                      ...fadeUp(frame, 30 + i * 8, 18, 16),
                    }}
                  >
                    <div
                      style={{
                        fontFamily: FONT_SANS,
                        fontSize: 12,
                        fontWeight: 500,
                        color: APP.secondary,
                        letterSpacing: 0.5,
                      }}
                    >
                      {stat.label}
                    </div>
                    <div
                      style={{
                        fontFamily: FONT_DISPLAY,
                        fontSize: 36,
                        fontWeight: 600,
                        color: stat.accent ? APP.gold : APP.white,
                        marginTop: 8,
                        lineHeight: 1,
                      }}
                    >
                      {stat.value}
                    </div>
                  </div>
                ))}
              </div>

              {/* Quick actions */}
              <div style={{ display: "flex", gap: 12, marginTop: 24 }}>
                <div
                  style={{
                    padding: "12px 20px",
                    borderRadius: 8,
                    backgroundColor: APP.gold,
                    fontFamily: FONT_SANS,
                    fontSize: 15,
                    fontWeight: 600,
                    color: APP.bg,
                    ...fadeUp(frame, 60, 16, 14),
                  }}
                >
                  + Tambah Jam
                </div>
                <div
                  style={{
                    padding: "12px 20px",
                    borderRadius: 8,
                    border: `1px solid ${APP.border}`,
                    fontFamily: FONT_SANS,
                    fontSize: 15,
                    fontWeight: 500,
                    color: APP.white,
                    ...fadeUp(frame, 66, 16, 14),
                  }}
                >
                  Transaksi
                </div>
              </div>

              {/* Reminders */}
              <div
                style={{
                  marginTop: 28,
                  fontFamily: FONT_SANS,
                  fontSize: 16,
                  fontWeight: 600,
                  color: APP.white,
                  ...fadeUp(frame, 72, 16, 14),
                }}
              >
                Pengingat Servis Terdekat
              </div>
              <div style={{ marginTop: 12, display: "grid", gap: 10 }}>
                {REMINDERS.map((r, i) => {
                  const toneColor = r.tone === "error" ? APP.error : r.tone === "warning" ? APP.warning : APP.success;
                  return (
                    <div
                      key={r.name}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: 16,
                        padding: "14px 18px",
                        borderRadius: 8,
                        backgroundColor: APP.surface,
                        border: `1px solid ${APP.border}`,
                        ...fadeUp(frame, 78 + i * 8, 16, 14),
                      }}
                    >
                      <div
                        style={{
                          width: 8,
                          height: 8,
                          borderRadius: "50%",
                          backgroundColor: toneColor,
                          flexShrink: 0,
                        }}
                      />
                      <div style={{ flex: 1 }}>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 15, fontWeight: 500, color: APP.white }}>
                          {r.name}
                        </div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 12, color: APP.secondary, marginTop: 2 }}>
                          {r.type}
                        </div>
                      </div>
                      <div style={{ fontFamily: FONT_SANS, fontSize: 13, color: APP.secondary }}>
                        {r.date}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </BrowserFrame>
        </DemoStage>
    </SceneShell>
  );
};

/* =========================================================== */
/* Demo 3 — Data Jam Tangan (List + Search + Filter)            */
/* =========================================================== */

const WATCHES = [
  { name: "Seiko 5 Sports", brand: "Seiko", type: "Automatic", price: "3.500.000", stock: 5, serial: "SK-SRPD65-001" },
  { name: "Casio G-Shock", brand: "Casio", type: "Quartz", price: "1.800.000", stock: 8, serial: "CS-GA2100-002" },
  { name: "Citizen Eco-Drive", brand: "Citizen", type: "Solar", price: "4.200.000", stock: 0, serial: "CZ-AW0040-003" },
  { name: "Timex Expedition", brand: "Timex", type: "Quartz", price: "750.000", stock: 12, serial: "TX-TW4B195-004" },
  { name: "Orient Bambino", brand: "Orient", type: "Automatic", price: "2.800.000", stock: 3, serial: "OR-AC0000-005" },
  { name: "Casio Edifice", brand: "Casio", type: "Quartz", price: "2.200.000", stock: 6, serial: "CS-EFRS108-006" },
];

export const DemoList: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();

  // Phase 0: all watches (0-40)
  // Phase 1: search "Casio" -> filtered (40-80)
  // Phase 2: filter Automatic (80-120)
  // Phase 3: search "zzz" -> empty state (120-end)
  const p = frame < 40 ? 0 : frame < 80 ? 1 : frame < 120 ? 2 : 3;

  let displayed = WATCHES;
  let searchText = "";
  let activeFilter = "";

  if (p === 1) {
    displayed = WATCHES.filter((w) => w.brand === "Casio");
    searchText = "Casio";
  } else if (p === 2) {
    displayed = WATCHES.filter((w) => w.type === "Automatic");
    activeFilter = "Automatic";
  } else if (p === 3) {
    displayed = [];
    searchText = "zzz";
  }

  const FILTERS = ["Semua", "Automatic", "Quartz", "Solar"];

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <DemoStage eyebrow="Demo Prototype" title="Data Jam Tangan" glowX={44}>
        <BrowserFrame>
          <div style={{ position: "absolute", inset: 0, backgroundColor: APP.bg, display: "flex" }}>
            {/* Nav rail */}
            <div
              style={{
                width: 64,
                backgroundColor: APP.bg,
                borderRight: `1px solid ${APP.border}`,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                paddingTop: 20,
                gap: 28,
                ...fadeUp(frame, 8, 16, 14),
              }}
            >
              <div
                style={{
                  width: 36,
                  height: 36,
                  borderRadius: "50%",
                  border: `1.5px solid ${APP.gold}`,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontFamily: FONT_DISPLAY,
                  fontSize: 16,
                  fontWeight: 600,
                  color: APP.gold,
                }}
              >
                C
              </div>
              {[
                { label: "Dashboard", active: false },
                { label: "Data Jam", active: true },
                { label: "Pengingat", active: false },
              ].map((item, i) => (
                <div key={item.label} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}>
                  <div
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 8,
                      backgroundColor: item.active ? `rgba(201,162,39,0.15)` : "transparent",
                      border: item.active ? `1px solid ${APP.gold}` : "1px solid transparent",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 16,
                      color: item.active ? APP.gold : APP.secondary,
                    }}
                  >
                    {["◆", "☰", "🔔"][i]}
                  </div>
                  <div
                    style={{
                      fontFamily: FONT_SANS,
                      fontSize: 9,
                      color: item.active ? APP.gold : APP.hint,
                    }}
                  >
                    {item.label}
                  </div>
                </div>
              ))}
            </div>

            {/* Main content */}
            <div style={{ flex: 1, padding: "28px 32px", overflow: "hidden" }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  ...fadeUp(frame, 14, 16, 14),
                }}
              >
                <div style={{ fontFamily: FONT_SANS, fontSize: 22, fontWeight: 600, color: APP.white }}>
                  Data Jam Tangan
                </div>
                <div
                  style={{
                    width: 44,
                    height: 44,
                    borderRadius: "50%",
                    backgroundColor: APP.gold,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 22,
                    fontWeight: 700,
                    color: APP.bg,
                  }}
                >
                  +
                </div>
              </div>

              {/* Search bar */}
              <div
                style={{
                  marginTop: 20,
                  padding: "12px 18px",
                  borderRadius: 24,
                  backgroundColor: APP.surface,
                  border: `1px solid ${APP.border}`,
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                  ...fadeUp(frame, 20, 16, 14),
                }}
              >
                <span style={{ fontSize: 16, color: APP.hint }}>🔍</span>
                <span style={{ fontFamily: FONT_SANS, fontSize: 15, color: searchText ? APP.white : APP.hint }}>
                  {searchText || "Cari nama atau merek..."}
                </span>
              </div>

              {/* Filter chips */}
              <div style={{ display: "flex", gap: 10, marginTop: 14 }}>
                {FILTERS.map((f, i) => {
                  const isActive = (f === "Semua" && !activeFilter) || f === activeFilter;
                  return (
                    <div
                      key={f}
                      style={{
                        padding: "8px 18px",
                        borderRadius: 20,
                        backgroundColor: isActive ? `rgba(201,162,39,0.15)` : APP.surface,
                        border: `1px solid ${isActive ? APP.gold : APP.border}`,
                        fontFamily: FONT_SANS,
                        fontSize: 13,
                        fontWeight: 500,
                        color: isActive ? APP.gold : APP.secondary,
                        ...fadeUp(frame, 26 + i * 4, 14, 12),
                      }}
                    >
                      {f}
                    </div>
                  );
                })}
              </div>

              {/* Watch list or empty state */}
              {displayed.length > 0 ? (
                <div style={{ marginTop: 18, display: "grid", gap: 10 }}>
                  {displayed.map((w, i) => (
                    <div
                      key={w.serial}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: 16,
                        padding: "16px 20px",
                        borderRadius: 10,
                        backgroundColor: APP.surface,
                        border: `1px solid ${APP.border}`,
                        ...fadeUp(frame, 40 + i * 6, 14, 12),
                      }}
                    >
                      {/* Watch icon */}
                      <div
                        style={{
                          width: 48,
                          height: 48,
                          borderRadius: 8,
                          backgroundColor: APP.surfaceAlt,
                          border: `1px solid ${APP.border}`,
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          fontSize: 22,
                          flexShrink: 0,
                        }}
                      >
                        ⌚
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 16, fontWeight: 600, color: APP.white }}>
                          {w.name}
                        </div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 12, color: APP.secondary, marginTop: 3 }}>
                          {w.brand} · {w.type} · {w.serial}
                        </div>
                      </div>
                      <div style={{ textAlign: "right" }}>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 15, fontWeight: 600, color: APP.gold }}>
                          Rp {w.price}
                        </div>
                        <div
                          style={{
                            fontFamily: FONT_SANS,
                            fontSize: 12,
                            color: w.stock === 0 ? APP.error : APP.secondary,
                            marginTop: 2,
                          }}
                        >
                          Stok: {w.stock}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                /* Empty state */
                <div
                  style={{
                    marginTop: 60,
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    gap: 16,
                    ...fadeUp(frame, 40, 18, 16),
                  }}
                >
                  <div style={{ fontSize: 56, opacity: 0.3 }}>📭</div>
                  <div style={{ fontFamily: FONT_SANS, fontSize: 18, fontWeight: 600, color: APP.white }}>
                    Tidak ada data jam tangan
                  </div>
                  <div style={{ fontFamily: FONT_SANS, fontSize: 14, color: APP.secondary }}>
                    Coba ubah kata kunci atau filter
                  </div>
                  <div
                    style={{
                      marginTop: 8,
                      padding: "10px 24px",
                      borderRadius: 8,
                      backgroundColor: APP.gold,
                      fontFamily: FONT_SANS,
                      fontSize: 14,
                      fontWeight: 600,
                      color: APP.bg,
                    }}
                  >
                    Kembali ke Dashboard
                  </div>
                </div>
              )}
            </div>
          </div>
        </BrowserFrame>
        </DemoStage>
    </SceneShell>
  );
};

/* =========================================================== */
/* Demo 4 — Form & Validasi                                     */
/* =========================================================== */

const FORM_FIELDS = [
  { label: "Nama Jam Tangan", icon: "⌚", value: "Rolex Submariner", error: "" },
  { label: "Merek", icon: "🏷", value: "Rolex", error: "" },
  { label: "Model", icon: "#", value: "126610LN", error: "" },
];

export const DemoForm: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Phase 0: form filling (0-60)
  // Phase 1: serial number duplicate error (60-100)
  // Phase 2: price = 0 error (100-130)
  // Phase 3: stock negative error (130-160)
  // Phase 4: success - snackbar (160-end)

  const p = frame < 60 ? 0 : frame < 100 ? 1 : frame < 130 ? 2 : frame < 160 ? 3 : 4;
  const fields = [...FORM_FIELDS];

  const serialError = p === 1 ? "Nomor seri sudah digunakan" : "";
  const priceError = p === 2 ? "Harga harus lebih dari 0" : "";
  const stockError = p === 3 ? "Stok tidak boleh negatif" : "";
  const showSuccess = p === 4;
  const successP = showSuccess ? progress(frame - 160, 0, 20) : 0;

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <DemoStage eyebrow="Demo Prototype" title="Form &amp; Validasi" glowX={36}>
        <BrowserFrame>
          <div style={{ position: "absolute", inset: 0, backgroundColor: APP.bg, display: "flex" }}>
            {/* Nav rail */}
            <div
              style={{
                width: 64,
                backgroundColor: APP.bg,
                borderRight: `1px solid ${APP.border}`,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                paddingTop: 20,
                gap: 28,
                ...fadeUp(frame, 8, 16, 14),
              }}
            >
              <div
                style={{
                  width: 36, height: 36, borderRadius: "50%",
                  border: `1.5px solid ${APP.gold}`,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontFamily: FONT_DISPLAY, fontSize: 16, fontWeight: 600, color: APP.gold,
                }}
              >C</div>
              {[
                { label: "Dashboard", active: false },
                { label: "Data Jam", active: true },
                { label: "Pengingat", active: false },
              ].map((item, i) => (
                <div key={item.label} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}>
                  <div
                    style={{
                      width: 36, height: 36, borderRadius: 8,
                      backgroundColor: item.active ? `rgba(201,162,39,0.15)` : "transparent",
                      border: item.active ? `1px solid ${APP.gold}` : "1px solid transparent",
                      display: "flex", alignItems: "center", justifyContent: "center",
                      fontSize: 16, color: item.active ? APP.gold : APP.secondary,
                    }}
                  >{["◆", "☰", "🔔"][i]}</div>
                  <div style={{ fontFamily: FONT_SANS, fontSize: 9, color: item.active ? APP.gold : APP.hint }}>{item.label}</div>
                </div>
              ))}
            </div>

            {/* Form content */}
            <div style={{ flex: 1, padding: "24px 32px", overflowY: "hidden" }}>
              <div style={{ fontFamily: FONT_SANS, fontSize: 20, fontWeight: 600, color: APP.white, ...fadeUp(frame, 12, 14, 12) }}>
                Tambah Jam Tangan
              </div>

              {/* Form fields */}
              <div style={{ marginTop: 16, display: "grid", gap: 14, maxWidth: 640 }}>
                {fields.map((f, i) => (
                  <div key={f.label} style={{ ...fadeUp(frame, 18 + i * 6, 14, 12) }}>
                    <div
                      style={{
                        padding: "12px 16px",
                        borderRadius: 8,
                        backgroundColor: APP.surface,
                        border: `1px solid ${APP.border}`,
                        display: "flex",
                        alignItems: "center",
                        gap: 12,
                      }}
                    >
                      <span style={{ fontSize: 16, color: APP.secondary }}>{f.icon}</span>
                      <div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>{f.label}</div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 15, color: APP.white }}>{f.value}</div>
                      </div>
                    </div>
                  </div>
                ))}

                {/* Type - SegmentedButton */}
                <div style={{ ...fadeUp(frame, 36, 14, 12) }}>
                  <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary, marginBottom: 6 }}>Tipe Mesin</div>
                  <div style={{ display: "flex", gap: 0, borderRadius: 8, overflow: "hidden", border: `1px solid ${APP.border}` }}>
                    {["Automatic", "Quartz", "Solar"].map((t, i) => (
                      <div
                        key={t}
                        style={{
                          flex: 1,
                          padding: "10px 8px",
                          textAlign: "center",
                          backgroundColor: i === 0 ? `rgba(201,162,39,0.15)` : APP.surface,
                          borderRight: i < 2 ? `1px solid ${APP.border}` : "none",
                          fontFamily: FONT_SANS,
                          fontSize: 13,
                          fontWeight: 500,
                          color: i === 0 ? APP.gold : APP.secondary,
                        }}
                      >
                        {t}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Price */}
                <div style={{ ...fadeUp(frame, 42, 14, 12) }}>
                  <div
                    style={{
                      padding: "12px 16px",
                      borderRadius: 8,
                      backgroundColor: APP.surface,
                      border: `1px solid ${priceError ? APP.error : APP.border}`,
                    }}
                  >
                    <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Harga (Rp)</div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 15, color: priceError ? APP.error : APP.white }}>
                      {priceError ? "0" : "125.000.000"}
                    </div>
                  </div>
                  {priceError ? (
                    <div style={{ marginTop: 5, fontFamily: FONT_SANS, fontSize: 12, color: APP.error, ...fadeUp(frame, 104, 10, 12) }}>
                      {priceError}
                    </div>
                  ) : null}
                </div>

                {/* Stock */}
                <div style={{ ...fadeUp(frame, 48, 14, 12) }}>
                  <div
                    style={{
                      padding: "12px 16px",
                      borderRadius: 8,
                      backgroundColor: APP.surface,
                      border: `1px solid ${stockError ? APP.error : APP.border}`,
                    }}
                  >
                    <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Stok</div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 15, color: stockError ? APP.error : APP.white }}>
                      {stockError ? "-5" : "2"}
                    </div>
                  </div>
                  {stockError ? (
                    <div style={{ marginTop: 5, fontFamily: FONT_SANS, fontSize: 12, color: APP.error, ...fadeUp(frame, 134, 10, 12) }}>
                      {stockError}
                    </div>
                  ) : null}
                </div>

                {/* Serial Number */}
                <div style={{ ...fadeUp(frame, 54, 14, 12) }}>
                  <div
                    style={{
                      padding: "12px 16px",
                      borderRadius: 8,
                      backgroundColor: APP.surface,
                      border: `1px solid ${serialError ? APP.error : APP.border}`,
                    }}
                  >
                    <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Nomor Seri</div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 15, color: serialError ? APP.error : APP.white }}>
                      {serialError ? "SK-SRPD65-001" : "RLX-126610-007"}
                    </div>
                  </div>
                  {serialError ? (
                    <div style={{ marginTop: 5, fontFamily: FONT_SANS, fontSize: 12, color: APP.error, ...fadeUp(frame, 64, 10, 12) }}>
                      {serialError}
                    </div>
                  ) : null}
                </div>

                {/* Save button */}
                <div
                  style={{
                    marginTop: 6,
                    height: 44,
                    borderRadius: 8,
                    backgroundColor: APP.gold,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontFamily: FONT_SANS,
                    fontSize: 16,
                    fontWeight: 600,
                    color: APP.bg,
                    ...fadeUp(frame, 60, 14, 12),
                  }}
                >
                  Simpan
                </div>
              </div>

              {/* Success SnackBar */}
              {showSuccess ? (
                <div
                  style={{
                    position: "absolute",
                    bottom: 32,
                    right: 32,
                    padding: "14px 24px",
                    borderRadius: 8,
                    backgroundColor: APP.success,
                    fontFamily: FONT_SANS,
                    fontSize: 15,
                    fontWeight: 500,
                    color: APP.white,
                    opacity: successP,
                    transform: `translateY(${(1 - successP) * 20}px)`,
                    boxShadow: "0 8px 32px rgba(0,0,0,0.4)",
                  }}
                >
                  ✓ Jam tangan ditambahkan
                </div>
              ) : null}
            </div>
          </div>
        </BrowserFrame>
        </DemoStage>
    </SceneShell>
  );
};

/* =========================================================== */
/* Demo 5 — Detail & Responsif                                  */
/* =========================================================== */

const DETAIL_SERVICES = [
  { date: "1 Sep 2026", type: "Berkala", desc: "Penggantian baterai dan pembersihan mesin", cost: "150.000" },
  { date: "15 Mar 2026", type: "Ringan", desc: "Pelumasan mesin otomatik", cost: "250.000" },
];

export const DemoDetail: React.FC<{ durationInFrames: number }> = ({ durationInFrames }) => {
  const frame = useCurrentFrame();

  return (
    <SceneShell durationInFrames={durationInFrames}>
      <DemoStage eyebrow="Demo Prototype" title="Detail &amp; Responsif" glowX={50}>
        <BrowserFrame>
          <div style={{ position: "absolute", inset: 0, backgroundColor: APP.bg, display: "flex" }}>
            {/* Nav rail - visible because width >= 600 */}
            <div
              style={{
                width: 64,
                backgroundColor: APP.bg,
                borderRight: `1px solid ${APP.border}`,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                paddingTop: 20,
                gap: 28,
                ...fadeUp(frame, 8, 16, 14),
              }}
            >
              <div
                style={{
                  width: 36, height: 36, borderRadius: "50%",
                  border: `1.5px solid ${APP.gold}`,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontFamily: FONT_DISPLAY, fontSize: 16, fontWeight: 600, color: APP.gold,
                }}
              >C</div>
              {[
                { label: "Dashboard", active: false },
                { label: "Data Jam", active: true },
                { label: "Pengingat", active: false },
              ].map((item, i) => (
                <div key={item.label} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}>
                  <div
                    style={{
                      width: 36, height: 36, borderRadius: 8,
                      backgroundColor: item.active ? `rgba(201,162,39,0.15)` : "transparent",
                      border: item.active ? `1px solid ${APP.gold}` : "1px solid transparent",
                      display: "flex", alignItems: "center", justifyContent: "center",
                      fontSize: 16, color: item.active ? APP.gold : APP.secondary,
                    }}
                  >{["◆", "☰", "🔔"][i]}</div>
                  <div style={{ fontFamily: FONT_SANS, fontSize: 9, color: item.active ? APP.gold : APP.hint }}>{item.label}</div>
                </div>
              ))}
            </div>

            {/* Detail content */}
            <div style={{ flex: 1, padding: "28px 32px", overflow: "hidden" }}>
              {/* Back button + title */}
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 12,
                  ...fadeUp(frame, 12, 16, 14),
                }}
              >
                <span style={{ fontSize: 20, color: APP.secondary }}>←</span>
                <span style={{ fontFamily: FONT_SANS, fontSize: 20, fontWeight: 600, color: APP.white }}>
                  Detail Jam Tangan
                </span>
              </div>

              {/* Watch info card */}
              <div
                style={{
                  marginTop: 20,
                  padding: "24px 28px",
                  borderRadius: 12,
                  backgroundColor: APP.surface,
                  border: `1px solid ${APP.border}`,
                  ...fadeUp(frame, 20, 18, 16),
                }}
              >
                <div style={{ display: "flex", gap: 24, alignItems: "flex-start" }}>
                  {/* Watch icon */}
                  <div
                    style={{
                      width: 80,
                      height: 80,
                      borderRadius: 12,
                      backgroundColor: APP.surfaceAlt,
                      border: `1px solid ${APP.border}`,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 36,
                      flexShrink: 0,
                    }}
                  >
                    ⌚
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 22, fontWeight: 600, color: APP.white }}>
                      Seiko 5 Sports
                    </div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 14, color: APP.secondary, marginTop: 4 }}>
                      Seiko · SRPD65 · Automatic
                    </div>
                    <div style={{ marginTop: 12, display: "flex", gap: 24 }}>
                      <div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Harga</div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 18, fontWeight: 600, color: APP.gold, marginTop: 2 }}>
                          Rp 3.500.000
                        </div>
                      </div>
                      <div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Stok</div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 18, fontWeight: 600, color: APP.white, marginTop: 2 }}>
                          5 unit
                        </div>
                      </div>
                      <div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Nomor Seri</div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 15, color: APP.white, marginTop: 2 }}>
                          SK-SRPD65-001
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Warranty info */}
                <div
                  style={{
                    marginTop: 16,
                    paddingTop: 16,
                    borderTop: `1px solid ${APP.border}`,
                    display: "flex",
                    gap: 32,
                  }}
                >
                  <div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Garansi Mulai</div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 14, color: APP.white, marginTop: 2 }}>15 Agu 2026</div>
                  </div>
                  <div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Garansi Berakhir</div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 14, color: APP.white, marginTop: 2 }}>15 Agu 2028</div>
                  </div>
                  <div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: APP.secondary }}>Status</div>
                    <div
                      style={{
                        display: "inline-block",
                        marginTop: 2,
                        padding: "4px 12px",
                        borderRadius: 12,
                        backgroundColor: `rgba(76,175,80,0.15)`,
                        border: `1px solid ${APP.success}`,
                        fontFamily: FONT_SANS,
                        fontSize: 12,
                        fontWeight: 500,
                        color: APP.success,
                      }}
                    >
                      Aktif
                    </div>
                  </div>
                </div>
              </div>

              {/* Service history */}
              <div
                style={{
                  marginTop: 24,
                  fontFamily: FONT_SANS,
                  fontSize: 16,
                  fontWeight: 600,
                  color: APP.white,
                  ...fadeUp(frame, 40, 16, 14),
                }}
              >
                Riwayat Servis
              </div>
              <div style={{ marginTop: 12, display: "grid", gap: 10 }}>
                {DETAIL_SERVICES.map((s, i) => (
                  <div
                    key={i}
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: 16,
                      padding: "14px 18px",
                      borderRadius: 8,
                      backgroundColor: APP.surface,
                      border: `1px solid ${APP.border}`,
                      ...fadeUp(frame, 46 + i * 8, 14, 12),
                    }}
                  >
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", gap: 12, alignItems: "baseline" }}>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 14, fontWeight: 600, color: APP.white }}>
                          {s.type}
                        </div>
                        <div style={{ fontFamily: FONT_SANS, fontSize: 12, color: APP.secondary }}>
                          {s.date}
                        </div>
                      </div>
                      <div style={{ fontFamily: FONT_SANS, fontSize: 13, color: APP.secondary, marginTop: 4 }}>
                        {s.desc}
                      </div>
                    </div>
                    <div style={{ fontFamily: FONT_SANS, fontSize: 15, fontWeight: 500, color: APP.gold }}>
                      Rp {s.cost}
                    </div>
                  </div>
                ))}
              </div>

              {/* Responsive indicator */}
              <div
                style={{
                  position: "absolute",
                  bottom: 16,
                  right: 32,
                  padding: "8px 16px",
                  borderRadius: 8,
                  backgroundColor: `rgba(201,162,39,0.1)`,
                  border: `1px solid ${APP.gold}`,
                  fontFamily: FONT_SANS,
                  fontSize: 12,
                  fontWeight: 500,
                  color: APP.gold,
                  ...fadeUp(frame, 70, 14, 12),
                }}
              >
                NavigationRail aktif (lebar ≥ 600px)
              </div>
            </div>
          </div>
        </BrowserFrame>
        </DemoStage>
    </SceneShell>
  );
};
