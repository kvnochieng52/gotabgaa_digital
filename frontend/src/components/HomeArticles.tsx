"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArticleCard } from "./ArticleCard";
import { SectionHeader } from "./SectionHeader";
import { getArticles, apiToCardArticle, type ApiArticle } from "@/lib/api";
import { formatDate } from "@/lib/format";
import type { Article } from "@/lib/types";
import styles from "@/app/page.module.css";

function useArticles(limit = 30) {
  const [articles, setArticles] = useState<ApiArticle[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    getArticles({ limit })
      .then((a) => {
        if (!cancelled) setArticles(a);
      })
      .catch(() => {})
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [limit]);

  return { articles, loading };
}

/** Top stories — featured hero card + numbered list of top 4 next. */
export function HomeTopStories() {
  const { articles, loading } = useArticles(6);

  if (loading && articles.length === 0) {
    return (
      <section className={styles.section}>
        <div className="container">
          <div className={styles.featuredGrid}>
            <div style={{ height: 480, borderRadius: 20, background: "var(--bg-elevated)", border: "1px solid var(--line)" }} />
            <div style={{ display: "grid", gap: 14 }}>
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} style={{ height: 100, borderRadius: 20, background: "var(--bg-elevated)", border: "1px solid var(--line)" }} />
              ))}
            </div>
          </div>
        </div>
      </section>
    );
  }

  const [feature, ...rest] = articles;
  if (!feature) return null;
  const top = rest.slice(0, 4);

  return (
    <section className={styles.section}>
      <div className="container">
        <SectionHeader
          eyebrow="Top stories"
          title="What everyone's reading"
          href="/news/"
          cta="Latest news"
        />
        <div className={styles.featuredGrid}>
          <ArticleCard article={apiToCardArticle(feature) as unknown as Article} variant="large" />
          <div className={styles.topList}>
            {top.map((a, i) => (
              <Link key={a.slug} href={`/article/${a.slug}/`} className={styles.topItem}>
                <span className={styles.topRank}>0{i + 1}</span>
                <div>
                  <span className={styles.topCategory}>{a.category}</span>
                  <h3>{a.title}</h3>
                  <span className={styles.topDate}>{a.publishedAt ? formatDate(a.publishedAt) : ""}</span>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

/** Latest news — 8-item grid, skips the top 5 that appear in "Top stories". */
export function HomeLatestNews() {
  const { articles, loading } = useArticles(15);

  if (loading && articles.length === 0) {
    return (
      <section className={styles.section}>
        <div className="container">
          <div className={styles.newsGrid}>
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} style={{ height: 340, borderRadius: 20, background: "var(--bg-elevated)", border: "1px solid var(--line)" }} />
            ))}
          </div>
        </div>
      </section>
    );
  }

  // Skip the ones already featured in Top stories (feature + 4 items = 5 total).
  const latest = articles.slice(5, 13);
  if (latest.length === 0) return null;

  return (
    <section className={styles.section}>
      <div className="container">
        <SectionHeader
          eyebrow="Fresh off the desk"
          title="Latest news"
          href="/news/"
          cta="Browse all"
        />
        <div className={styles.newsGrid}>
          {latest.map((a) => (
            <ArticleCard key={a.slug} article={apiToCardArticle(a) as unknown as Article} />
          ))}
        </div>
      </div>
    </section>
  );
}

/** Backwards-compatible combined section — keeps existing imports working. */
export function HomeArticles() {
  return (
    <>
      <HomeTopStories />
      <HomeLatestNews />
    </>
  );
}
