import Link from "next/link";
import { PosterImage } from "./PosterImage";
import { formatViews, timeAgo } from "@/lib/format";
import type { Video } from "@/lib/types";
import styles from "./VideoCard.module.css";

interface VideoCardProps {
  video: Video;
  size?: "sm" | "md" | "lg";
}

export function VideoCard({ video, size = "md" }: VideoCardProps) {
  return (
    <Link href={`/catch-up/${video.slug}/`} className={styles[`card_${size}`]}>
      <div className={styles.thumb}>
        <PosterImage spec={video.image} title={video.title} variant="abstract" />
        <span className={styles.play} aria-hidden>▶</span>
        <span className={styles.duration}>{video.duration}</span>
      </div>
      <div className={styles.body}>
        <h3>{video.title}</h3>
        <div className={styles.meta}>
          <span>{formatViews(video.views)} views</span>
          <span className={styles.dot} />
          <span>{timeAgo(video.airedAt)}</span>
        </div>
      </div>
    </Link>
  );
}
