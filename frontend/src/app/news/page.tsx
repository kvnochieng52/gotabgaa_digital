import { NewsList } from "@/components/NewsList";
import styles from "./page.module.css";

export const metadata = {
  title: "News",
  description: "Breaking stories, features, and analysis from Gotabgaa TV.",
};

export default function NewsPage() {
  return (
    <>
      <section className={styles.hero}>
        <div className="container">
          <div className="eyebrow">Newsroom</div>
          <h1 className={styles.title}>Latest news</h1>
          <p className={styles.subtitle}>
            Reporting from the heart of the Kalenjin community — the stories that shape our
            people, at home and in the diaspora.
          </p>
        </div>
      </section>

      <section className={styles.section}>
        <div className="container">
          <NewsList />
        </div>
      </section>
    </>
  );
}
