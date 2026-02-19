#!/bin/bash
set -e

echo "🚀 Starting Infix LMS on Railway..."

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL..."
while ! nc -z $MYSQLHOST $MYSQLPORT; do
  sleep 1
done
echo "✅ MySQL is ready!"

# Wait for Redis to be ready
echo "⏳ Waiting for Redis..."
while ! nc -z $REDISHOST $REDISPORT; do
  sleep 1
done
echo "✅ Redis is ready!"

# Run migrations
echo "🔄 Running database migrations..."
php artisan migrate --force --no-interaction

# Run seeders (optional - uncomment if you want sample data)
# echo "🌱 Running seeders..."
# php artisan db:seed --force --no-interaction

# Optimize Laravel
echo "⚡ Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Create storage link
echo "🔗 Creating storage link..."
php artisan storage:link 2>/dev/null || true

# Set proper permissions
echo "🔒 Setting permissions..."
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

# Start PHP-FPM and Nginx
echo "🌐 Starting web server..."
php-fpm -D
nginx -g 'daemon off;'
