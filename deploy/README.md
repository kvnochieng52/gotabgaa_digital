# Deploying Gotabgaa Digital

Minimal deploy guide for a Debian/Ubuntu VPS. No domain required — everything
runs on a random high port until you attach a domain.

## Architecture

One nginx server block handles everything. There is **no separate Node
process** — the Next.js frontend is built as static HTML and served directly
by nginx.

```
    Browser                                  VPS
    ─────────                              ─────────
    :8090/         ──────────────────▶  nginx
                                          │
                                          ├─ /             → frontend/out/*.html   (static)
                                          ├─ /_next/static → frontend/out/_next/…  (static, 1yr cache)
                                          ├─ /api/*        → PHP-FPM (Laravel)
                                          ├─ /admin        → PHP-FPM (Filament)
                                          ├─ /livewire     → PHP-FPM
                                          ├─ /storage      → static from Laravel public/
                                          └─ /*.php        → PHP-FPM
```

## Server prerequisites

Install once, on a fresh Ubuntu 22.04 / 24.04 box:

```bash
sudo apt update
sudo apt install -y \
    nginx \
    mysql-server \
    php8.2 php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml \
    php8.2-curl php8.2-zip php8.2-bcmath php8.2-gd php8.2-intl \
    php8.2-sqlite3 \
    composer git curl unzip

# Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# MySQL: create the app database + user
sudo mysql <<'SQL'
CREATE DATABASE gotabgaa_digital CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'gotabgaa'@'localhost' IDENTIFIED BY 'CHANGE_ME_STRONG_PASSWORD';
GRANT ALL PRIVILEGES ON gotabgaa_digital.* TO 'gotabgaa'@'localhost';
FLUSH PRIVILEGES;
SQL
```

## First-time deploy

```bash
# 1. Clone into /app
sudo mkdir -p /app
cd /app
sudo git clone https://github.com/kvnochieng52/gotabgaa_digital.git gotabgaa
sudo chown -R www-data:www-data /app/gotabgaa

# 2. Backend .env
cd gotabgaa
sudo -u www-data cp deploy/backend.env.example backend/.env
sudo -u www-data nano backend/.env         # set DB_PASSWORD, APP_URL, SERVER_IP

# 3. Frontend .env
sudo -u www-data cp deploy/frontend.env.example frontend/.env.production
sudo -u www-data nano frontend/.env.production   # set NEXT_PUBLIC_API_URL

# 4. Backend deps + app key + migration
cd backend
sudo -u www-data composer install --no-dev --optimize-autoloader
sudo -u www-data php artisan key:generate
sudo -u www-data php artisan migrate --seed --force
sudo -u www-data php artisan storage:link

# 5. Frontend deps + build
cd ../frontend
sudo -u www-data npm ci
sudo -u www-data npm run build

# 6. nginx site
sudo cp ../deploy/nginx/gotabgaa.conf /etc/nginx/sites-available/gotabgaa
sudo ln -s /etc/nginx/sites-available/gotabgaa /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 7. Open the port on the firewall
sudo ufw allow 8090/tcp

# 8. Visit http://YOUR_SERVER_IP:8090/
```

## Repeat deploys

After the first-time setup, deploying updates from `main` is one command:

```bash
cd /app/gotabgaa
sudo bash deploy/deploy.sh
```

The script pulls latest, installs deps, runs migrations, caches config,
rebuilds the frontend, and reloads nginx / PHP-FPM.

## Common tweaks

### Change the port

Edit `/etc/nginx/sites-available/gotabgaa` — swap `listen 8090;` for whatever
you want. Also update:

- `frontend/.env.production` → `NEXT_PUBLIC_API_URL`
- `backend/.env` → `APP_URL` and `CORS_ALLOWED_ORIGINS`
- The firewall rule: `sudo ufw allow <port>/tcp`

Then rebuild the frontend and reload nginx:

```bash
sudo -u www-data npm --prefix /app/gotabgaa/frontend run build
sudo systemctl reload nginx
```

### Attach a domain (later)

Once DNS points at the VPS:

```bash
sudo nano /etc/nginx/sites-available/gotabgaa
# Change: server_name _;   →   server_name gotabgaa.digital www.gotabgaa.digital;
# Change: listen 8090;     →   listen 80;
# Change: listen [::]:8090;→   listen [::]:80;

sudo nginx -t && sudo systemctl reload nginx

# Get HTTPS
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d gotabgaa.digital -d www.gotabgaa.digital
```

Certbot auto-inserts the SSL blocks the same way the vitabuswap.com config
shows. Then update `backend/.env` `APP_URL` and `CORS_ALLOWED_ORIGINS` to
`https://gotabgaa.digital` and rebuild frontend.

### Switch to SSR (dynamic Next.js)

If you outgrow the static-export model (need per-request rendering, live
edge caching, etc.):

1. Remove `output: "export"` from `frontend/next.config.ts`
2. Install the systemd unit:
   ```bash
   sudo cp deploy/systemd/gotabgaa-frontend.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now gotabgaa-frontend
   ```
3. Swap the nginx config:
   ```bash
   sudo cp deploy/nginx/gotabgaa-ssr.conf /etc/nginx/sites-available/gotabgaa
   sudo nginx -t && sudo systemctl reload nginx
   ```

The SSR config proxies `/` to `127.0.0.1:3120` where the Node process runs.

## Troubleshooting

**500 error on `/api/*`** — check `backend/storage/logs/laravel.log`. Usually a
DB connection issue or missing `APP_KEY`.

**403 on `/`** — the frontend hasn't been built yet, or `frontend/out/` isn't
readable by nginx. Run `sudo -u www-data npm --prefix /app/gotabgaa/frontend
run build` and check permissions with `ls -la /app/gotabgaa/frontend/out/`.

**HLS stream returns 502** — the upstream RTMP server firewalls off external
IPs. Confirm the server IP is allowed on the upstream (`102.210.28.247`), or
switch to a CDN-based proxy path.

**PHP-FPM socket not found** — you're on a non-8.2 PHP. Change the socket path
in the nginx config: `fastcgi_pass unix:/var/run/php/phpX.Y-fpm.sock;`.

**Filament assets 404** — run `sudo -u www-data php artisan filament:assets`.

## Contents of `deploy/`

| File | Purpose |
|---|---|
| `nginx/gotabgaa.conf` | Static-export config (recommended, no Node process needed) |
| `nginx/gotabgaa-ssr.conf` | SSR config (proxy to Node on 3120) |
| `systemd/gotabgaa-frontend.service` | Only needed if you use SSR |
| `backend.env.example` | Copy → `backend/.env` and edit |
| `frontend.env.example` | Copy → `frontend/.env.production` and edit |
| `deploy.sh` | Repeatable one-command redeploy |
| `README.md` | This file |
