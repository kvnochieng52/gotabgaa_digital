"use client";

import { useEffect, useState } from "react";
import {
  getArticleComments,
  postArticleComment,
  type ApiArticleComment,
} from "@/lib/api";
import styles from "./ArticleComments.module.css";

const NAME_KEY = "gotabgaa_comment_name";
const EMAIL_KEY = "gotabgaa_comment_email";

function formatWhen(iso: string) {
  try {
    const d = new Date(iso);
    return d.toLocaleString([], {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  } catch {
    return "";
  }
}

interface Props { slug: string; }

export function ArticleComments({ slug }: Props) {
  const [comments, setComments] = useState<ApiArticleComment[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sending, setSending] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [body, setBody] = useState("");
  const [formError, setFormError] = useState<string | null>(null);

  useEffect(() => {
    if (typeof window === "undefined") return;
    setName(localStorage.getItem(NAME_KEY) ?? "");
    setEmail(localStorage.getItem(EMAIL_KEY) ?? "");
  }, []);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    getArticleComments(slug)
      .then((cs) => { if (!cancelled) { setComments(cs); setError(null); } })
      .catch(() => { if (!cancelled) setError("Could not load comments"); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [slug]);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    if (!name.trim() || !body.trim()) {
      setFormError("Name and comment are required");
      return;
    }
    setSending(true);
    try {
      const created = await postArticleComment(slug, {
        name: name.trim(),
        email: email.trim() || undefined,
        body: body.trim(),
      });
      localStorage.setItem(NAME_KEY, name.trim());
      if (email.trim()) localStorage.setItem(EMAIL_KEY, email.trim());
      setComments((c) => [created, ...(c ?? [])]);
      setBody("");
    } catch {
      setFormError("Could not post your comment");
    } finally {
      setSending(false);
    }
  };

  const count = comments?.length ?? 0;

  return (
    <div className={styles.wrap}>
      <div className={styles.header}>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
        </svg>
        <h2>Comments{count > 0 ? ` · ${count}` : ""}</h2>
      </div>

      <form className={styles.composer} onSubmit={submit}>
        <div className={styles.composerRow}>
          <input
            type="text"
            placeholder="Your name"
            value={name}
            maxLength={60}
            onChange={(e) => setName(e.target.value)}
            required
          />
          <input
            type="email"
            placeholder="Email (optional)"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <textarea
          placeholder="Share your thoughts…"
          value={body}
          maxLength={2000}
          onChange={(e) => setBody(e.target.value)}
          required
        />
        {formError && <div className={styles.error}>{formError}</div>}
        <div className={styles.actions}>
          <button type="submit" className={styles.submitBtn} disabled={sending}>
            {sending ? "Posting…" : "Post comment"}
          </button>
        </div>
      </form>

      {loading && <div className={styles.empty}>Loading comments…</div>}
      {error && !loading && <div className={styles.empty}>{error}</div>}
      {!loading && !error && comments && comments.length === 0 && (
        <div className={styles.empty}>Be the first to comment.</div>
      )}

      <div className={styles.list}>
        {comments?.map((c) => (
          <article key={c.id} className={styles.comment}>
            <div className={styles.avatar}>{c.name.charAt(0).toUpperCase()}</div>
            <div className={styles.commentBody}>
              <div className={styles.commentMeta}>
                <span className={styles.commentAuthor}>{c.name}</span>
                <span className={styles.commentTime}>{formatWhen(c.created_at)}</span>
              </div>
              <div className={styles.commentText}>{c.body}</div>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}
