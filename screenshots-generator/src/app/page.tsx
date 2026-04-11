"use client";

import React, { useState, useEffect, useRef, useCallback } from "react";
import { toPng } from "html-to-image";

// =============================================================================
// Constants
// =============================================================================

const W = 1320;
const H = 2868;

const IPHONE_SIZES = [
  { label: '6.9"', w: 1320, h: 2868 },
  { label: '6.5"', w: 1284, h: 2778 },
  { label: '6.3"', w: 1206, h: 2622 },
  { label: '6.1"', w: 1125, h: 2436 },
] as const;

// iPhone mockup measurements
const MK_W = 1022;
const MK_H = 2082;
const MK_RATIO = MK_W / MK_H;
const SC_L = (52 / MK_W) * 100;
const SC_T = (46 / MK_H) * 100;
const SC_W = (918 / MK_W) * 100;
const SC_H = (1990 / MK_H) * 100;
const SC_RX = (126 / 918) * 100;
const SC_RY = (126 / 1990) * 100;

// Theme — warm fireworks palette derived from app icon
const THEME = {
  bg: "#0B1428",
  bgLight: "#F6F1EA",
  fg: "#FFFFFF",
  fgDark: "#171717",
  accent: "#F59E0B",
};

// =============================================================================
// Image preload cache (CRITICAL for html-to-image export)
// =============================================================================

const IMAGE_PATHS = [
  "/mockup.png",
  "/app-icon.png",
  "/screenshots/en/01-home-light.png",
  "/screenshots/en/02-settings-light.png",
  "/screenshots/en/03-home-dark.png",
  "/screenshots/en/04-settings-dark.png",
];

const imageCache: Record<string, string> = {};

async function preloadAllImages() {
  await Promise.all(
    IMAGE_PATHS.map(async (path) => {
      const resp = await fetch(path);
      const blob = await resp.blob();
      const dataUrl = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.readAsDataURL(blob);
      });
      imageCache[path] = dataUrl;
    })
  );
}

function img(path: string): string {
  return imageCache[path] || path;
}

// =============================================================================
// Width formula
// =============================================================================

function phoneW(cW: number, cH: number, clamp = 0.84) {
  return Math.min(clamp, 0.72 * (cH / cW) * MK_RATIO);
}

// =============================================================================
// Device frame component
// =============================================================================

function Phone({
  src,
  alt,
  style,
}: {
  src: string;
  alt: string;
  style?: React.CSSProperties;
}) {
  return (
    <div
      style={{
        position: "relative",
        aspectRatio: `${MK_W}/${MK_H}`,
        ...style,
      }}
    >
      <img
        src={img("/mockup.png")}
        alt=""
        style={{ display: "block", width: "100%", height: "100%" }}
        draggable={false}
      />
      <div
        style={{
          position: "absolute",
          zIndex: 10,
          overflow: "hidden",
          left: `${SC_L}%`,
          top: `${SC_T}%`,
          width: `${SC_W}%`,
          height: `${SC_H}%`,
          borderRadius: `${SC_RX}% / ${SC_RY}%`,
        }}
      >
        <img
          src={src}
          alt={alt}
          style={{
            display: "block",
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: "top",
          }}
          draggable={false}
        />
      </div>
    </div>
  );
}

// =============================================================================
// Caption component
// =============================================================================

function Caption({
  cW,
  label,
  headline,
  light = false,
}: {
  cW: number;
  label: string;
  headline: React.ReactNode;
  light?: boolean;
}) {
  return (
    <div
      style={{
        position: "absolute",
        top: `${cW * 0.06}px`,
        left: "50%",
        transform: "translateX(-50%)",
        textAlign: "center",
        width: "90%",
        zIndex: 20,
      }}
    >
      <div
        style={{
          fontSize: cW * 0.028,
          fontWeight: 600,
          color: THEME.accent,
          letterSpacing: "0.1em",
          textTransform: "uppercase",
          marginBottom: cW * 0.015,
        }}
      >
        {label}
      </div>
      <div
        style={{
          fontSize: cW * 0.085,
          fontWeight: 700,
          color: light ? THEME.fgDark : THEME.fg,
          lineHeight: 1.0,
        }}
      >
        {headline}
      </div>
    </div>
  );
}

// =============================================================================
// Slide definitions
// =============================================================================

type SlideProps = { cW: number; cH: number };
type SlideDef = { id: string; component: (p: SlideProps) => React.JSX.Element };

const SLIDES: SlideDef[] = [
  // Slide 1: Hero — dark bg, home screenshot, app icon
  {
    id: "hero",
    component: ({ cW, cH }: SlideProps) => {
      const fw = phoneW(cW, cH) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `radial-gradient(ellipse at 50% 30%, #1a2744 0%, ${THEME.bg} 70%)`,
            overflow: "hidden",
          }}
        >
          {/* Warm glow behind phone */}
          <div
            style={{
              position: "absolute",
              bottom: "15%",
              left: "50%",
              transform: "translateX(-50%)",
              width: "70%",
              height: "50%",
              borderRadius: "50%",
              background:
                "radial-gradient(ellipse, rgba(245,158,11,0.15) 0%, transparent 70%)",
              filter: "blur(60px)",
            }}
          />
          <Caption
            cW={cW}
            label="TEMPLATESWIFTAPP"
            headline={
              <>
                Your app,
                <br />
                ready to ship.
              </>
            }
          />
          {/* App icon */}
          <img
            src={img("/app-icon.png")}
            alt="App Icon"
            style={{
              position: "absolute",
              top: `${cW * 0.34}px`,
              left: "50%",
              transform: "translateX(-50%)",
              width: cW * 0.12,
              height: cW * 0.12,
              borderRadius: cW * 0.025,
              zIndex: 20,
            }}
            draggable={false}
          />
          <Phone
            src={img("/screenshots/en/01-home-light.png")}
            alt="Home"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "50%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />
        </div>
      );
    },
  },

  // Slide 2: Settings — warm light bg for visual contrast
  {
    id: "settings",
    component: ({ cW, cH }: SlideProps) => {
      const fw = phoneW(cW, cH) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `linear-gradient(170deg, ${THEME.bgLight} 0%, #E8DFD3 100%)`,
            overflow: "hidden",
          }}
        >
          {/* Subtle accent blob */}
          <div
            style={{
              position: "absolute",
              top: "10%",
              right: "-10%",
              width: "50%",
              height: "40%",
              borderRadius: "50%",
              background:
                "radial-gradient(ellipse, rgba(245,158,11,0.12) 0%, transparent 70%)",
              filter: "blur(80px)",
            }}
          />
          <Caption
            cW={cW}
            label="FULLY CONFIGURED"
            headline={
              <>
                Every detail,
                <br />
                your way.
              </>
            }
            light
          />
          <Phone
            src={img("/screenshots/en/02-settings-light.png")}
            alt="Settings"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "50%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />
        </div>
      );
    },
  },

  // Slide 3: Dark mode — two phones layered for visual interest
  {
    id: "dark-mode",
    component: ({ cW, cH }: SlideProps) => {
      const fw = phoneW(cW, cH, 0.66) * 100;
      const fwLarge = phoneW(cW, cH, 0.82) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `linear-gradient(150deg, #0d0d1a 0%, ${THEME.bg} 40%, #0a1a30 100%)`,
            overflow: "hidden",
          }}
        >
          {/* Glow */}
          <div
            style={{
              position: "absolute",
              bottom: "20%",
              right: "10%",
              width: "60%",
              height: "40%",
              borderRadius: "50%",
              background:
                "radial-gradient(ellipse, rgba(245,158,11,0.1) 0%, transparent 70%)",
              filter: "blur(60px)",
            }}
          />
          <Caption
            cW={cW}
            label="DARK MODE"
            headline={
              <>
                Beautiful
                <br />
                in the dark.
              </>
            }
          />
          {/* Back phone — light, tilted, faded */}
          <Phone
            src={img("/screenshots/en/01-home-light.png")}
            alt="Home Light"
            style={{
              position: "absolute",
              bottom: 0,
              left: "-8%",
              width: `${fw}%`,
              transform: "rotate(-4deg) translateY(15%)",
              opacity: 0.45,
            }}
          />
          {/* Front phone — dark */}
          <Phone
            src={img("/screenshots/en/03-home-dark.png")}
            alt="Home Dark"
            style={{
              position: "absolute",
              bottom: 0,
              right: "-4%",
              width: `${fwLarge}%`,
              transform: "translateY(10%)",
            }}
          />
        </div>
      );
    },
  },

  // Slide 4: Dark settings — final slide
  {
    id: "polished",
    component: ({ cW, cH }: SlideProps) => {
      const fw = phoneW(cW, cH) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `radial-gradient(ellipse at 50% 60%, #162040 0%, ${THEME.bg} 70%)`,
            overflow: "hidden",
          }}
        >
          {/* Top glow */}
          <div
            style={{
              position: "absolute",
              top: "-10%",
              left: "50%",
              transform: "translateX(-50%)",
              width: "80%",
              height: "40%",
              borderRadius: "50%",
              background:
                "radial-gradient(ellipse, rgba(245,158,11,0.08) 0%, transparent 70%)",
              filter: "blur(80px)",
            }}
          />
          <Caption
            cW={cW}
            label="POLISHED"
            headline={
              <>
                Ready for
                <br />
                the store.
              </>
            }
          />
          <Phone
            src={img("/screenshots/en/04-settings-dark.png")}
            alt="Settings Dark"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "50%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />
        </div>
      );
    },
  },
];

// =============================================================================
// Preview component with ResizeObserver scaling
// =============================================================================

function ScreenshotPreview({
  slide,
  index,
  cW,
  cH,
  exportRef,
}: {
  slide: SlideDef;
  index: number;
  cW: number;
  cH: number;
  exportRef: (el: HTMLDivElement | null) => void;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [scale, setScale] = useState(0.2);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const observer = new ResizeObserver((entries) => {
      const entry = entries[0];
      if (!entry) return;
      setScale(entry.contentRect.width / cW);
    });
    observer.observe(el);
    return () => observer.disconnect();
  }, [cW]);

  const Comp = slide.component;

  return (
    <div>
      {/* Preview card */}
      <div
        ref={containerRef}
        style={{
          width: "100%",
          aspectRatio: `${cW}/${cH}`,
          overflow: "hidden",
          borderRadius: 12,
          border: "1px solid #e5e7eb",
          position: "relative",
          background: "#000",
        }}
      >
        <div
          style={{
            width: cW,
            height: cH,
            transform: `scale(${scale})`,
            transformOrigin: "top left",
            position: "absolute",
            top: 0,
            left: 0,
          }}
        >
          <Comp cW={cW} cH={cH} />
        </div>
      </div>
      <p
        style={{
          marginTop: 8,
          fontSize: 12,
          color: "#6b7280",
          textAlign: "center",
        }}
      >
        {String(index + 1).padStart(2, "0")} &mdash; {slide.id}
      </p>

      {/* Offscreen export element */}
      <div
        ref={exportRef}
        style={{
          width: cW,
          height: cH,
          position: "absolute",
          left: -9999,
          top: 0,
        }}
      >
        <Comp cW={cW} cH={cH} />
      </div>
    </div>
  );
}

// =============================================================================
// Main page
// =============================================================================

export default function ScreenshotsPage() {
  const [ready, setReady] = useState(false);
  const [sizeIdx, setSizeIdx] = useState(0);
  const [exporting, setExporting] = useState<string | null>(null);
  const exportRefs = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    preloadAllImages().then(() => setReady(true));
  }, []);

  const size = IPHONE_SIZES[sizeIdx];

  const captureSlide = useCallback(
    async (el: HTMLElement, w: number, h: number): Promise<string> => {
      el.style.left = "0px";
      el.style.opacity = "1";
      el.style.zIndex = "-1";

      const opts = { width: w, height: h, pixelRatio: 1, cacheBust: true };
      // Double-call trick: first warms fonts/images, second produces clean output
      await toPng(el, opts);
      const dataUrl = await toPng(el, opts);

      el.style.left = "-9999px";
      el.style.opacity = "";
      el.style.zIndex = "";
      return dataUrl;
    },
    []
  );

  const exportAll = useCallback(async () => {
    for (let i = 0; i < SLIDES.length; i++) {
      setExporting(`${i + 1}/${SLIDES.length}`);
      const el = exportRefs.current[i];
      if (!el) continue;
      const dataUrl = await captureSlide(el, size.w, size.h);
      const a = document.createElement("a");
      a.href = dataUrl;
      a.download = `${String(i + 1).padStart(2, "0")}-${SLIDES[i].id}-en-${size.w}x${size.h}.png`;
      a.click();
      await new Promise((r) => setTimeout(r, 300));
    }
    setExporting(null);
  }, [size, captureSlide]);

  if (!ready) {
    return (
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          height: "100vh",
          fontSize: 18,
          color: "#6b7280",
        }}
      >
        Loading images&hellip;
      </div>
    );
  }

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "#f3f4f6",
        position: "relative",
        overflowX: "hidden",
      }}
    >
      {/* Toolbar */}
      <div
        style={{
          position: "sticky",
          top: 0,
          zIndex: 50,
          background: "white",
          borderBottom: "1px solid #e5e7eb",
          display: "flex",
          alignItems: "center",
        }}
      >
        {/* Scrollable controls */}
        <div
          style={{
            flex: 1,
            display: "flex",
            alignItems: "center",
            gap: 10,
            padding: "10px 16px",
            overflowX: "auto",
            minWidth: 0,
          }}
        >
          <span style={{ fontWeight: 700, fontSize: 14, whiteSpace: "nowrap" }}>
            TemplateSwiftApp &middot; Screenshots
          </span>

          {/* Export size picker */}
          <select
            value={sizeIdx}
            onChange={(e) => setSizeIdx(Number(e.target.value))}
            style={{
              fontSize: 12,
              border: "1px solid #e5e7eb",
              borderRadius: 6,
              padding: "5px 10px",
            }}
          >
            {IPHONE_SIZES.map((s, i) => (
              <option key={i} value={i}>
                {s.label} &mdash; {s.w}&times;{s.h}
              </option>
            ))}
          </select>
        </div>

        {/* Export button — always visible at right edge */}
        <div
          style={{
            flexShrink: 0,
            padding: "10px 16px",
            borderLeft: "1px solid #e5e7eb",
          }}
        >
          <button
            onClick={exportAll}
            disabled={!!exporting}
            style={{
              padding: "7px 20px",
              background: exporting ? "#93c5fd" : "#2563eb",
              color: "white",
              border: "none",
              borderRadius: 8,
              fontSize: 12,
              fontWeight: 600,
              cursor: exporting ? "default" : "pointer",
              whiteSpace: "nowrap",
            }}
          >
            {exporting ? `Exporting\u2026 ${exporting}` : "Export All"}
          </button>
        </div>
      </div>

      {/* Slide grid */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
          gap: 24,
          padding: 24,
        }}
      >
        {SLIDES.map((slide, i) => (
          <ScreenshotPreview
            key={slide.id}
            slide={slide}
            index={i}
            cW={W}
            cH={H}
            exportRef={(el) => {
              exportRefs.current[i] = el;
            }}
          />
        ))}
      </div>
    </div>
  );
}
