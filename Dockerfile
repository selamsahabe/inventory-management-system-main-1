FROM php:8.2-fpm-buster

WORKDIR /var/www/html

COPY ./ ./

RUN apt-get update && \
  apt-get install -y \
  zlib1g-dev \
  libpng-dev \
  libonig-dev \
  libzip-dev \
  libpq-dev \
  libfreetype6-dev # Add FreeType library

# Configure the GD extension with FreeType support and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype && \
  docker-php-ext-install gd pdo pdo_mysql mysqli mbstring zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

USER root
RUN composer install --optimize-autoloader --no-cache
