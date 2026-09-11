"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import { LiveBadge } from "./LiveBadge";
import styles from "./LiveStreamPlayer.module.css";

// Match the OLD website exactly — load Video.js 8.6.0 from the same CDN so the
// bundle we run in the browser is the identical, tested build the production
// gotabgaa.co.ke site uses.
const VIDEOJS_VERSION = "8.6.0";
const VIDEOJS_CSS = `https://cdnjs.cloudflare.com/ajax/libs/video.js/${VIDEOJS_VERSION}/video-js.min.css`;
const VIDEOJS_JS = `https://cdnjs.cloudflare.com/ajax/libs/video.js/${VIDEOJS_VERSION}/video.min.js`;

interface LiveStreamPlayerProps {
  url: string | null | undefined;
  poster?: string;
  className?: string;
  autoplay?: boolean;
}

type PlaybackKind = "hls" | "flv" | "mp4" | "youtube" | "rtmp" | "empty" | "unknown";

function detectPlayback(url: string | null | undefined): PlaybackKind {
  if (!url) return "empty";
  const u = url.trim().toLowerCase();
  if (u.startsWith("rtmp://") || u.startsWith("rtmps://")) return "rtmp";
  if (u.includes("youtube.com") || u.includes("youtu.be")) return "youtube";
  if (u.endsWith(".flv") || u.includes(".flv?")) return "flv";
  if (u.endsWith(".mp4") || u.includes(".mp4?")) return "mp4";
  if (u.startsWith("http://") || u.startsWith("https://")) return "hls";
  return "unknown";
}

// Lazy-loaders — reuse the same <script>/<link> across mounts so the CDN is
// hit at most once per session.
let videojsPromise: Promise<any> | null = null;
function loadVideoJs(): Promise<any> {
  if (typeof window === "undefined") return Promise.resolve(null);
  const w = window as unknown as { videojs?: any };
  if (w.videojs) return Promise.resolve(w.videojs);
  if (videojsPromise) return videojsPromise;

  videojsPromise = new Promise((resolve, reject) => {
    // CSS
    if (!document.querySelector(`link[href="${VIDEOJS_CSS}"]`)) {
      const link = document.createElement("link");
      link.rel = "stylesheet";
      link.href = VIDEOJS_CSS;
      document.head.appendChild(link);
    }
    // JS
    if (document.querySelector(`script[src="${VIDEOJS_JS}"]`)) {
      // Already loading — wait for it.
      const check = () => {
        if (w.videojs) resolve(w.videojs);
        else setTimeout(check, 50);
      };
      check();
      return;
    }
    const script = document.createElement("script");
    script.src = VIDEOJS_JS;
    script.async = true;
    script.onload = () => (w.videojs ? resolve(w.videojs) : reject(new Error("videojs did not attach to window")));
    script.onerror = () => reject(new Error("Failed to load Video.js from CDN"));
    document.head.appendChild(script);
  });
  return videojsPromise;
}

export function LiveStreamPlayer({
  url,
  poster,
  className,
  autoplay = false,
}: LiveStreamPlayerProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const playerRef = useRef<any>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const kind = detectPlayback(url);

  useEffect(() => {
    if (kind !== "hls" && kind !== "mp4") return;
    if (!url || !videoRef.current) return;

    let disposed = false;

    (async () => {
      try {
        const videojs = await loadVideoJs();
        if (disposed || !videoRef.current) return;

        // Tear down any previous player before making a new one.
        if (playerRef.current) {
          try { playerRef.current.dispose(); } catch { /* noop */ }
          playerRef.current = null;
        }

        const player = videojs(videoRef.current, {
          autoplay: autoplay ? "muted" : false,
          controls: true,
          liveui: true,
          fluid: true,
          preload: "auto",
          responsive: true,
          sources: [{
            src: url,
            type: kind === "hls" ? "application/x-mpegURL" : "video/mp4",
          }],
        });

        player.on("error", () => {
          const err = player.error();
          const code = err?.code ?? "?";
          const msg = err?.message ?? "Playback error";
          setErrorMsg(`(${code}) ${msg}`);
        });

        playerRef.current = player;
      } catch (e) {
        setErrorMsg(e instanceof Error ? e.message : "Failed to load video player");
      }
    })();

    return () => {
      disposed = true;
      if (playerRef.current) {
        try { playerRef.current.dispose(); } catch { /* noop */ }
        playerRef.current = null;
      }
    };
  }, [url, kind, autoplay]);

  return (
    <div className={`${styles.player} ${className ?? ""}`}>
      {kind === "hls" || kind === "mp4" ? (
        <>
          <video
            ref={videoRef}
            className={`video-js vjs-big-play-centered vjs-fluid ${styles.video}`}
            playsInline
            poster={poster}
          />
          {errorMsg && <FallbackPanel title="Stream error" message={errorMsg} />}
        </>
      ) : kind === "youtube" ? (
        <YouTubeEmbed url={url!} autoplay={autoplay} />
      ) : kind === "rtmp" ? (
        <FallbackPanel
          title="RTMP stream detected"
          message="RTMP is for stream ingest, not browser playback. Configure an HLS output on your streaming server."
        />
      ) : kind === "empty" ? (
        <FallbackPanel title="No stream configured" message="Set the TV Stream URL in the CMS → Settings." />
      ) : (
        <FallbackPanel title="Unknown stream format" message={`Cannot play: ${url}`} />
      )}
    </div>
  );
}

/* ---------- Sub-components ---------- */
function YouTubeEmbed({ url, autoplay }: { url: string; autoplay?: boolean }) {
  const idMatch = url.match(/(?:youtu\.be\/|v=|\/embed\/)([\w-]{11})/);
  const id = idMatch?.[1];
  if (!id) {
    return <FallbackPanel title="Invalid YouTube URL" message={url} />;
  }
  return (
    <iframe
      src={`https://www.youtube.com/embed/${id}?autoplay=${autoplay ? 1 : 0}&rel=0`}
      className={styles.iframe}
      allow="autoplay; fullscreen; picture-in-picture"
      allowFullScreen
    />
  );
}

function FallbackPanel({ title, message }: { title: string; message: string }) {
  return (
    <div className={styles.fallback}>
      <div className={styles.fallbackInner}>
        <Image src="/logo.png" alt="" width={140} height={80} className={styles.fallbackLogo} />
        <LiveBadge label="STREAM READY" />
        <h3>{title}</h3>
        <p>{message}</p>
      </div>
    </div>
  );
}
