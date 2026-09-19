"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import {
  getLiveChat,
  getLiveChatDays,
  postLiveChat,
  reactLiveChat,
  type ApiLiveChatDay,
  type ApiLiveChatDaySummary,
  type ApiLiveChatMessage,
} from "@/lib/api";
import styles from "./LiveChat.module.css";

const NAME_KEY = "gotabgaa_chat_name";
const PALETTE = [
  "#E63946", "#FF7A1A", "#FFA31A", "#2A9D8F",
  "#264653", "#9D4EDD", "#3A86FF", "#F15BB5",
];

function colorForName(name: string) {
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = (hash * 31 + name.charCodeAt(i)) & 0x7fffffff;
  }
  return PALETTE[hash % PALETTE.length];
}

function formatTime(iso: string) {
  try {
    const d = new Date(iso);
    return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  } catch {
    return "";
  }
}

function formatDayLabel(iso: string) {
  try {
    const d = new Date(`${iso}T00:00:00`);
    return d.toLocaleDateString([], {
      weekday: "long",
      month: "short",
      day: "numeric",
      year: "numeric",
    });
  } catch {
    return iso;
  }
}

export function LiveChat() {
  const [day, setDay] = useState<ApiLiveChatDay | null>(null);
  const [days, setDays] = useState<ApiLiveChatDaySummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [name, setName] = useState<string>("");
  const [text, setText] = useState("");
  const [sending, setSending] = useState(false);
  const [selectedDate, setSelectedDate] = useState<string | null>(null);
  const [showDayPicker, setShowDayPicker] = useState(false);
  const [showNamePrompt, setShowNamePrompt] = useState(false);
  const [pendingName, setPendingName] = useState("");
  const [emojiOpenFor, setEmojiOpenFor] = useState<number | null>(null);
  const [replyTo, setReplyTo] = useState<ApiLiveChatMessage | null>(null);
  const composerRef = useRef<HTMLInputElement | null>(null);
  const messagesRef = useRef<HTMLDivElement | null>(null);

  const scrollToBottom = useCallback(() => {
    const el = messagesRef.current;
    if (!el) return;
    // Only auto-scroll if the user is near the bottom.
    const near = el.scrollHeight - el.scrollTop - el.clientHeight < 140;
    if (near) requestAnimationFrame(() => { el.scrollTop = el.scrollHeight; });
  }, []);

  const load = useCallback(
    async (silent = false) => {
      if (!silent) setLoading(true);
      try {
        const [chat, list] = await Promise.all([
          getLiveChat(selectedDate ?? undefined),
          getLiveChatDays(),
        ]);
        setDay(chat);
        setDays(list);
        setError(null);
        setTimeout(scrollToBottom, 0);
      } catch {
        setError("Could not load chat");
      } finally {
        if (!silent) setLoading(false);
      }
    },
    [selectedDate, scrollToBottom],
  );

  useEffect(() => {
    const stored = typeof window !== "undefined" ? localStorage.getItem(NAME_KEY) : null;
    if (stored) setName(stored);
  }, []);

  useEffect(() => {
    load();
    if (selectedDate) return;
    const t = setInterval(() => load(true), 8000);
    return () => clearInterval(t);
  }, [load, selectedDate]);

  const openNamePrompt = () => {
    setPendingName(name);
    setShowNamePrompt(true);
  };
  const saveName = () => {
    const n = pendingName.trim().slice(0, 40);
    if (!n) return;
    setName(n);
    localStorage.setItem(NAME_KEY, n);
    setShowNamePrompt(false);
  };

  const send = async () => {
    const body = text.trim();
    if (!body || sending) return;
    if (!name.trim()) {
      openNamePrompt();
      return;
    }
    setSending(true);
    const parentId = replyTo?.id ?? null;
    try {
      const msg = await postLiveChat(name.trim(), body, parentId);
      setText("");
      setReplyTo(null);
      if (day?.is_today) {
        if (parentId != null) {
          // Attach reply into its parent (one level deep).
          setDay({
            ...day,
            messages: day.messages.map((m) => {
              const targetId = replyTo!.parent_id ?? replyTo!.id;
              return m.id === targetId
                ? { ...m, replies: [...(m.replies ?? []), msg] }
                : m;
            }),
          });
        } else {
          setDay({ ...day, messages: [...day.messages, msg] });
          setTimeout(scrollToBottom, 0);
        }
      }
    } catch {
      setError("Could not send message");
    } finally {
      setSending(false);
    }
  };

  const startReply = (m: ApiLiveChatMessage) => {
    setReplyTo(m);
    setTimeout(() => composerRef.current?.focus(), 0);
  };

  const updateReactions = (id: number, reactions: Record<string, number>) =>
    setDay((d) => d && ({
      ...d,
      messages: d.messages.map((m) => {
        if (m.id === id) return { ...m, reactions };
        if (m.replies?.some((r) => r.id === id)) {
          return {
            ...m,
            replies: m.replies.map((r) => r.id === id ? { ...r, reactions } : r),
          };
        }
        return m;
      }),
    }));

  const react = async (msg: ApiLiveChatMessage, emoji: string) => {
    if (!day?.is_today) return;
    setEmojiOpenFor(null);
    const bumped = { ...msg.reactions, [emoji]: (msg.reactions[emoji] ?? 0) + 1 };
    updateReactions(msg.id, bumped);
    try {
      const actual = await reactLiveChat(msg.id, emoji);
      updateReactions(msg.id, actual);
    } catch {
      updateReactions(msg.id, msg.reactions);
    }
  };

  const headerLabel = !day
    ? "Live conversation"
    : day.is_today
      ? "Today's conversation"
      : formatDayLabel(day.date);

  return (
    <div className={styles.card}>
      <div className={styles.header}>
        <span className={`${styles.dot} ${!day?.is_today ? styles.archived : ""}`} />
        <span className={styles.headerTitle}>{headerLabel}</span>
        <button
          className={styles.headerBtn}
          onClick={() => setShowDayPicker(true)}
          disabled={days.length === 0}
          aria-label="Past chats"
        >
          <HistoryIcon />
          Past chats
        </button>
      </div>

      <div className={styles.messages} ref={messagesRef}>
        {loading && !day && (
          <div className={styles.loadingState}>Loading conversation…</div>
        )}
        {error && !day && (
          <div className={styles.loadingState}>
            {error}{" "}
            <button
              onClick={() => load()}
              style={{
                background: "transparent", border: "none", color: "#e63946",
                cursor: "pointer", fontWeight: 700, marginLeft: 6,
              }}
            >
              Retry
            </button>
          </div>
        )}
        {day && day.messages.length === 0 && (
          <div className={styles.emptyState}>
            No messages yet — start the conversation!
          </div>
        )}
        {day?.messages.map((m) => (
          <div key={m.id} className={styles.messageWrap}>
            <MessageRow
              m={m}
              day={day}
              onReact={react}
              onReply={startReply}
              emojiOpenFor={emojiOpenFor}
              setEmojiOpenFor={setEmojiOpenFor}
              isReply={false}
            />
            {m.replies && m.replies.length > 0 && (
              <div className={styles.replies}>
                {m.replies.map((r) => (
                  <MessageRow
                    key={r.id}
                    m={r}
                    day={day}
                    onReact={react}
                    onReply={startReply}
                    emojiOpenFor={emojiOpenFor}
                    setEmojiOpenFor={setEmojiOpenFor}
                    isReply
                  />
                ))}
              </div>
            )}
          </div>
        ))}
      </div>

      {day?.is_today !== false ? (
        <div className={styles.composerWrap}>
          {replyTo && (
            <div className={styles.replyChip}>
              <span className={styles.replyChipArrow}>↩</span>
              <span className={styles.replyChipLabel}>
                Replying to <strong>{replyTo.name}</strong>
                <span className={styles.replyChipPreview}>{replyTo.message}</span>
              </span>
              <button
                type="button"
                className={styles.replyChipCancel}
                onClick={() => setReplyTo(null)}
                aria-label="Cancel reply"
              >
                ×
              </button>
            </div>
          )}
          <div className={styles.composer}>
            <button
              className={styles.nameBtn}
              title="Set display name"
              onClick={openNamePrompt}
              aria-label="Set display name"
            >
              <PersonIcon />
            </button>
            <input
              ref={composerRef}
              className={styles.input}
              placeholder={
                replyTo
                  ? `Reply to ${replyTo.name}…`
                  : name
                    ? `Say something as ${name}…`
                    : "Say something (tap to set your name)…"
              }
              value={text}
              maxLength={500}
              onChange={(e) => setText(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Escape" && replyTo) {
                  e.preventDefault();
                  setReplyTo(null);
                  return;
                }
                if (e.key === "Enter" && !e.shiftKey) {
                  e.preventDefault();
                  send();
                }
              }}
            />
            <button
              className={styles.sendBtn}
              onClick={send}
              disabled={sending || text.trim().length === 0}
              aria-label={replyTo ? "Send reply" : "Send"}
            >
              <SendIcon />
            </button>
          </div>
        </div>
      ) : (
        <div className={styles.archiveNotice}>
          <LockIcon />
          Archived chat — read only
          <button onClick={() => { setSelectedDate(null); }}>
            Back to today
          </button>
        </div>
      )}

      {showDayPicker && (
        <div className={styles.modalOverlay} onClick={() => setShowDayPicker(false)}>
          <div className={styles.modal} onClick={(e) => e.stopPropagation()}>
            <div className={styles.modalHeader}>
              <h3>Past conversations</h3>
              <p>Pick a day to read that conversation</p>
            </div>
            <div className={styles.modalBody}>
              <div
                className={`${styles.dayItem} ${!selectedDate ? styles.active : ""}`}
                onClick={() => { setSelectedDate(null); setShowDayPicker(false); }}
              >
                <span className={styles.dayIcon} style={{ color: "#e63946" }}>●</span>
                <div className={styles.dayLabel}>Today (live)</div>
              </div>
              {days.map((d) => (
                <div
                  key={d.date}
                  className={`${styles.dayItem} ${selectedDate === d.date ? styles.active : ""}`}
                  onClick={() => { setSelectedDate(d.date); setShowDayPicker(false); }}
                >
                  <span className={styles.dayIcon}>💬</span>
                  <div className={styles.dayLabel}>{formatDayLabel(d.date)}</div>
                  <div className={styles.dayCount}>{d.count} message{d.count === 1 ? "" : "s"}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {showNamePrompt && (
        <div className={styles.modalOverlay} onClick={() => setShowNamePrompt(false)}>
          <div className={styles.modal} onClick={(e) => e.stopPropagation()} style={{ maxWidth: 380 }}>
            <div className={styles.modalHeader}>
              <h3>Your display name</h3>
              <p>How should other viewers see you in chat?</p>
            </div>
            <div style={{ padding: "16px 20px" }}>
              <input
                autoFocus
                className={styles.nameInput}
                value={pendingName}
                maxLength={40}
                onChange={(e) => setPendingName(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && saveName()}
                placeholder="e.g. Kip from Nairobi"
              />
            </div>
            <div className={styles.modalFooter}>
              <button className={styles.cancelBtn} onClick={() => setShowNamePrompt(false)}>
                Cancel
              </button>
              <button className={styles.primaryBtn} onClick={saveName}>
                Save
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

interface MessageRowProps {
  m: ApiLiveChatMessage;
  day: ApiLiveChatDay;
  onReact: (m: ApiLiveChatMessage, emoji: string) => void;
  onReply: (m: ApiLiveChatMessage) => void;
  emojiOpenFor: number | null;
  setEmojiOpenFor: (id: number | null) => void;
  isReply: boolean;
}

function MessageRow({ m, day, onReact, onReply, emojiOpenFor, setEmojiOpenFor, isReply }: MessageRowProps) {
  return (
    <div className={`${styles.message} ${isReply ? styles.replyMessage : ""}`}>
      <div className={styles.avatar} style={{ background: colorForName(m.name) }}>
        {m.name.charAt(0).toUpperCase()}
      </div>
      <div className={styles.bubble}>
        <div className={styles.bubbleInner}>
          <span className={styles.author}>{m.name}</span>
          <span className={styles.body}>{m.message}</span>
        </div>
        <div className={styles.actions}>
          {day.is_today && (
            <>
              <div className={styles.addReaction}>
                <button
                  className={styles.addReactionBtn}
                  onClick={() => setEmojiOpenFor(emojiOpenFor === m.id ? null : m.id)}
                >
                  React
                </button>
                {emojiOpenFor === m.id && (
                  <div
                    className={styles.emojiPop}
                    onMouseLeave={() => setEmojiOpenFor(null)}
                  >
                    {day.allowed_emojis.map((e) => (
                      <button key={e} onClick={() => onReact(m, e)}>{e}</button>
                    ))}
                  </div>
                )}
              </div>
              <button
                type="button"
                className={styles.replyBtn}
                onClick={() => onReply(m)}
                aria-label={`Reply to ${m.name}`}
              >
                Reply
              </button>
            </>
          )}
          <span className={styles.time}>{formatTime(m.created_at)}</span>
          {Object.entries(m.reactions).map(([emoji, count]) => (
            <button
              key={emoji}
              className={styles.reactionChip}
              onClick={() => onReact(m, emoji)}
              disabled={!day.is_today}
            >
              <span>{emoji}</span>
              <span>{count}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

function HistoryIcon() {
  return (<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round"><path d="M3 12a9 9 0 1 0 3-6.7"/><path d="M3 4v5h5"/><path d="M12 8v5l3 2"/></svg>);
}
function ReplyIcon() {
  return (<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M9 17 4 12l5-5"/><path d="M20 18v-2a4 4 0 0 0-4-4H4"/></svg>);
}
function SendIcon() {
  return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M2 21l21-9L2 3v7l15 2-15 2z"/></svg>);
}
function PersonIcon() {
  return (<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 4-6 8-6s8 2 8 6"/></svg>);
}
function LockIcon() {
  return (<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="4" y="10" width="16" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg>);
}
