import { ContactForm } from "@/components/ContactForm";
import styles from "./page.module.css";

export const metadata = {
  title: "Contact us",
  description: "Get in touch with the Gotabgaa TV team — news tips, advertising enquiries, partnerships and more.",
};

export default function ContactPage() {
  return (
    <>
      <section className={styles.hero}>
        <div className={styles.orb} />
        <div className={`container ${styles.heroInner}`}>
          <div className="eyebrow">Say hello</div>
          <h1 className={styles.title}>
            Let&apos;s <span className="gradient-text">talk.</span>
          </h1>
          <p className={styles.subtitle}>
            News tip? Advertising enquiry? Community partnership? Whatever
            brings you here — we&apos;re listening.
          </p>
        </div>
      </section>

      <section className={styles.body}>
        <div className={`container ${styles.bodyGrid}`}>
          <ContactForm />
          <ContactDetails />
        </div>
      </section>
    </>
  );
}

function ContactDetails() {
  return (
    <aside className={styles.details}>
      <div className={styles.detailsBlock}>
        <h3>Newsroom</h3>
        <p>Have a story or a tip? Reach the editorial desk directly.</p>
        <a href="mailto:news@gotabgaa.co.ke" className={styles.link}>news@gotabgaa.co.ke</a>
      </div>

      <div className={styles.detailsBlock}>
        <h3>Advertising</h3>
        <p>Get your brand in front of the Kalenjin community — at home and abroad.</p>
        <a href="mailto:sales@gotabgaa.co.ke" className={styles.link}>sales@gotabgaa.co.ke</a>
      </div>

      <div className={styles.detailsBlock}>
        <h3>General</h3>
        <p>Everything else — feedback, partnerships, careers.</p>
        <a href="mailto:gotabgaatelevision@gmail.com" className={styles.link}>gotabgaatelevision@gmail.com</a>
      </div>

      <div className={styles.contactCard}>
        <div className={styles.contactRow}>
          <PhoneIcon />
          <div>
            <span>Call the newsroom</span>
            <strong><a href="tel:+254713176146">+254 713 176 146</a></strong>
          </div>
        </div>
        <div className={styles.contactRow}>
          <PinIcon />
          <div>
            <span>Studios</span>
            <strong>Kericho County, Kenya</strong>
          </div>
        </div>
        <div className={styles.contactRow}>
          <ClockIcon />
          <div>
            <span>Broadcast hours</span>
            <strong>24 / 7 · Live</strong>
          </div>
        </div>
      </div>
    </aside>
  );
}

function PhoneIcon() { return (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.37 1.9.72 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.35 1.85.59 2.81.72A2 2 0 0 1 22 16.92z"/></svg>); }
function PinIcon() { return (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/></svg>); }
function ClockIcon() { return (<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>); }
