"use client";

import { useState } from "react";
import { LiveChat } from "./LiveChat";
import { LivePoll } from "./LivePoll";
import styles from "./PollChatTabs.module.css";

type Tab = "chat" | "poll";

export function PollChatTabs({ initial = "chat" }: { initial?: Tab }) {
  const [tab, setTab] = useState<Tab>(initial);

  return (
    <div className={styles.wrap}>
      <div className={styles.tabs} role="tablist">
        <button
          role="tab"
          aria-selected={tab === "chat"}
          className={`${styles.tab} ${tab === "chat" ? styles.active : ""}`}
          onClick={() => setTab("chat")}
        >
          <span className={styles.pulse} />
          Live Chat
        </button>
        <button
          role="tab"
          aria-selected={tab === "poll"}
          className={`${styles.tab} ${tab === "poll" ? styles.active : ""}`}
          onClick={() => setTab("poll")}
        >
          Live Poll
        </button>
      </div>

      <div className={styles.panel}>
        {tab === "chat" ? <LiveChat /> : <LivePoll />}
      </div>
    </div>
  );
}
