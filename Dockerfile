FROM php:8.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install \
      intl \
      pdo_mysql \
      mbstring \
      xml \
      zip \
      opcache \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

COPY . .

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's|<Directory "/var/www/html">|<Directory "/var/www/html/public">|' /etc/apache2/sites-available/000-default.conf \
    && chown -R www-data:www-data /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]
