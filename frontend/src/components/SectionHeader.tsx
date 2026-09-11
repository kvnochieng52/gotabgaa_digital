import Link from "next/link";
import styles from "./SectionHeader.module.css";

interface SectionHeaderProps {
  eyebrow?: string;
  title: string;
  href?: string;
  cta?: string;
}

export function SectionHeader({ eyebrow, title, href, cta = "See all" }: SectionHeaderProps) {
  return (
    <div className={styles.wrap}>
      <div>
        {eyebrow && <div className="eyebrow">{eyebrow}</div>}
        <h2 className={styles.title}>{title}</h2>
      </div>
      {href && (
        <Link href={href} className={styles.cta}>
          {cta}
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M5 12h14" />
            <path d="m13 5 7 7-7 7" />
          </svg>
        </Link>
      )}
    </div>
  );
}
