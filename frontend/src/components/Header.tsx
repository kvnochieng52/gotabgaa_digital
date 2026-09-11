"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { getArticles, apiFetch } from "@/lib/api";
import { ThemeToggle } from "./ThemeToggle";
import styles from "./Header.module.css";

interface BreakingItem { slug: string; title: string; }

const NAV: { href: string; label: string; highlight?: boolean }[] = [
  { href: "/", label: "Home" },
  { href: "/news/", label: "News" },
  { href: "/category/politics/", label: "Politics" },
  { href: "/category/sports/", label: "Sports" },
  { href: "/category/culture/", label: "Culture" },
  { href: "/live-tv/", label: "Live TV" },
  { href: "/catch-up/", label: "Catch Up" },
  { href: "/contact/", label: "Contact" },
  { href: "/advertise/", label: "Advertise with us", highlight: true },
];

export function Header() {
  const pathname = usePathname();
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [breaking, setBreaking] = useState<BreakingItem[]>([]);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  // Fetch breaking headlines: prefer /breaking-news, fall back to latest articles.
  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const bn = await apiFetch<{ data: { headline: string; link_url: string | null }[] }>("/breaking-news").catch(() => null);
        if (bn?.data?.length) {
          if (!cancelled) {
            setBreaking(bn.data.slice(0, 5).map((b) => ({
              slug: b.link_url ?? "/news/",
              title: b.headline,
            })));
          }
          return;
        }
        const arts = await getArticles({ limit: 5 });
        if (!cancelled) {
          setBreaking(arts.map((a) => ({ slug: `/article/${a.slug}/`, title: a.title })));
        }
      } catch {
        // silent
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    setMenuOpen(false);
    setSearchOpen(false);
  }, [pathname]);

  return (
    <>
      {/* BREAKING TICKER */}
      {breaking.length > 0 && (
        <div className={styles.tickerBar}>
          <div className={styles.tickerLabel}>
            <span className={styles.tickerDot} />
            Breaking
          </div>
          <div className={styles.tickerViewport}>
            <ul className={styles.tickerTrack}>
              {[...breaking, ...breaking].map((a, i) => (
                <li key={i}>
                  <Link href={a.slug.startsWith("/") ? a.slug : `/article/${a.slug}/`}>{a.title}</Link>
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}

      {/* MAIN HEADER */}
      <header className={`${styles.header} ${scrolled ? styles.scrolled : ""}`}>
        <div className={`container ${styles.headerInner}`}>
          <Link href="/" className={styles.branding}>
            <Image
              src="/logo.png"
              alt="Gotabgaa Digital"
              width={220}
              height={120}
              priority
              className={styles.logo}
            />
          </Link>

          <nav className={`${styles.nav} ${menuOpen ? styles.navOpen : ""}`} aria-label="Primary">
            <ul>
              {NAV.map((item) => {
                const active =
                  pathname === item.href ||
                  (item.href !== "/" && pathname.startsWith(item.href));
                const cls = item.highlight
                  ? `${styles.navHighlight} ${active ? styles.navHighlightActive : ""}`
                  : active
                    ? styles.navLinkActive
                    : styles.navLink;
                return (
                  <li key={item.href}>
                    <Link href={item.href} className={cls}>
                      {item.label}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </nav>

          <div className={styles.actions}>
            <ThemeToggle />
            <button
              className={styles.iconBtn}
              aria-label="Search"
              onClick={() => setSearchOpen((v) => !v)}
            >
              <SearchIcon />
            </button>
            <Link href="/live-tv/" className={styles.watchLive}>
              <span className={styles.watchDot} />
              Watch Live
            </Link>
            <button
              className={`${styles.iconBtn} ${styles.menuToggle}`}
              aria-label="Menu"
              aria-expanded={menuOpen}
              onClick={() => setMenuOpen((v) => !v)}
            >
              <MenuIcon open={menuOpen} />
            </button>
          </div>

          {searchOpen && (
            <div className={styles.searchDrawer}>
              <input
                type="search"
                autoFocus
                placeholder="Search news, shows, videos…"
                className={styles.searchInput}
              />
            </div>
          )}
        </div>
      </header>
    </>
  );
}

function SearchIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="11" cy="11" r="7" />
      <path d="m20 20-4-4" />
    </svg>
  );
}

function MenuIcon({ open }: { open: boolean }) {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round">
      {open ? (
        <>
          <path d="M6 6l12 12" />
          <path d="M18 6L6 18" />
        </>
      ) : (
        <>
          <path d="M3 6h18" />
          <path d="M3 12h18" />
          <path d="M3 18h18" />
        </>
      )}
    </svg>
  );
}
