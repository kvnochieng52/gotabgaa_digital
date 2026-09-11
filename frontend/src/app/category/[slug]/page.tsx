import { NewsList } from "@/components/NewsList";
import styles from "./page.module.css";

// Statically generate the categories we imported. Client-side fetch handles
// content — this list just declares which paths exist at build time.
const KNOWN_SLUGS = [
  "news", "politics", "sports", "business", "health",
  "agriculture", "entertainment", "culture", "education",
];

export async function generateStaticParams() {
  return KNOWN_SLUGS.map((slug) => ({ slug }));
}

export async function generateMetadata({ params }: PageProps<"/category/[slug]">) {
  const { slug } = await params;
  const nice = slug.charAt(0).toUpperCase() + slug.slice(1);
  return {
    title: nice,
    description: `${nice} — stories from Gotabgaa TV.`,
  };
}

export default async function CategoryPage({ params }: PageProps<"/category/[slug]">) {
  const { slug } = await params;
  const nice = slug.charAt(0).toUpperCase() + slug.slice(1);

  return (
    <>
      <section className={styles.hero}>
        <div className={styles.orb} />
        <div className={`container ${styles.heroInner}`}>
          <div className="eyebrow">Section</div>
          <h1>
            <span className="gradient-text">{nice}</span>
          </h1>
        </div>
      </section>

      <section className={styles.section}>
        <div className="container">
          <NewsList categorySlug={slug} />
        </div>
      </section>
    </>
  );
}
