import { LiveBadge } from "@/components/LiveBadge";
import { LiveChat } from "@/components/LiveChat";
import { PosterImage } from "@/components/PosterImage";
import { VideoCard } from "@/components/VideoCard";
import { SectionHeader } from "@/components/SectionHeader";
import { LiveTVPlayerSlot } from "@/components/LiveTVPlayerSlot";
import { getSchedule, getCurrentProgram } from "@/data/programs";
import { videos } from "@/data/videos";
import styles from "./page.module.css";

export const metadata = {
  title: "Live TV",
  description: "Watch Gotabgaa TV live 24/7. News, culture, sports and talk shows from the Kalenjin diaspora.",
};

export default function LiveTVPage() {
  const schedule = getSchedule("tv");
  const current = getCurrentProgram("tv");
  const catchup = videos.slice(0, 6);

  const groupedByDay = schedule.reduce<Record<string, typeof schedule>>((acc, p) => {
    (acc[p.day] ||= []).push(p);
    return acc;
  }, {});

  return (
    <>
      <section className={styles.hero}>
        <div className={styles.heroOrbA} />
        <div className={styles.heroOrbB} />

        <div className={`container ${styles.heroInner}`}>
          <div className={styles.player}>
            <LiveTVPlayerSlot className={styles.playerFill} autoplay />
            <div className={styles.playerBadge}>
              <LiveBadge label={current ? "ON AIR" : "STREAM READY"} />
            </div>
          </div>

          <div className={styles.playerFoot}>
            <div>
              {current ? (
                <>
                  <div className={styles.playerFootEyebrow}>Now Playing</div>
                  <div className={styles.playerFootTitle}>{current.title}</div>
                  <div className={styles.playerFootMeta}>
                    Hosted by {current.host} · {current.start}–{current.end}
                  </div>
                </>
              ) : (
                <>
                  <div className={styles.playerFootEyebrow}>Off Air</div>
                  <div className={styles.playerFootTitle}>Programming resumes shortly</div>
                  <div className={styles.playerFootMeta}>See schedule below</div>
                </>
              )}
            </div>
            <div className={styles.playerControls}>
              <button aria-label="Volume"><VolumeIcon /></button>
              <button aria-label="Captions">CC</button>
              <button aria-label="Fullscreen"><FullscreenIcon /></button>
            </div>
          </div>
        </div>
      </section>

      <section className={styles.section}>
        <div className="container">
          <SectionHeader eyebrow="Join the room" title="Live conversation" />
          <LiveChat />
        </div>
      </section>

      <section className={styles.section}>
        <div className="container">
          <SectionHeader eyebrow="This week on Gotabgaa TV" title="Full Schedule" />
          {Object.entries(groupedByDay).map(([day, shows]) => (
            <div key={day} className={styles.dayGroup}>
              <h3 className={styles.dayTitle}>{day}</h3>
              <div className={styles.dayGrid}>
                {shows.map((s) => (
                  <article
                    key={s.id}
                    className={`${styles.scheduleCard} ${s.id === current?.id ? styles.onAir : ""}`}
                  >
                    <div className={styles.scheduleThumb}>
                      <PosterImage spec={s.image} title={s.title} variant="letter" />
                    </div>
                    <div>
                      <div className={styles.scheduleTime}>
                        {s.start} – {s.end}
                        {s.id === current?.id && <LiveBadge />}
                      </div>
                      <h4>{s.title}</h4>
                      <p>{s.description}</p>
                      <span className={styles.scheduleHost}>{s.host}</span>
                    </div>
                  </article>
                ))}
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className={styles.section}>
        <div className="container">
          <SectionHeader eyebrow="Catch up" title="Watch on demand" href="/catch-up/" cta="Full library" />
          <div className={styles.catchupGrid}>
            {catchup.map((v) => <VideoCard key={v.slug} video={v} />)}
          </div>
        </div>
      </section>
    </>
  );
}

function VolumeIcon() { return (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" /><path d="M15.54 8.46a5 5 0 0 1 0 7.07" /></svg>); }
function FullscreenIcon() { return (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7V3h4M17 3h4v4M21 17v4h-4M7 21H3v-4" /></svg>); }
