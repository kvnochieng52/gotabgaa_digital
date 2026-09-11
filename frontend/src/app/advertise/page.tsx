import Link from "next/link";
import styles from "./page.module.css";

export const metadata = {
  title: "Advertise with us",
  description: "Reach the Kalenjin community across Kenya and the diaspora on Gotabgaa TV — live broadcast, digital, radio and social.",
};

const PACKAGES = [
  {
    name: "Starter",
    tag: "For small businesses",
    price: "KSh 25,000",
    period: "/ week",
    features: [
      "1 banner ad on gotabgaa.co.ke",
      "3 mentions on Prime Time News",
      "Post on Facebook & WhatsApp channel",
      "Basic performance report",
    ],
    accent: false,
  },
  {
    name: "Growth",
    tag: "Most popular",
    price: "KSh 85,000",
    period: "/ month",
    features: [
      "Homepage takeover — 7 days",
      "30-second TV spot × 15 airings",
      "Sponsored article + video short",
      "Weekly analytics dashboard",
      "Dedicated account manager",
    ],
    accent: true,
  },
  {
    name: "Premier",
    tag: "For campaigns & brands",
    price: "Custom",
    period: "",
    features: [
      "Show or program sponsorship",
      "60-second TV spots × unlimited",
      "Live event coverage & branded content",
      "Cross-channel amplification",
      "Bespoke content team",
    ],
    accent: false,
  },
];

const STATS = [
  { value: "500K+", label: "Weekly reach" },
  { value: "24/7", label: "Live broadcast" },
  { value: "9", label: "Countries" },
  { value: "3", label: "Languages" },
];

export default function AdvertisePage() {
  return (
    <>
      <section className={styles.hero}>
        <div className={styles.orbA} />
        <div className={styles.orbB} />
        <div className={styles.grid} />

        <div className={`container ${styles.heroInner}`}>
          <div className={styles.eyebrow}>
            <span className={styles.dot} /> Partner with Gotabgaa TV
          </div>
          <h1 className={styles.title}>
            Reach the <span className="gradient-text">Kalenjin community</span>{" "}
            wherever they live.
          </h1>
          <p className={styles.subtitle}>
            Your brand on the largest media platform serving Kenya&apos;s Kalenjin
            community — home and diaspora. Live TV, radio, digital, and social —
            one partner, every channel.
          </p>

          <div className={styles.heroCtas}>
            <a href="#packages" className={styles.primaryBtn}>See our packages</a>
            <Link href="/contact/" className={styles.ghostBtn}>Talk to sales</Link>
          </div>

          <div className={styles.stats}>
            {STATS.map((s) => (
              <div key={s.label}>
                <strong>{s.value}</strong>
                <span>{s.label}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Why us */}
      <section className={styles.why}>
        <div className={`container ${styles.whyGrid}`}>
          <div>
            <div className="eyebrow">Why advertise with us</div>
            <h2 className={styles.whyTitle}>
              A trusted platform in every Kalenjin household.
            </h2>
            <p className={styles.whyText}>
              Gotabgaa TV is the number-one Kalenjin-language broadcaster with a
              growing digital audience across Kenya, the US, UK and Middle East.
              We combine mass reach with the intimacy of community media —
              exactly where high-intent buyers are watching, listening and reading.
            </p>
          </div>
          <ul className={styles.whyList}>
            <li>
              <strong>Live + on-demand.</strong> Your message appears in the same feed as our
              news, sports and cultural programming.
            </li>
            <li>
              <strong>Diaspora-first.</strong> We&apos;re where the diaspora finds home content —
              your product travels with them.
            </li>
            <li>
              <strong>Full production.</strong> Our in-house team can shoot, edit and script
              your creative end-to-end.
            </li>
            <li>
              <strong>Transparent analytics.</strong> Weekly dashboards showing views, reach,
              engagement — no black boxes.
            </li>
          </ul>
        </div>
      </section>

      {/* Packages */}
      <section id="packages" className={styles.packages}>
        <div className="container">
          <div style={{ textAlign: "center", marginBottom: 40 }}>
            <div className="eyebrow" style={{ justifyContent: "center", display: "inline-flex" }}>Packages</div>
            <h2 className={styles.packagesTitle}>Simple, transparent pricing.</h2>
            <p className={styles.packagesSubtitle}>
              Every package includes creative support, a live dashboard, and a dedicated point of contact.
            </p>
          </div>

          <div className={styles.packageGrid}>
            {PACKAGES.map((p) => (
              <article key={p.name} className={`${styles.package} ${p.accent ? styles.packageAccent : ""}`}>
                {p.accent && <span className={styles.packageBadge}>Most popular</span>}
                <div className={styles.packageHead}>
                  <div className={styles.packageTag}>{p.tag}</div>
                  <h3>{p.name}</h3>
                </div>
                <div className={styles.packagePrice}>
                  <strong>{p.price}</strong>
                  {p.period && <span>{p.period}</span>}
                </div>
                <ul>
                  {p.features.map((f) => (
                    <li key={f}>
                      <CheckIcon />
                      {f}
                    </li>
                  ))}
                </ul>
                <Link href="/contact/?ref=advertise" className={p.accent ? styles.packageCtaAccent : styles.packageCta}>
                  Get started
                </Link>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className={styles.finalCta}>
        <div className={`container ${styles.finalCtaInner}`}>
          <div>
            <h2>Ready to talk?</h2>
            <p>Tell us about your brand and we&apos;ll propose the right mix.</p>
          </div>
          <Link href="/contact/?ref=advertise" className={styles.finalCtaBtn}>
            Start a conversation
            <ArrowIcon />
          </Link>
        </div>
      </section>
    </>
  );
}

function CheckIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 6 9 17l-5-5" />
    </svg>
  );
}
function ArrowIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12h14" />
      <path d="m13 5 7 7-7 7" />
    </svg>
  );
}
