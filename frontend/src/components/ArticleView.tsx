"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { PosterImage } from "@/components/PosterImage";
import { ArticleCard } from "@/components/ArticleCard";
import { ArticleComments } from "@/components/ArticleComments";
import { getArticle, getArticles, apiToCardArticle, type ApiArticle } from "@/lib/api";
import { formatDate, timeAgo } from "@/lib/format";
import type { Article } from "@/lib/types";
import styles from "@/app/article/[slug]/page.module.css";

interface ArticleViewProps {
  slug: string;
}

export function ArticleView({ slug }: ArticleViewProps) {
  const [article, setArticle] = useState<ApiArticle | null>(null);
  const [related, setRelated] = useState<ApiArticle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);

    getArticle(slug)
      .then((a) => {
        if (cancelled) return;
        setArticle(a);
        if (a.categorySlug) {
          getArticles({ limit: 4, category: a.categorySlug })
            .then((rel) => {
              if (!cancelled) setRelated(rel.filter((r) => r.slug !== a.slug).slice(0, 3));
            })
            .catch(() => {});
        }
      })
      .catch((e) => {
        if (!cancelled) setError(e.message ?? "Failed to load article");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [slug]);

  if (loading) {
    return (
      <div className={styles.loadingWrap}>
        <div className={styles.loader} />
      </div>
    );
  }
  if (error || !article) {
    return (
      <div className={styles.emptyWrap}>
        <p>Article not found.</p>
        <Link href="/news/">← Back to news</Link>
      </div>
    );
  }

  const ytEmbedId = article.youtubeUrl?.match(/(?:youtu\.be\/|v=|\/embed\/)([\w-]{11})/)?.[1];
  const publishedAt = article.publishedAt ?? new Date().toISOString();

  return (
    <>
      <article>
        <div className={styles.heroImage}>
          <PosterImage spec={article.image} title={article.title} variant="logo" />
          <div className={styles.heroOverlay} />
          <div className={styles.heroContent}>
            <div className="container">
              {article.categorySlug && (
                <Link href={`/category/${article.categorySlug}/`} className={styles.categoryTag}>
                  {article.category}
                </Link>
              )}
              <h1 className={styles.title}>{article.title}</h1>
              {article.excerpt && <p className={styles.excerpt}>{article.excerpt}</p>}
              <div className={styles.meta}>
                <div className={styles.author}>
                  <span className={styles.avatar}>{article.author.name.charAt(0)}</span>
                  <div>
                    <strong>{article.author.name}</strong>
                    <span>{formatDate(publishedAt)} · {article.readingTime} min read</span>
                  </div>
                </div>
                <div className={styles.timeAgo}>{timeAgo(publishedAt)}</div>
              </div>
            </div>
          </div>
        </div>

        <div className={`container ${styles.body}`}>
          <div className={styles.content}>
            {ytEmbedId && (
              <div className={styles.videoWrap}>
                <iframe
                  src={`https://www.youtube.com/embed/${ytEmbedId}?rel=0`}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  title={article.title}
                />
              </div>
            )}
            {(article.body ?? article.excerpt ?? "").split("\n\n").map((paragraph, i) => (
              <p key={i}>{paragraph}</p>
            ))}

            <ArticleComments slug={article.slug} />
          </div>

          <aside className={styles.sidebar}>
            <div className={styles.shareBox}>
              <h4>Share</h4>
              <div className={styles.shareRow}>
                <a
                  href={`https://api.whatsapp.com/send?text=${encodeURIComponent(article.title + " — " + window.location.href)}`}
                  aria-label="Share on WhatsApp"
                  className={styles.shareBtn}
                  style={{ background: "#25D366" }}
                  target="_blank" rel="noopener noreferrer"
                >
                  <WhatsAppIcon />
                </a>
                <a
                  href={`https://twitter.com/intent/tweet?text=${encodeURIComponent(article.title)}&url=${encodeURIComponent(typeof window !== "undefined" ? window.location.href : "")}`}
                  aria-label="Share on X"
                  className={styles.shareBtn}
                  style={{ background: "#000" }}
                  target="_blank" rel="noopener noreferrer"
                >
                  <XIcon />
                </a>
                <a
                  href={`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(typeof window !== "undefined" ? window.location.href : "")}`}
                  aria-label="Share on Facebook"
                  className={styles.shareBtn}
                  style={{ background: "#1877F2" }}
                  target="_blank" rel="noopener noreferrer"
                >
                  <FBIcon />
                </a>
                <a
                  href={`mailto:?subject=${encodeURIComponent(article.title)}&body=${encodeURIComponent(typeof window !== "undefined" ? window.location.href : "")}`}
                  aria-label="Share via email"
                  className={styles.shareBtn}
                  style={{ background: "#666" }}
                >
                  <EmailIcon />
                </a>
              </div>
            </div>

            {article.tags && article.tags.length > 0 && (
              <div className={styles.tagsBox}>
                <h4>Tags</h4>
                <div>
                  {article.tags.map((t) => (
                    <span key={t} className={styles.tag}>#{t}</span>
                  ))}
                </div>
              </div>
            )}
          </aside>
        </div>
      </article>

      {related.length > 0 && (
        <section className={styles.related}>
          <div className="container">
            <div className="eyebrow">Read next</div>
            <h2>More in {article.category}</h2>
            <div className={styles.relatedGrid}>
              {related.map((a) => (
                <ArticleCard key={a.slug} article={apiToCardArticle(a) as unknown as Article} />
              ))}
            </div>
          </div>
        </section>
      )}
    </>
  );
}

function WhatsAppIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M20.5 3.5A11 11 0 0 0 2.7 17.1L1 23l6-1.5a11 11 0 0 0 5 1.2 11 11 0 0 0 8.5-19.2Z"/></svg>); }
function XIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M17.53 3H21l-7.55 8.63L22 21h-6.8l-5.32-6.96L3.79 21H.32l8.07-9.24L1 3h6.94l4.82 6.4L17.53 3Z"/></svg>); }
function FBIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M22 12a10 10 0 1 0-11.6 9.9V15H8v-3h2.5V9.8c0-2.5 1.5-3.9 3.8-3.9 1.1 0 2.2.2 2.2.2v2.5h-1.3c-1.2 0-1.6.8-1.6 1.6V12h2.7l-.4 3h-2.3V22A10 10 0 0 0 22 12Z"/></svg>); }
function EmailIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/></svg>); }
