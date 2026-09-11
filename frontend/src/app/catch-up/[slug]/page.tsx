import { notFound } from "next/navigation";
import { PosterImage } from "@/components/PosterImage";
import { VideoCard } from "@/components/VideoCard";
import { SectionHeader } from "@/components/SectionHeader";
import { videos, getVideoBySlug } from "@/data/videos";
import { formatDate, formatViews } from "@/lib/format";
import styles from "./page.module.css";

export async function generateStaticParams() {
  return videos.map((v) => ({ slug: v.slug }));
}

export async function generateMetadata({ params }: PageProps<"/catch-up/[slug]">) {
  const { slug } = await params;
  const video = getVideoBySlug(slug);
  if (!video) return {};
  return { title: video.title, description: video.description };
}

export default async function VideoPage({ params }: PageProps<"/catch-up/[slug]">) {
  const { slug } = await params;
  const video = getVideoBySlug(slug);
  if (!video) notFound();

  const related = videos.filter((v) => v.slug !== video.slug && v.category === video.category).slice(0, 4);

  return (
    <>
      <section className={styles.playerSection}>
        <div className={`container ${styles.playerWrap}`}>
          <div className={styles.player}>
            <PosterImage spec={video.image} title={video.title} variant="letter" />
            <button className={styles.playBtn} aria-label="Play video">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z" /></svg>
            </button>
            <span className={styles.duration}>{video.duration}</span>
          </div>
          <div className={styles.info}>
            <div className={styles.categoryTag}>{video.category}</div>
            <h1 className={styles.title}>{video.title}</h1>
            <div className={styles.meta}>
              <span>{formatViews(video.views)} views</span>
              <span className={styles.dot} />
              <span>Aired {formatDate(video.airedAt)}</span>
            </div>
            <p className={styles.description}>{video.description}</p>
          </div>
        </div>
      </section>

      {related.length > 0 && (
        <section className={styles.section}>
          <div className="container">
            <SectionHeader eyebrow={video.category} title="More like this" />
            <div className={styles.grid}>
              {related.map((v) => <VideoCard key={v.slug} video={v} />)}
            </div>
          </div>
        </section>
      )}
    </>
  );
}
