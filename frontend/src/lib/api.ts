export const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

export async function apiFetch<T = unknown>(path: string, init?: RequestInit): Promise<T> {
  const url = `${API_BASE}/api/v1${path.startsWith("/") ? path : `/${path}`}`;
  const res = await fetch(url, {
    ...init,
    headers: {
      Accept: "application/json",
      ...(init?.headers ?? {}),
    },
  });
  if (!res.ok) {
    throw new Error(`API ${res.status} on ${path}`);
  }
  return res.json() as Promise<T>;
}

// ---------- Types ----------
export interface ApiArticle {
  slug: string;
  title: string;
  excerpt: string | null;
  body?: string;
  category: string | null;
  categorySlug: string | null;
  author: { name: string };
  publishedAt: string | null;
  readingTime: number;
  image: string; // Gradient spec "#hex|#hex" or full URL
  youtubeUrl: string | null;
  featured: boolean;
  breaking: boolean;
  isShort: boolean;
  viewCount: number;
  likeCount: number;
  tags: string[];
}

export interface ApiCategory {
  slug: string;
  name: string;
  color: string | null;
  articleCount: number;
}

export interface StreamSettings {
  tvTitle: string;
  tvStreamUrl: string | null;
  radioTitle: string;
  radioFrequency: string | null;
  radioStreamUrl: string | null;
}

export interface SettingsResponse {
  stream: StreamSettings;
  social: Record<string, string | null>;
}

// ---------- Endpoints ----------
export function getSettings() {
  return apiFetch<SettingsResponse>("/settings");
}

export function getCategories() {
  return apiFetch<ApiCategory[]>("/categories");
}

export async function getArticles(opts: {
  limit?: number;
  category?: string;
  featured?: boolean;
  breaking?: boolean;
} = {}): Promise<ApiArticle[]> {
  const params = new URLSearchParams();
  if (opts.limit) params.set("limit", String(opts.limit));
  if (opts.category) params.set("category", opts.category);
  if (opts.featured) params.set("featured", "1");
  if (opts.breaking) params.set("breaking", "1");
  const qs = params.toString();
  const path = qs ? `/articles?${qs}` : "/articles";
  const res = await apiFetch<{ data: ApiArticle[] }>(path);
  return res.data;
}

export async function getArticle(slug: string): Promise<ApiArticle> {
  const res = await apiFetch<{ data: ApiArticle }>(`/articles/${slug}`);
  return res.data;
}

// ---------- Polls ----------
export interface ApiPollOption {
  id: string;
  label: string;
  votes: number;
}

export interface ApiPoll {
  slug: string;
  question: string;
  options: ApiPollOption[];
  active: boolean;
  closesAt: string | null;
  totalVotes: number;
}

export async function getActivePoll(): Promise<ApiPoll | null> {
  const res = await apiFetch<{ poll: ApiPoll | null }>("/poll");
  return res.poll;
}

// ---------- Live chat ----------
export interface ApiLiveChatMessage {
  id: number;
  parent_id: number | null;
  name: string;
  message: string;
  created_at: string;
  reactions: Record<string, number>;
  replies?: ApiLiveChatMessage[];
}

export interface ApiLiveChatDay {
  date: string; // YYYY-MM-DD
  is_today: boolean;
  messages: ApiLiveChatMessage[];
  allowed_emojis: string[];
}

export interface ApiLiveChatDaySummary {
  date: string;
  count: number;
}

export async function getLiveChat(date?: string): Promise<ApiLiveChatDay> {
  const path = date ? `/live-chat?date=${encodeURIComponent(date)}` : "/live-chat";
  return apiFetch<ApiLiveChatDay>(path);
}

export async function getLiveChatDays(): Promise<ApiLiveChatDaySummary[]> {
  const res = await apiFetch<{ data: ApiLiveChatDaySummary[] }>("/live-chat/days");
  return res.data;
}

export async function postLiveChat(
  name: string,
  message: string,
  parentId?: number | null,
): Promise<ApiLiveChatMessage> {
  const url = `${API_BASE}/api/v1/live-chat`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify({
      name,
      message,
      ...(parentId ? { parent_id: parentId } : {}),
    }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(body?.message ?? "Failed to post message");
  return body as ApiLiveChatMessage;
}

export async function reactLiveChat(
  id: number,
  emoji: string,
): Promise<Record<string, number>> {
  const url = `${API_BASE}/api/v1/live-chat/${id}/react`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify({ emoji }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(body?.message ?? "Failed to react");
  return body.reactions as Record<string, number>;
}

// ---------- Article comments ----------
export interface ApiArticleComment {
  id: number;
  name: string;
  body: string;
  created_at: string;
}

export async function getArticleComments(slug: string): Promise<ApiArticleComment[]> {
  const res = await apiFetch<{ data: ApiArticleComment[] }>(`/articles/${slug}/comments`);
  return res.data;
}

export async function postArticleComment(
  slug: string,
  payload: { name: string; email?: string; body: string },
): Promise<ApiArticleComment> {
  const url = `${API_BASE}/api/v1/articles/${slug}/comments`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify(payload),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(body?.message ?? "Failed to post comment");
  return body as ApiArticleComment;
}

export async function voteOnPoll(slug: string, optionId: string): Promise<ApiPoll> {
  const url = `${API_BASE}/api/v1/polls/${encodeURIComponent(slug)}/vote`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify({ option_id: optionId }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = body?.message ?? body?.errors?.option_id?.[0] ?? `Vote failed (HTTP ${res.status})`;
    throw new Error(msg);
  }
  return body.poll as ApiPoll;
}

/**
 * Convert an API article into the shape our existing card components expect.
 * Keeps ArticleCard/etc. working without touching them.
 */
export function apiToCardArticle(a: ApiArticle): {
  slug: string;
  title: string;
  excerpt: string;
  category: string;
  publishedAt: string;
  readingTime: number;
  image: string;
} {
  return {
    slug: a.slug,
    title: a.title,
    excerpt: a.excerpt ?? "",
    category: (a.category ?? "News") as string,
    publishedAt: a.publishedAt ?? new Date().toISOString(),
    readingTime: a.readingTime,
    image: a.image,
  };
}
