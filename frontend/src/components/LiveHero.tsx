import Link from "next/link";
import { LiveBadge } from "./LiveBadge";
import { LivePoll } from "./LivePoll";
import { LiveTVPlayerSlot } from "./LiveTVPlayerSlot";
import { getCurrentProgram } from "@/data/programs";
import styles from "./LiveHero.module.css";

export function LiveHero() {
  const isOnAir = !!getCurrentProgram("tv");

  return (
    <section className={styles.hero}>
      <div className={styles.orbA} />
      <div className={styles.orbB} />
      <div className={styles.grid} />

      <div className={`container ${styles.inner}`}>
        {/* LEFT: Player (70%) */}
        <div className={styles.playerCol}>
          <div className={styles.player}>
            <LiveTVPlayerSlot className={styles.playerFill} autoplay />
            <div className={styles.playerLive}>
              <LiveBadge label={isOnAir ? "ON AIR" : "STREAM READY"} />
            </div>
            <div className={styles.playerScanlines} />
          </div>
          <div className={styles.playerFoot}>
            <div className={styles.playerFootLabel}>Gotabgaa TV · Live Broadcast</div>
            <div className={styles.playerFootBadges}>
              <span className={styles.quality}>HD</span>
              <span className={styles.stereo}>STEREO</span>
              <span className={styles.captions}>CC</span>
            </div>
          </div>
        </div>

        {/* RIGHT: Poll (30%) */}
        <div className={styles.pollCol}>
          <LivePoll />

          <div className={styles.pollCtas}>
            <Link href="/live-tv/" className={styles.pollPrimaryBtn}>
              <PlayIcon />
              Live TV
            </Link>
            <Link href="/catch-up/" className={styles.pollGhostBtn}>
              <ArchiveIcon />
              Video Archives
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

function PlayIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
      <path d="M8 5v14l11-7z" />
    </svg>
  );
}
function ArchiveIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="4" width="20" height="5" rx="2" />
      <path d="M4 9v9a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9" />
      <path d="M10 13h4" />
    </svg>
  );
}
