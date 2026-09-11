import { SectionHeader } from "@/components/SectionHeader";
import { VideoCard } from "@/components/VideoCard";
import { Rail } from "@/components/Rail";
import { videos } from "@/data/videos";
import styles from "./page.module.css";

export const metadata = {
  title: "Catch Up TV",
  description: "Watch full episodes, news bulletins, interviews and features on demand.",
};

export default function CatchUpPage() {
  const trending = [...videos].sort((a, b) => b.views - a.views).slice(0, 6);
  const byCategory = videos.reduce<Record<string, typeof videos>>((acc, v) => {
    (acc[v.category] ||= []).push(v);
    return acc;
  }, {});

  return (
    <>
      <section className={styles.hero}>
        <div className={styles.orb} />
        <div className={`container ${styles.heroInner}`}>
          <div className="eyebrow">On demand</div>
          <h1 className={styles.title}>
            Missed a show? <span className="gradient-text">Watch it here.</span>
          </h1>
          <p className={styles.subtitle}>
            Full episodes, news bulletins, cultural specials, and interviews — anytime, anywhere.
          </p>

          <div className={styles.searchRow}>
            <input type="search" placeholder="Search shows, hosts, or topics…" className={styles.search} />
            <button className={styles.searchBtn}>Search</button>
          </div>
        </div>
      </section>

      {/* Trending */}
      <section className={styles.section}>
        <div className="container">
          <SectionHeader eyebrow="Most watched" title="Trending this week" />
          <Rail itemWidth={320}>
            {trending.map((v) => <VideoCard key={v.slug} video={v} size="lg" />)}
          </Rail>
        </div>
      </section>

      {/* By category */}
      {Object.entries(byCategory).map(([cat, vids]) => (
        <section key={cat} className={styles.section}>
          <div className="container">
            <SectionHeader eyebrow={cat} title={`${cat} — full library`} />
            <div className={styles.grid}>
              {vids.map((v) => <VideoCard key={v.slug} video={v} />)}
            </div>
          </div>
        </section>
      ))}
    </>
  );
}
