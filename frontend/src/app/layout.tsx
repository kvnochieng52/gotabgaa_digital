import type { Metadata, Viewport } from "next";
import { Inter, Poppins } from "next/font/google";
import Script from "next/script";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import "./globals.css";

const inter = Inter({
  variable: "--font-sans",
  subsets: ["latin"],
  display: "swap",
});

const poppins = Poppins({
  variable: "--font-display",
  subsets: ["latin"],
  weight: ["500", "600", "700", "800", "900"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Gotabgaa Digital — Live TV, Radio & News",
    template: "%s · Gotabgaa Digital",
  },
  description:
    "The voice of the Kalenjin diaspora. Live TV, radio, breaking news, and on-demand shows from Gotabgaa International.",
  metadataBase: new URL("https://gotabgaa.digital"),
  openGraph: {
    title: "Gotabgaa Digital",
    description: "Live TV, radio and news for the Kalenjin diaspora.",
    url: "https://gotabgaa.digital",
    siteName: "Gotabgaa Digital",
    locale: "en_US",
    type: "website",
  },
  icons: {
    icon: "/logo.png",
  },
};

export const viewport: Viewport = {
  themeColor: "#08080A",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
};

const THEME_SCRIPT = `(function(){try{var q=new URL(location.href).searchParams.get('theme');var t=q==='light'||q==='dark'?q:localStorage.getItem('gotabgaa-theme');if(t!=='light'&&t!=='dark'){t='light';}document.documentElement.setAttribute('data-theme',t);if(q){localStorage.setItem('gotabgaa-theme',t);}}catch(e){document.documentElement.setAttribute('data-theme','light');}})();`;

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" data-theme="light" className={`${inter.variable} ${poppins.variable}`}>
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
        <Script id="gotabgaa-theme-init" strategy="beforeInteractive">
          {THEME_SCRIPT}
        </Script>
      </body>
    </html>
  );
}
