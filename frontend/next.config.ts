import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Static export — produces plain HTML/CSS/JS in `out/` for deployment
  // to cPanel / any Apache host. Upload contents of `out/` to public_html/.
  output: "export",

  // Required because static export disables the built-in image optimizer.
  images: { unoptimized: true },

  // Emit trailing-slash URLs (better with Apache; /about -> /about/index.html).
  trailingSlash: true,
};

export default nextConfig;
