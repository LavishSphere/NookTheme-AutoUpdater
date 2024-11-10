#!/bin/bash
LOG_PATH="/var/log/pterodactyl-update.log"
echo "Checking if /var/www/pterodactyl exists..."
if [ -d "/var/www/pterodactyl" ]; then
    echo "Directory exists. Proceeding with update."
    cd /var/www/pterodactyl || exit
    echo "Putting the application into maintenance mode..."
    php artisan down &>> $LOG_PATH
    echo "Downloading and extracting the latest theme..."
    curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv &>> $LOG_PATH
    echo "Setting permissions on storage and bootstrap/cache..."
    chmod -R 755 storage/* bootstrap/cache
    echo "Installing composer dependencies (manual confirmation required)..."
    composer install --no-dev --optimize-autoloader &>> $LOG_PATH
    echo "Clearing views and config cache..."
    php artisan view:clear &>> $LOG_PATH
    php artisan config:clear &>> $LOG_PATH
    echo "Running migrations..."
    php artisan migrate --seed --force &>> $LOG_PATH
    echo "Setting ownership to www-data..."
    chown -R www-data:www-data /var/www/pterodactyl/*
    echo "Restarting the queue..."
    php artisan queue:restart &>> $LOG_PATH
    echo "Bringing the application back up..."
    php artisan up &>> $LOG_PATH
    echo "Update complete!"
else
    echo "Directory /var/www/pterodactyl does not exist. Exiting."
    exit 1
fi
