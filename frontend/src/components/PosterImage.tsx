"use client";

import { gradient } from "@/lib/format";
import styles from "./PosterImage.module.css";

interface PosterImageProps {
  spec: string; // "#hex|#hex" gradient spec OR a full image URL
  title?: string;
  variant?: "logo" | "letter" | "abstract";
}

function isUrl(spec: string): boolean {
  return spec.startsWith("http://") || spec.startsWith("https://") || spec.startsWith("/");
}

export function PosterImage({ spec, title, variant = "abstract" }: PosterImageProps) {
  const letter = title?.trim()?.charAt(0)?.toUpperCase() ?? "G";

  if (isUrl(spec)) {
    return (
      <div className={styles.wrap} aria-hidden="true">
        <img
          src={spec}
          alt=""
          loading="lazy"
          className={styles.photo}
          onError={(e) => {
            // If maxresdefault etc. is missing, fall back to hqdefault (always exists on YouTube).
            const img = e.currentTarget;
            const src = img.src;
            if (src.includes("/maxresdefault.jpg")) {
              img.src = src.replace("/maxresdefault.jpg", "/hqdefault.jpg");
              return;
            }
            if (src.includes("/sddefault.jpg")) {
              img.src = src.replace("/sddefault.jpg", "/hqdefault.jpg");
              return;
            }
            // Give up: hide the image so the parent gradient (if any) shows.
            img.style.display = "none";
          }}
        />
      </div>
    );
  }

  return (
    <div className={styles.wrap} style={{ background: gradient(spec) }} aria-hidden="true">
      <div className={styles.noise} />
      {variant === "letter" && <span className={styles.letter}>{letter}</span>}
      {variant === "logo" && <span className={styles.logo}>G</span>}
      {variant === "abstract" && (
        <>
          <span className={styles.blob1} />
          <span className={styles.blob2} />
        </>
      )}
    </div>
  );
}
