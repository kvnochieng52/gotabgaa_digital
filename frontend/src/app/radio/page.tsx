import { LiveBadge } from "@/components/LiveBadge";
import { SectionHeader } from "@/components/SectionHeader";
import { PosterImage } from "@/components/PosterImage";
import { getSchedule, getCurrentProgram } from "@/data/programs";
import styles from "./page.module.css";

export const metadata = {
  title: "Live Radio",
  description: "Listen to Gotabgaa Radio — music, talk, and community 24/7.",
};

export default function RadioPage() {
  const schedule = getSchedule("radio");
  const current = getCurrentProgram("radio");

  return (
    <>
      <section className={styles.hero}>
        <div className={styles.orbA} />
        <div className={styles.orbB} />

        <div className={`container ${styles.heroInner}`}>
          <div className={styles.stationArt}>
            <div className={styles.stationCore}>
              <div className={styles.pulseRing} />
              <div className={styles.pulseRing2} />
              <span className={styles.stationLetter}>G</span>
            </div>
          </div>

          <div className={styles.copy}>
            <div className={styles.eyebrowRow}>
              <LiveBadge label={current ? "ON AIR" : "STREAM READY"} />
              <span className={styles.timePill}>102.5 FM</span>
            </div>
            <h1 className={styles.title}>
              <span className="gradient-text">Gotabgaa Radio</span>
            </h1>
            <p className={styles.subtitle}>
              The sound of the diaspora. Music, talk, and community — 24 hours a day.
            </p>

            {current && (
              <div className={styles.nowPlaying}>
                <div className={styles.nowPlayingLabel}>Now on air</div>
                <div className={styles.nowPlayingTitle}>{current.title}</div>
                <div className={styles.nowPlayingHost}>{current.host} · {current.start}–{current.end}</div>
              </div>
            )}

            <div className={styles.playerBar}>
              <button className={styles.playBtn} aria-label="Play">
                <PlayIcon />
              </button>
              <div className={styles.waveform}>
                {Array.from({ length: 40 }).map((_, i) => (
                  <span key={i} className={styles.bar} style={{ height: `${20 + Math.abs(Math.sin(i * 0.5)) * 60}%`, animationDelay: `${i * 60}ms` }} />
                ))}
              </div>
              <div className={styles.volume}>
                <VolumeIcon />
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className={styles.section}>
        <div className="container">
          <SectionHeader eyebrow="Weekly schedule" title="Programming lineup" />
          <div className={styles.scheduleGrid}>
            {schedule.map((s) => (
              <article
                key={s.id}
                className={`${styles.card} ${s.id === current?.id ? styles.onAir : ""}`}
              >
                <div className={styles.cardArt}>
                  <PosterImage spec={s.image} title={s.title} variant="letter" />
                </div>
                <div className={styles.cardBody}>
                  <div className={styles.cardMeta}>
                    {s.day} · {s.start}–{s.end}
                    {s.id === current?.id && <LiveBadge />}
                  </div>
                  <h3>{s.title}</h3>
                  <p>{s.description}</p>
                  <div className={styles.cardHost}>with {s.host}</div>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}

function PlayIcon() { return (<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z" /></svg>); }
function VolumeIcon() { return (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" /><path d="M15.54 8.46a5 5 0 0 1 0 7.07" /></svg>); }
