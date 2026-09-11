"use client";

import { useRef, useState, useEffect, ReactNode } from "react";
import styles from "./Rail.module.css";

interface RailProps {
  children: ReactNode;
  itemWidth?: number; // px
}

export function Rail({ children, itemWidth = 320 }: RailProps) {
  const scrollerRef = useRef<HTMLDivElement>(null);
  const [canPrev, setCanPrev] = useState(false);
  const [canNext, setCanNext] = useState(true);

  const update = () => {
    const el = scrollerRef.current;
    if (!el) return;
    setCanPrev(el.scrollLeft > 8);
    setCanNext(el.scrollLeft + el.clientWidth < el.scrollWidth - 8);
  };

  useEffect(() => {
    const el = scrollerRef.current;
    if (!el) return;
    update();
    el.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);
    return () => {
      el.removeEventListener("scroll", update);
      window.removeEventListener("resize", update);
    };
  }, []);

  const scroll = (dir: 1 | -1) => {
    scrollerRef.current?.scrollBy({
      left: dir * (itemWidth * 2.2),
      behavior: "smooth",
    });
  };

  return (
    <div className={styles.wrap}>
      <div ref={scrollerRef} className={styles.scroller}>
        {children}
      </div>
      {canPrev && (
        <button
          className={`${styles.arrow} ${styles.prev}`}
          aria-label="Scroll left"
          onClick={() => scroll(-1)}
        >
          <ArrowIcon dir="left" />
        </button>
      )}
      {canNext && (
        <button
          className={`${styles.arrow} ${styles.next}`}
          aria-label="Scroll right"
          onClick={() => scroll(1)}
        >
          <ArrowIcon dir="right" />
        </button>
      )}
    </div>
  );
}

function ArrowIcon({ dir }: { dir: "left" | "right" }) {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      {dir === "left" ? (
        <>
          <path d="M19 12H5" />
          <path d="m12 19-7-7 7-7" />
        </>
      ) : (
        <>
          <path d="M5 12h14" />
          <path d="m13 5 7 7-7 7" />
        </>
      )}
    </svg>
  );
}
