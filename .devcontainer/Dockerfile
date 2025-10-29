FROM php:8.1-apache-bullseye

# Set environment variables
ENV PHP_INI_DATE_TIMEZONE='UTC'
ENV PHP_INI_MEMORY_LIMIT=256M
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libjpeg62-turbo \
        libpng-dev \
        libpng16-16 \
        libldap2-dev \
        libxml2-dev \
        libzip-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        default-mysql-client \
        unzip \
        curl \
        wget \
        git \
        vim \
        nano \
        apt-utils \
        msmtp \
        msmtp-mta \
        mailutils \
        libpq-dev \
        sudo \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        calendar \
        intl \
        mysqli \
        pdo_mysql \
        pgsql \
        gd \
        soap \
        zip \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) ldap

# Install xdebug for debugging
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Configure PHP
RUN mv ${PHP_INI_DIR}/php.ini-development ${PHP_INI_DIR}/php.ini \
    && echo 'memory_limit = 256M' >> ${PHP_INI_DIR}/php.ini \
    && echo 'max_execution_time = 300' >> ${PHP_INI_DIR}/php.ini \
    && echo 'date.timezone = UTC' >> ${PHP_INI_DIR}/php.ini \
    && echo 'display_errors = On' >> ${PHP_INI_DIR}/php.ini \
    && echo 'error_reporting = E_ALL' >> ${PHP_INI_DIR}/php.ini

# Configure xdebug
RUN echo 'zend_extension="xdebug.so"' >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.mode=debug,develop' >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.start_with_request=yes' >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_host=host.docker.internal' >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_port=9003' >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.discover_client_host=true' >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini

# Configure sendmail to use maildev
RUN echo "account default" > /etc/msmtprc \
    && echo "auth off" >> /etc/msmtprc \
    && echo "port 1025" >> /etc/msmtprc \
    && echo "host mail" >> /etc/msmtprc \
    && echo "from local@localdomain.com" >> /etc/msmtprc \
    && echo "domain localhost.localdomain" >> /etc/msmtprc \
    && echo "sendmail_path=/usr/bin/msmtp -t" >> /usr/local/etc/php/conf.d/php-sendmail.ini

# Enable Apache modules
RUN a2enmod rewrite headers ssl expires

# Configure Apache for Dolibarr
RUN echo '<Directory /workspace/htdocs>' > /etc/apache2/conf-available/dolibarr.conf \
    && echo '    Options Indexes FollowSymLinks' >> /etc/apache2/conf-available/dolibarr.conf \
    && echo '    AllowOverride All' >> /etc/apache2/conf-available/dolibarr.conf \
    && echo '    Require all granted' >> /etc/apache2/conf-available/dolibarr.conf \
    && echo '</Directory>' >> /etc/apache2/conf-available/dolibarr.conf \
    && a2enconf dolibarr

# Set DocumentRoot to Dolibarr htdocs
RUN sed -i 's|/var/www/html|/workspace/htdocs|g' /etc/apache2/sites-available/000-default.conf

# Create directories
RUN mkdir -p /var/www/documents /workspace \
    && chown -R www-data:www-data /var/www/documents

# Give www-data user sudo access (for development convenience)
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/www-data

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /workspace

EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
