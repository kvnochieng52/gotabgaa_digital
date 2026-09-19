import Link from "next/link";
import { LiveBadge } from "./LiveBadge";
import { PollChatTabs } from "./PollChatTabs";
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

        {/* RIGHT: Chat + Poll tabs (30%) */}
        <div className={styles.pollCol}>
          <PollChatTabs initial="chat" />

          <div className={styles.pollCtas}>
            <Link href="/live-tv/" className={styles.pollPrimaryBtn}>
              <PlayIcon />
              Live TV
            </Link>
            <a
              href="https://play.google.com/store/apps/details?id=co.ke.gotabgaa.digital"
              target="_blank"
              rel="noopener noreferrer"
              className={styles.appBtn}
              aria-label="Get the Gotabgaa app on Google Play"
            >
              <span className={styles.appBtnIcon}><PlayStoreIcon /></span>
              <span className={styles.appBtnLabel}>
                <small>Get it on</small>
                <strong>Google Play</strong>
              </span>
            </a>
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
function PlayStoreIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 24 24" aria-hidden="true">
      <defs>
        <linearGradient id="psBlue" x1="0" x2="1" y1="0" y2="1">
          <stop offset="0" stopColor="#00c1ff" />
          <stop offset="1" stopColor="#0091ff" />
        </linearGradient>
        <linearGradient id="psYellow" x1="0" x2="1" y1="0" y2="1">
          <stop offset="0" stopColor="#ffd400" />
          <stop offset="1" stopColor="#ffa000" />
        </linearGradient>
        <linearGradient id="psRed" x1="0" x2="1" y1="0" y2="1">
          <stop offset="0" stopColor="#ff3d47" />
          <stop offset="1" stopColor="#e63946" />
        </linearGradient>
        <linearGradient id="psGreen" x1="0" x2="1" y1="0" y2="1">
          <stop offset="0" stopColor="#00d477" />
          <stop offset="1" stopColor="#00a95c" />
        </linearGradient>
      </defs>
      <path fill="url(#psBlue)"   d="M3.6 1.9c-.4.3-.6.7-.6 1.3v17.6c0 .6.2 1 .6 1.3l10-10.6-10-9.6z" />
      <path fill="url(#psGreen)"  d="m14.6 12.4 3.2-3.4L4.9 1.5l9.7 10.9z" />
      <path fill="url(#psRed)"    d="m14.6 12.4-9.7 10.9 12.9-7.5-3.2-3.4z" />
      <path fill="url(#psYellow)" d="M20.9 10.3 17.8 9l-3.2 3.4 3.2 3.4 3.1-1.3c1.2-.7 1.2-2.5 0-3.2z" />
    </svg>
  );
}
