"use client";

import { useEffect, useMemo, useState } from "react";
import { getActivePoll, voteOnPoll, type ApiPoll } from "@/lib/api";
import styles from "./LivePoll.module.css";

const STORAGE_KEY = "gotabgaa-poll-votes"; // Map<pollSlug, optionId>

type VoteMap = Record<string, string>;

function readVotes(): VoteMap {
  if (typeof window === "undefined") return {};
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return {};
    const parsed = JSON.parse(raw);
    return typeof parsed === "object" && parsed !== null ? parsed : {};
  } catch {
    return {};
  }
}

function saveVote(pollSlug: string, optionId: string) {
  try {
    const votes = readVotes();
    votes[pollSlug] = optionId;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(votes));
  } catch { /* noop */ }
}

/** Human-friendly "closes in X" from a UTC ISO timestamp. */
function useCountdown(closesAt: string | null): string | null {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    if (!closesAt) return;
    const interval = setInterval(() => setNow(Date.now()), 30_000);
    return () => clearInterval(interval);
  }, [closesAt]);

  return useMemo(() => {
    if (!closesAt) return null;
    const diff = new Date(closesAt).getTime() - now;
    if (diff <= 0) return "Closed";
    const secs = Math.floor(diff / 1000);
    const days = Math.floor(secs / 86_400);
    const hrs = Math.floor((secs % 86_400) / 3600);
    const mins = Math.floor((secs % 3600) / 60);
    if (days > 0) return `Closes in ${days}d ${hrs}h`;
    if (hrs > 0) return `Closes in ${hrs}h ${mins}m`;
    if (mins > 0) return `Closes in ${mins}m`;
    return `Closes in ${secs}s`;
  }, [closesAt, now]);
}

export function LivePoll() {
  const [poll, setPoll] = useState<ApiPoll | null>(null);
  const [status, setStatus] = useState<"loading" | "ready" | "error">("loading");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [voted, setVoted] = useState<string | null>(null);
  const [voting, setVoting] = useState(false);
  const closesText = useCountdown(poll?.closesAt ?? null);

  // Load active poll on mount + check localStorage for existing vote.
  useEffect(() => {
    let cancelled = false;
    getActivePoll()
      .then((p) => {
        if (cancelled) return;
        setPoll(p);
        if (p) {
          const stored = readVotes()[p.slug];
          if (stored) setVoted(stored);
        }
        setStatus("ready");
      })
      .catch((e) => {
        if (cancelled) return;
        setStatus("error");
        setErrorMsg(e instanceof Error ? e.message : "Failed to load poll");
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const handleVote = async (optionId: string) => {
    if (!poll || voted || voting) return;
    setVoting(true);
    setErrorMsg(null);

    // Optimistic: mark as voted immediately.
    setVoted(optionId);
    setPoll((p) => (p ? {
      ...p,
      options: p.options.map((o) => o.id === optionId ? { ...o, votes: o.votes + 1 } : o),
      totalVotes: p.totalVotes + 1,
    } : p));
    saveVote(poll.slug, optionId);

    try {
      const fresh = await voteOnPoll(poll.slug, optionId);
      setPoll(fresh);
    } catch (e) {
      // "Already voted" isn't really an error — server just confirmed our vote is on record.
      const msg = e instanceof Error ? e.message : "Vote failed";
      if (!/already voted/i.test(msg)) {
        setErrorMsg(msg);
      }
    } finally {
      setVoting(false);
    }
  };

  if (status === "loading") {
    return (
      <div className={styles.poll} aria-busy>
        <div className={styles.header}>
          <span className={styles.pill}>
            <span className={styles.dot} /> LIVE POLL
          </span>
        </div>
        <h3 className={styles.question} style={{ opacity: 0.4 }}>Loading poll…</h3>
        <div className={styles.options}>
          {[0, 1, 2].map((i) => (
            <div key={i} className={styles.option} style={{ minHeight: 44, opacity: 0.4 }} />
          ))}
        </div>
      </div>
    );
  }

  if (status === "error" || !poll) {
    return (
      <div className={styles.poll}>
        <div className={styles.header}>
          <span className={styles.pill}><span className={styles.dot} /> LIVE POLL</span>
        </div>
        <h3 className={styles.question}>No live poll right now</h3>
        <div className={styles.footer}>
          <span style={{ color: "var(--text-muted)" }}>{errorMsg ?? "Check back later for the next question."}</span>
        </div>
      </div>
    );
  }

  const showResults = voted !== null;
  const total = poll.totalVotes;

  return (
    <div className={styles.poll}>
      <div className={styles.header}>
        <span className={styles.pill}>
          <span className={styles.dot} /> LIVE POLL
        </span>
        {closesText && (
          <span className={styles.timer}>
            <ClockIcon />
            {closesText}
          </span>
        )}
      </div>

      <h3 className={styles.question}>{poll.question}</h3>

      <div className={styles.options}>
        {poll.options.map((opt) => {
          const pct = total > 0 ? (opt.votes / total) * 100 : 0;
          const isPicked = voted === opt.id;
          return (
            <button
              key={opt.id}
              type="button"
              disabled={showResults || voting}
              onClick={() => handleVote(opt.id)}
              className={`${styles.option} ${isPicked ? styles.picked : ""} ${showResults ? styles.showingResults : ""}`}
              aria-pressed={isPicked}
            >
              <span className={styles.optionFill} style={{ width: showResults ? `${pct}%` : "0%" }} />
              <span className={styles.optionContent}>
                <span className={styles.optionLabel}>
                  {isPicked && <CheckIcon />}
                  {opt.label}
                </span>
                {showResults && (
                  <span className={styles.optionStats}>
                    <span className={styles.optionPct}>{pct.toFixed(0)}%</span>
                    <span className={styles.optionVotes}>{formatNum(opt.votes)}</span>
                  </span>
                )}
              </span>
            </button>
          );
        })}
      </div>

      <div className={styles.footer}>
        <span>
          <UsersIcon />
          {formatNum(total)} vote{total === 1 ? "" : "s"}
          {!voted && " · tap to cast yours"}
          {voted && !errorMsg && " · thanks for voting"}
          {errorMsg && ` · ${errorMsg}`}
        </span>
        <a href="#" className={styles.viewAll}>
          Past polls
          <ArrowIcon />
        </a>
      </div>
    </div>
  );
}

function formatNum(n: number) {
  if (n >= 1000) return `${(n / 1000).toFixed(1)}K`;
  return n.toString();
}

function ClockIcon() { return (<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>); }
function CheckIcon() { return (<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>); }
function UsersIcon() { return (<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>); }
function ArrowIcon() { return (<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14"/><path d="m13 5 7 7-7 7"/></svg>); }
