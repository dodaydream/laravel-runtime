#!/bin/bash
# install composer dependencies (skip if vendor folder exists)
composer install --no-dev --no-interaction --optimize-autoloader

# Change ownership for folder
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/html/storage

# Optimize laravel
# @see: https://laravel.com/docs/9.x/deployment#optimization
# run the follows in www-data user
gosu www-data:www-data php artisan optimize

# Update nginx to match worker_processes to no. of cpu's
procs=$(cat /proc/cpuinfo | grep processor | wc -l)
sed -i -e "s/worker_processes  1/worker_processes $procs/" /etc/nginx/nginx.conf

# Start supervisord and services
if [ $# -gt 0 ]; then
  exec gosu www-data "$@"
else
  exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
fi
