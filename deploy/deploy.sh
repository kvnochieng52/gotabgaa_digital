#!/usr/bin/env bash
# ============================================================
# Gotabgaa Digital — deployment script
#
# What it does:
#   1. Pulls latest from git
#   2. Installs backend Composer deps
#   3. Runs migrations
#   4. Clears + rebuilds Laravel caches
#   5. Installs frontend npm deps
#   6. Builds Next.js static export
#   7. Reloads nginx + PHP-FPM
#
# Run from /app/gotabgaa on the server:
#     sudo bash deploy/deploy.sh
# ============================================================
set -euo pipefail

APP_DIR="/app/gotabgaa"
BACKEND="$APP_DIR/backend"
FRONTEND="$APP_DIR/frontend"

# Colors
G="\033[0;32m"; Y="\033[0;33m"; R="\033[0;31m"; N="\033[0m"
step() { echo -e "\n${G}==>${N} $*"; }
warn() { echo -e "${Y}[!]${N} $*"; }

if [[ $EUID -ne 0 ]]; then
    warn "This script must run as root (use sudo)."
    exit 1
fi

step "Pulling latest from git"
cd "$APP_DIR"
sudo -u www-data git pull --ff-only

step "Backend: installing composer packages"
cd "$BACKEND"
sudo -u www-data composer install --no-dev --optimize-autoloader --no-interaction

step "Backend: running migrations"
sudo -u www-data php artisan migrate --force

step "Backend: caching config/routes/views"
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache
sudo -u www-data php artisan event:cache
sudo -u www-data php artisan filament:optimize

step "Backend: ensuring storage symlink"
sudo -u www-data php artisan storage:link || true

step "Backend: setting permissions"
chown -R www-data:www-data "$BACKEND/storage" "$BACKEND/bootstrap/cache"
chmod -R 775 "$BACKEND/storage" "$BACKEND/bootstrap/cache"

step "Frontend: installing npm packages"
cd "$FRONTEND"
sudo -u www-data npm ci --no-audit --no-fund

step "Frontend: building static export"
sudo -u www-data npm run build

step "Reloading nginx + PHP-FPM"
nginx -t
systemctl reload nginx
systemctl reload php8.2-fpm

step "Done. Site is live at http://$(hostname -I | awk '{print $1}'):8090/"
