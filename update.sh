#!/bin/bash
if [ ! -d "/var/www/pterodactyl" ]; then
  echo "Directory /var/www/pterodactyl does not exist. Exiting."
  exit 1
fi
cd /var/www/pterodactyl || exit
php artisan down
echo "Downloading and extracting the latest panel theme..."
curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv
chmod -R 755 storage/* bootstrap/cache
echo "Installing composer dependencies as root..."
sudo composer install --no-dev --optimize-autoloader --no-interaction
php artisan view:clear
php artisan config:clear
php artisan migrate --seed --force
chown -R www-data:www-data /var/www/pterodactyl/*
php artisan queue:restart
php artisan up
echo "Update completed successfully."
