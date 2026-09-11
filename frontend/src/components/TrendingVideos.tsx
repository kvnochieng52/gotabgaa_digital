"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { PosterImage } from "./PosterImage";
import { SectionHeader } from "./SectionHeader";
import { Rail } from "./Rail";
import { getArticles, type ApiArticle } from "@/lib/api";
import { formatViews, timeAgo } from "@/lib/format";
import cardStyles from "./VideoCard.module.css";
import pageStyles from "@/app/page.module.css";

export function TrendingVideos() {
  const [videos, setVideos] = useState<ApiArticle[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    getArticles({ limit: 40 })
      .then((all) => {
        if (cancelled) return;
        // Any article with a YouTube URL counts as a video.
        const withVideo = all.filter((a) => !!a.youtubeUrl);
        // "Trending" = highest view_count first; fall back to most recent.
        withVideo.sort((a, b) => {
          if (b.viewCount !== a.viewCount) return b.viewCount - a.viewCount;
          return (b.publishedAt ?? "").localeCompare(a.publishedAt ?? "");
        });
        setVideos(withVideo.slice(0, 12));
      })
      .catch(() => {})
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  if (loading && videos.length === 0) {
    return (
      <section className={pageStyles.section}>
        <div className="container">
          <SectionHeader eyebrow="On demand" title="Trending videos" href="/catch-up/" cta="Full library" />
          <div style={{ display: "grid", gridAutoFlow: "column", gridAutoColumns: 320, gap: 20, overflow: "hidden" }}>
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} style={{ height: 260, borderRadius: 20, background: "var(--bg-elevated)", border: "1px solid var(--line)" }} />
            ))}
          </div>
        </div>
      </section>
    );
  }

  if (videos.length === 0) return null;

  return (
    <section className={pageStyles.section}>
      <div className="container">
        <SectionHeader eyebrow="On demand" title="Trending videos" href="/catch-up/" cta="Full library" />
        <Rail itemWidth={320}>
          {videos.map((v) => (
            <TrendingCard key={v.slug} article={v} />
          ))}
        </Rail>
      </div>
    </section>
  );
}

function TrendingCard({ article }: { article: ApiArticle }) {
  return (
    <Link href={`/article/${article.slug}/`} className={cardStyles.card_md}>
      <div className={cardStyles.thumb}>
        <PosterImage spec={article.image} title={article.title} variant="abstract" />
        <span className={cardStyles.play} aria-hidden>▶</span>
        {article.readingTime > 0 && (
          <span className={cardStyles.duration}>{article.readingTime}:00</span>
        )}
      </div>
      <div className={cardStyles.body}>
        <h3>{article.title}</h3>
        <div className={cardStyles.meta}>
          <span>{formatViews(article.viewCount)} views</span>
          <span className={cardStyles.dot} />
          <span>{article.publishedAt ? timeAgo(article.publishedAt) : "recent"}</span>
        </div>
      </div>
    </Link>
  );
}
