#!/bin/bash
# install composer dependencies (skip if vendor folder exists)
if [ ! -d "vendor" ]; then
  composer install --no-dev --no-interaction --optimize-autoloader
fi

# Optimize laravel
# @see: https://laravel.com/docs/9.x/deployment#optimization
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Change ownership for folder
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Update nginx to match worker_processes to no. of cpu's
procs=$(cat /proc/cpuinfo | grep processor | wc -l)
sed -i -e "s/worker_processes  1/worker_processes $procs/" /etc/nginx/nginx.conf

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
