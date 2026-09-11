import { LiveHero } from "@/components/LiveHero";
import { SectionHeader } from "@/components/SectionHeader";
import { HomeTopStories, HomeLatestNews } from "@/components/HomeArticles";
import { TrendingVideos } from "@/components/TrendingVideos";
import { Rail } from "@/components/Rail";
import { PosterImage } from "@/components/PosterImage";
import { programs } from "@/data/programs";
import Link from "next/link";
import styles from "./page.module.css";

export default function HomePage() {
  const tvShows = programs.filter((p) => p.type === "tv").slice(0, 8);

  return (
    <>
      <LiveHero />

      {/* --------- LATEST NEWS (moved up from below) --------- */}
      <HomeLatestNews />

      {/* --------- TOP STORIES --------- */}
      <HomeTopStories />

      {/* --------- WATCH OUR SHOWS (moved down from above) --------- */}
      <section className={styles.section}>
        <div className="container">
          <SectionHeader
            eyebrow="Featured Programs"
            title="Watch our shows"
            href="/live-tv/"
            cta="See schedule"
          />
          <Rail itemWidth={280}>
            {tvShows.map((show) => (
              <Link key={show.id} href="/live-tv/" className={styles.showCard}>
                <div className={styles.showThumb}>
                  <PosterImage spec={show.image} title={show.title} variant="letter" />
                  <span className={styles.showTime}>{show.start} · {show.day.slice(0, 3)}</span>
                </div>
                <div>
                  <h3>{show.title}</h3>
                  <p>{show.host}</p>
                </div>
              </Link>
            ))}
          </Rail>
        </div>
      </section>

      {/* --------- TRENDING VIDEOS (real articles with YouTube URLs) --------- */}
      <TrendingVideos />

      {/* --------- NEWSLETTER --------- */}
      <section className={styles.section}>
        <div className="container">
          <div className={styles.newsletter}>
            <div className={styles.newsletterOrb} />
            <div>
              <div className="eyebrow">Stay connected</div>
              <h2 className={styles.newsletterTitle}>
                The Kalenjin daily,<br />
                <span className="gradient-text">delivered to your inbox.</span>
              </h2>
              <p>Top stories, program schedules, and community updates — every morning.</p>
            </div>
            <form className={styles.newsletterForm}>
              <input type="email" placeholder="Enter your email" required />
              <button type="submit">Subscribe</button>
            </form>
          </div>
        </div>
      </section>
    </>
  );
}
