import { ArticleView } from "@/components/ArticleView";
import { API_BASE } from "@/lib/api";

// At build time, fetch every article slug so each gets its own static HTML.
// If the API is unreachable (e.g. first deploy — nginx not up yet), we return
// a single sentinel slug. Next.js 16 requires at least one route for a dynamic
// segment under `output: "export"`, and this guarantees the build succeeds.
// Real routes are added by the NEXT redeploy once the backend is reachable.
const SENTINEL: { slug: string }[] = [{ slug: "sample" }];

export async function generateStaticParams() {
  try {
    const res = await fetch(`${API_BASE}/api/v1/articles?limit=200`, {
      cache: "no-store",
      // Short timeout — if the API isn't up we don't want to hang the build.
      signal: AbortSignal.timeout(8000),
    });
    if (!res.ok) return SENTINEL;
    const json = (await res.json()) as { data: { slug: string }[] };
    const params = json.data.map((a) => ({ slug: a.slug }));
    return params.length > 0 ? params : SENTINEL;
  } catch {
    return SENTINEL;
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
