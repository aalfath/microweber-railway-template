# Microweber on Railway: built from the pinned upstream release (no current official image).
# Upstream: https://github.com/microweber/microweber, tag v2.0.21 (commit pinned below).

# Base image with the PHP extensions Microweber needs.
FROM php:8.4.28-apache-trixie@sha256:3550aedd1c7bdfe26283c7b1550ef76509e6c2b1284aef814e6f2e325b7c9688 AS base
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libwebp-dev libpng-dev \
        libzip-dev libicu-dev; \
    docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" gd pdo_mysql zip intl bcmath exif; \
    rm -rf /var/lib/apt/lists/*; \
    for m in gd intl pdo_mysql zip bcmath exif sodium mbstring; do php -m | grep -qix "$m"; done

# Build stage: fetch the release and install PHP dependencies.
FROM base AS build
ARG MW_VERSION=2.0.21
ARG MW_COMMIT=4ac62cce031d04bcae48c6cb90d4297292a963ed
COPY --from=composer:2.9.8@sha256:b09bccd91a78fe8a9ab4b33d707b862e8fe54fec17782e32683ad2a69c46867d /usr/bin/composer /usr/local/bin/composer
RUN apt-get update && apt-get install -y --no-install-recommends git unzip && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN set -eux; \
    git -c advice.detachedHead=false clone -q --depth 1 --branch "v${MW_VERSION}" https://github.com/microweber/microweber.git .; \
    test "$(git rev-parse HEAD)" = "${MW_COMMIT}"; \
    rm -rf .git .github tests xdebug_server.php phpunit*.xml Jenkinsfile .travis.yml docker-compose.yml Dockerfile
COPY build/prepare-composer.php /tmp/prepare-composer.php
ENV COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_NO_INTERACTION=1
# The optional "big-free" theme is only on packages.microweberapi.com (172 MB); it is left out.
# GitHub dist URLs are pointed at codeload so anonymous builds don't hit the API rate limit.
RUN set -eux; \
    php /tmp/prepare-composer.php; \
    composer install --no-dev --prefer-dist --optimize-autoloader --no-progress > /tmp/composer.log 2>&1 || { tail -n 60 /tmp/composer.log; exit 1; }; \
    tail -n 5 /tmp/composer.log; \
    test -f vendor/autoload.php; \
    rm -rf /root/.composer/cache /tmp/composer*; \
    # Railway's MySQL port comes from DB_PORT (upstream's mysql block has no port key).
    sed -i "s#'host' => env('DB_HOST', '127.0.0.1'),#'host' => env('DB_HOST', '127.0.0.1'),\n            'port' => env('DB_PORT', '3306'),#" config/database.php; \
    grep -q "'port' => env('DB_PORT', '3306')" config/database.php; \
    # State lives on the /data volume: settings (config/microweber.php), storage and user uploads.
    mkdir -p /seed/userfiles; \
    mv storage /seed/storage; ln -s /data/storage storage; \
    for d in media css language fonts export import backup; do \
      if [ -e "userfiles/$d" ]; then mv "userfiles/$d" "/seed/userfiles/$d"; else mkdir -p "/seed/userfiles/$d"; fi; \
      ln -s "/data/userfiles/$d" "userfiles/$d"; \
    done; \
    ln -s /data/config/microweber.php config/microweber.php; \
    echo "${MW_VERSION}" > /seed/VERSION

FROM base
COPY --from=build --chown=www-data:www-data /src /var/www/html
COPY --from=build --chown=www-data:www-data /seed /opt/microweber-seed
COPY rootfs/ /
RUN set -eux; \
    cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    a2enmod rewrite headers expires; \
    a2enconf microweber; \
    sed -ri 's/^Listen 80$/Listen ${PORT}/' /etc/apache2/ports.conf; \
    sed -ri 's/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/' /etc/apache2/sites-available/000-default.conf; \
    chmod 755 /usr/local/bin/microweber-start; \
    chown www-data:www-data /var/www/html
ENV PORT=8080 APP_ENV=production APP_DEBUG=false
EXPOSE 8080
VOLUME ["/data"]
WORKDIR /var/www/html
CMD ["microweber-start"]
