import styles from "./LiveBadge.module.css";

interface LiveBadgeProps {
  label?: string;
  variant?: "solid" | "outline";
}

export function LiveBadge({ label = "LIVE", variant = "solid" }: LiveBadgeProps) {
  return (
    <span className={variant === "solid" ? styles.solid : styles.outline}>
      <span className={styles.dot} />
      {label}
    </span>
  );
}
