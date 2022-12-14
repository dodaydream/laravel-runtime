#!/bin/bash
# install composer dependencies
composer install --no-dev --no-interaction --optimize-autoloader

# optimize laravel
php artisan optimize:clear
php artisan optimize

# set permission for folder
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Update nginx to match worker_processes to no. of cpu's
procs=$(cat /proc/cpuinfo | grep processor | wc -l)
sed -i -e "s/worker_processes  1/worker_processes $procs/" /etc/nginx/nginx.conf

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
