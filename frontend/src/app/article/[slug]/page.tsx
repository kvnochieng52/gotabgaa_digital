import { ArticleView } from "@/components/ArticleView";
import { API_BASE } from "@/lib/api";

// At build time, fetch every article slug so each gets its own static HTML.
// If the API is unreachable, we return no static params and dev still works
// because the client component fetches by slug on mount.
export async function generateStaticParams() {
  try {
    const res = await fetch(`${API_BASE}/api/v1/articles?limit=200`, {
      cache: "no-store",
    });
    if (!res.ok) return [];
    const json = (await res.json()) as { data: { slug: string }[] };
    return json.data.map((a) => ({ slug: a.slug }));
  } catch {
    return [];
  }
}

export async function generateMetadata({ params }: PageProps<"/article/[slug]">) {
  const { slug } = await params;
  try {
    const res = await fetch(`${API_BASE}/api/v1/articles/${slug}`, { cache: "no-store" });
    if (!res.ok) return { title: "Article" };
    const { data } = (await res.json()) as { data: { title: string; excerpt: string | null } };
    return {
      title: data.title,
      description: data.excerpt ?? undefined,
      openGraph: {
        title: data.title,
        description: data.excerpt ?? undefined,
        type: "article",
      },
    };
  } catch {
    return { title: "Article" };
  }
}

export default async function ArticlePage({ params }: PageProps<"/article/[slug]">) {
  const { slug } = await params;
  return <ArticleView slug={slug} />;
}
