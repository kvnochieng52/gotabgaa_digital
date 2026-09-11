"use client";

import { useEffect, useState } from "react";
import { LiveStreamPlayer } from "./LiveStreamPlayer";
import { getSettings, type StreamSettings } from "@/lib/api";

interface LiveTVPlayerSlotProps {
  className?: string;
  autoplay?: boolean;
}

export function LiveTVPlayerSlot({ className, autoplay }: LiveTVPlayerSlotProps) {
  const [stream, setStream] = useState<StreamSettings | null>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    let cancelled = false;
    getSettings()
      .then((res) => {
        if (!cancelled) setStream(res.stream);
      })
      .catch(() => {
        if (!cancelled) setFailed(true);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  // Show a placeholder while loading — same design as fallback for continuity.
  const url = failed ? null : stream?.tvStreamUrl ?? null;

  return <LiveStreamPlayer url={url} className={className} autoplay={autoplay} />;
}
