"use client";

import { useState } from "react";
import { API_BASE } from "@/lib/api";
import styles from "./ContactForm.module.css";

type Status = "idle" | "sending" | "sent" | "error";

const SUBJECTS = [
  "General enquiry",
  "News tip",
  "Advertising",
  "Partnership",
  "Careers",
  "Other",
];

export function ContactForm() {
  const [status, setStatus] = useState<Status>("idle");
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setStatus("sending");
    setError(null);

    const form = e.currentTarget;
    const data = Object.fromEntries(new FormData(form).entries());

    try {
      const res = await fetch(`${API_BASE}/api/v1/contact`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(data),
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.message ?? `Server returned ${res.status}`);
      }
      setStatus("sent");
      form.reset();
    } catch (e) {
      setStatus("error");
      setError(e instanceof Error ? e.message : "Failed to send. Please try again.");
    }
  };

  if (status === "sent") {
    return (
      <div className={styles.success}>
        <div className={styles.successIcon}>
          <CheckIcon />
        </div>
        <h2>Message sent</h2>
        <p>
          Thanks for reaching out. A member of our team will get back to you within one business day.
        </p>
        <button
          type="button"
          onClick={() => setStatus("idle")}
          className={styles.successBtn}
        >
          Send another message
        </button>
      </div>
    );
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit} noValidate>
      <div className="eyebrow" style={{ marginBottom: 12 }}>Send us a message</div>
      <h2 className={styles.formTitle}>We&apos;ll reply within a business day.</h2>

      <div className={styles.row}>
        <label className={styles.field}>
          <span>Full name *</span>
          <input name="name" type="text" required placeholder="Chelagat Kiprop" />
        </label>
        <label className={styles.field}>
          <span>Email *</span>
          <input name="email" type="email" required placeholder="you@example.com" />
        </label>
      </div>

      <div className={styles.row}>
        <label className={styles.field}>
          <span>Phone (optional)</span>
          <input name="phone" type="tel" placeholder="+254 700 000 000" />
        </label>
        <label className={styles.field}>
          <span>Subject *</span>
          <select name="subject" required defaultValue="">
            <option value="" disabled>Choose one</option>
            {SUBJECTS.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        </label>
      </div>

      <label className={styles.field}>
        <span>Message *</span>
        <textarea name="message" rows={6} required placeholder="Tell us how we can help…" />
      </label>

      {error && <div className={styles.error}>{error}</div>}

      <div className={styles.actions}>
        <button
          type="submit"
          className={styles.submit}
          disabled={status === "sending"}
        >
          {status === "sending" ? "Sending…" : "Send message"}
        </button>
        <span className={styles.privacy}>We&apos;ll never share your details.</span>
      </div>
    </form>
  );
}

function CheckIcon() {
  return (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 6 9 17l-5-5" />
    </svg>
  );
}
