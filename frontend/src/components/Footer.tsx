import Link from "next/link";
import Image from "next/image";
import styles from "./Footer.module.css";

const YEAR = new Date().getFullYear();

const SOCIAL = [
  { href: "#", label: "Facebook", icon: FacebookIcon },
  { href: "#", label: "X (Twitter)", icon: XIcon },
  { href: "#", label: "Instagram", icon: InstagramIcon },
  { href: "#", label: "YouTube", icon: YouTubeIcon },
  { href: "#", label: "WhatsApp", icon: WhatsAppIcon },
];

export function Footer() {
  return (
    <footer className={styles.footer}>
      <div className="container">
        <div className={styles.top}>
          <div className={styles.brand}>
            <Image src="/logo.png" alt="Gotabgaa Digital" width={200} height={110} className={styles.brandLogo} />
            <p>
              Gotabgaa Digital is the online and media arm of Gotabgaa International —
              connecting the Kalenjin community around the world through news, live TV,
              radio, and on-demand content.
            </p>
            <div className={styles.socials}>
              {SOCIAL.map(({ href, label, icon: Icon }) => (
                <Link key={label} href={href} aria-label={label} className={styles.social}>
                  <Icon />
                </Link>
              ))}
            </div>
          </div>

          <div>
            <h4>Explore</h4>
            <ul>
              <li><Link href="/">Home</Link></li>
              <li><Link href="/news/">News</Link></li>
              <li><Link href="/live-tv/">Live TV</Link></li>
              <li><Link href="/radio/">Live Radio</Link></li>
              <li><Link href="/catch-up/">Catch Up</Link></li>
            </ul>
          </div>

          <div>
            <h4>Sections</h4>
            <ul>
              <li><Link href="/category/politics/">Politics</Link></li>
              <li><Link href="/category/sports/">Sports</Link></li>
              <li><Link href="/category/culture/">Culture</Link></li>
              <li><Link href="/category/diaspora/">Diaspora</Link></li>
              <li><Link href="/category/business/">Business</Link></li>
            </ul>
          </div>

          <div className={styles.newsletter}>
            <h4>Newsletter</h4>
            <p>Top stories and program schedules, delivered weekly.</p>
            <form className={styles.newsletterForm}>
              <input type="email" placeholder="you@example.com" required />
              <button type="submit">Subscribe</button>
            </form>
          </div>
        </div>

        <div className={styles.bottom}>
          <span>© {YEAR} Gotabgaa Digital. All rights reserved.</span>
          <div className={styles.legal}>
            <Link href="#">Privacy</Link>
            <span>·</span>
            <Link href="#">Terms</Link>
            <span>·</span>
            <Link href="#">Contact</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}

/* --- Inline SVG icons --- */
function FacebookIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M22 12a10 10 0 1 0-11.6 9.9V15h-2.5v-3h2.5V9.8c0-2.5 1.5-3.9 3.8-3.9 1.1 0 2.2.2 2.2.2v2.5h-1.3c-1.2 0-1.6.8-1.6 1.6V12h2.7l-.4 3h-2.3V22A10 10 0 0 0 22 12Z"/></svg>); }
function XIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M17.53 3H21l-7.55 8.63L22 21h-6.8l-5.32-6.96L3.79 21H.32l8.07-9.24L1 3h6.94l4.82 6.4L17.53 3Zm-1.2 16.2h1.88L7.75 4.7H5.73l10.6 14.5Z"/></svg>); }
function InstagramIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor"/></svg>); }
function YouTubeIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M23 12s0-3.7-.5-5.4a2.8 2.8 0 0 0-2-2C18.9 4 12 4 12 4s-6.9 0-8.5.6a2.8 2.8 0 0 0-2 2C1 8.3 1 12 1 12s0 3.7.5 5.4c.3 1 1 1.7 2 2 1.6.6 8.5.6 8.5.6s6.9 0 8.5-.6a2.8 2.8 0 0 0 2-2c.5-1.7.5-5.4.5-5.4Zm-13 3.5V8.5l6 3.5-6 3.5Z"/></svg>); }
function WhatsAppIcon() { return (<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M20.5 3.5A11 11 0 0 0 2.7 17.1L1 23l6-1.5a11 11 0 0 0 5 1.2 11 11 0 0 0 8.5-19.2ZM12 20.8a9 9 0 0 1-4.5-1.2l-.4-.2-3.5.9.9-3.4-.2-.4A9 9 0 1 1 12 20.8Zm5-6.7c-.3-.1-1.6-.8-1.8-.9-.3-.1-.5-.1-.6.1-.2.3-.7.9-.9 1.1-.2.2-.3.2-.6.1-.3-.1-1.2-.4-2.4-1.5-.9-.8-1.5-1.7-1.6-2s0-.4.1-.6c.1-.1.3-.3.4-.5.1-.1.2-.2.3-.4 0-.2 0-.4 0-.6l-.9-2.1c-.2-.5-.5-.4-.6-.4h-.5c-.2 0-.5.1-.7.3-.3.3-1 1-1 2.5s1.1 2.9 1.2 3.1c.1.2 2.1 3.3 5.1 4.6 2.5 1.1 3 .9 3.6.9.6 0 1.8-.8 2-1.5.2-.7.2-1.4.2-1.5-.1-.2-.3-.3-.6-.4Z"/></svg>); }
