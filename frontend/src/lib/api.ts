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
