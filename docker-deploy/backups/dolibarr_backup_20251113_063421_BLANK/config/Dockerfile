FROM php:8.2-fpm-bookworm

# Install system deps and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libicu-dev \
    libxml2-dev \
    libxslt-dev \
    libmagickwand-dev \
    libc-client-dev \
    libkrb5-dev \
    libssl-dev \
    --no-install-recommends \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mysqli \
        calendar \
        imap \
        zip \
        gd \
        intl \
        mbstring \
        xml \
        soap \
        bcmath \
        pcntl \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/memory_limit = 128M/memory_limit = 256M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/max_execution_time = 30/max_execution_time = 300/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/;date.timezone =/date.timezone = UTC/' "$PHP_INI_DIR/php.ini"

# Create dolibarr user/group with specific ID
RUN groupadd -g 1000 dolibarr \
    && useradd -u 1000 -g dolibarr -m dolibarr

# Create directory structure
RUN mkdir -p /var/www/html/documents \
    && ln -s /var/www/html/documents /var/www/documents \
    && chown -R dolibarr:dolibarr /var/www/html

# Set working directory
WORKDIR /var/www/html

# Switch to dolibarr user
USER dolibarr

# Copy application (will be mounted in docker-compose)