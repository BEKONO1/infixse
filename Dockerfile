FROM php:8.4-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    unzip \
    nginx \
    && docker-php-ext-install \
      intl \
      pdo_mysql \
      mbstring \
      xml \
      zip \
      opcache \
      curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --ignore-platform-reqs --no-security-blocking

RUN if [ ! -f .env ]; then \
        cp .env.example .env 2>/dev/null || echo "APP_NAME=Laravel\nAPP_ENV=local\nAPP_KEY=\nAPP_DEBUG=true\nAPP_URL=http://localhost" > .env; \
    fi \
    && php artisan key:generate --force \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache /var/www/html

COPY <<'EOF' /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;
    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

RUN mkdir -p /var/run/php && chown www-data:www-data /var/run/php

EXPOSE 80

CMD service php8.4-fpm start && nginx -g "daemon off;"
