import Link from "next/link";
import { PosterImage } from "./PosterImage";
import { formatDate } from "@/lib/format";
import type { Article } from "@/lib/types";
import styles from "./ArticleCard.module.css";

type Variant = "default" | "large" | "compact";

interface ArticleCardProps {
  article: Article;
  variant?: Variant;
}

export function ArticleCard({ article, variant = "default" }: ArticleCardProps) {
  return (
    <Link
      href={`/article/${article.slug}/`}
      className={
        variant === "large"
          ? styles.large
          : variant === "compact"
          ? styles.compact
          : styles.card
      }
    >
      <div className={styles.media}>
        <PosterImage spec={article.image} title={article.title} variant="letter" />
        <span className={styles.tag}>{article.category}</span>
      </div>
      <div className={styles.body}>
        <h3 className={styles.title}>{article.title}</h3>
        {variant !== "compact" && (
          <p className={styles.excerpt}>{article.excerpt}</p>
        )}
        <div className={styles.meta}>
          <span>{formatDate(article.publishedAt)}</span>
          <span className={styles.dot} />
          <span>{article.readingTime} min read</span>
        </div>
      </div>
    </Link>
  );
}
