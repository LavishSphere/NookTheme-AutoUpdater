#!/bin/bash
LOG_PATH="/var/log/update.log"
if [ ! -d "/var/www/pterodactyl" ]; then
  echo "Directory /var/www/pterodactyl does not exist. Exiting."
  exit 1
fi
echo "Navigating to /var/www/pterodactyl"
cd /var/www/pterodactyl || exit
echo "Putting the application into maintenance mode..."
php artisan down &>> $LOG_PATH
echo "Downloading and extracting the latest panel theme..."
curl -sL https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xz &>> $LOG_PATH
echo "Setting permissions for storage and cache directories..."
chmod -R 755 storage/* bootstrap/cache &>> $LOG_PATH
echo "Installing composer dependencies as root..."
sudo composer install --no-dev --optimize-autoloader --no-interaction &>> $LOG_PATH
echo "Clearing and optimizing cache..."
php artisan view:clear &>> $LOG_PATH
php artisan config:clear &>> $LOG_PATH
echo "Running migrations and seeding the database..."
php artisan migrate --seed --force &>> $LOG_PATH
echo "Setting ownership to www-data..."
chown -R www-data:www-data /var/www/pterodactyl/* &>> $LOG_PATH
echo "Restarting the queue worker..."
php artisan queue:restart &>> $LOG_PATH
echo "Bringing the application out of maintenance mode..."
php artisan up &>> $LOG_PATH
echo "Update completed successfully."
