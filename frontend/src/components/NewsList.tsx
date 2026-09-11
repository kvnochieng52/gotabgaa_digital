"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArticleCard } from "./ArticleCard";
import { getArticles, getCategories, apiToCardArticle, type ApiCategory, type ApiArticle } from "@/lib/api";
import styles from "@/app/news/page.module.css";
import type { Article } from "@/lib/types";

interface NewsListProps {
  categorySlug?: string;
}

export function NewsList({ categorySlug }: NewsListProps) {
  const [articles, setArticles] = useState<ApiArticle[]>([]);
  const [cats, setCats] = useState<ApiCategory[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    Promise.all([
      getArticles({ limit: 60, category: categorySlug }),
      getCategories(),
    ])
      .then(([a, c]) => {
        if (cancelled) return;
        setArticles(a);
        setCats(c);
      })
      .catch(() => {
        if (!cancelled) {
          setArticles([]);
          setCats([]);
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [categorySlug]);

  return (
    <>
      <div className={styles.filters}>
        <Link
          href="/news/"
          className={`${styles.chip} ${!categorySlug ? styles.chipActive : ""}`}
        >
          All
        </Link>
        {cats.map((c) => (
          <Link
            key={c.slug}
            href={`/category/${c.slug}/`}
            className={`${styles.chip} ${categorySlug === c.slug ? styles.chipActive : ""}`}
          >
            {c.name}
          </Link>
        ))}
      </div>

      <div className={styles.grid} style={{ marginTop: 32 }}>
        {loading && articles.length === 0
          ? Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className={styles.skeletonCard} />
            ))
          : articles.map((a) => (
              <ArticleCard key={a.slug} article={apiToCardArticle(a) as unknown as Article} />
            ))}
      </div>

      {!loading && articles.length === 0 && (
        <div className={styles.empty}>
          <p>No articles found{categorySlug ? ` in "${categorySlug}"` : ""}.</p>
        </div>
      )}
    </>
  );
}
