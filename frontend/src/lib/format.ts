const DATE_FMT = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
});

const TIME_AGO_UNITS: [Intl.RelativeTimeFormatUnit, number][] = [
  ["year", 60 * 60 * 24 * 365],
  ["month", 60 * 60 * 24 * 30],
  ["week", 60 * 60 * 24 * 7],
  ["day", 60 * 60 * 24],
  ["hour", 60 * 60],
  ["minute", 60],
];

const RTF = new Intl.RelativeTimeFormat("en", { numeric: "auto" });

export function formatDate(iso: string) {
  return DATE_FMT.format(new Date(iso));
}

export function timeAgo(iso: string) {
  const seconds = (Date.now() - new Date(iso).getTime()) / 1000;
  for (const [unit, secs] of TIME_AGO_UNITS) {
    if (Math.abs(seconds) >= secs) {
      return RTF.format(-Math.round(seconds / secs), unit);
    }
  }
  return "just now";
}

export function formatViews(n: number) {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`;
  return `${n}`;
}

/**
 * Parse "#E63946|#FF7A1A" into a diagonal gradient CSS value.
 */
export function gradient(spec: string, angle = 135): string {
  const [a, b] = spec.split("|");
  return `linear-gradient(${angle}deg, ${a} 0%, ${b} 100%)`;
}
