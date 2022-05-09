FROM php:7.4.29-fpm-alpine3.15
MAINTAINER from dylan

ENV PHP_VERSION="7.4.29" \
    INSTALL_DIR=/usr/local/php DATA_DIR=/data/wwwroot TEMP_DIR=/tmp/php
ENV PHP_INI_DIR="/usr/local/etc/php" \
    PATH="$INSTALL_DIR/bin:$INSTALL_DIR/sbin:$PATH"
# Install gd, iconv, mbstring, mysql, soap, sockets, zip, and zlib extensions
# see example at https://hub.docker.com/_/php/
RUN set -xe  \
        && mkdir -p ${DATA_DIR} ${PHP_INI_DIR}/conf.d ${TEMP_DIR}  \
		&& addgroup -g 400 -S www  \
		&& adduser -u 400 -S -H -s /sbin/nologin -g 'PHP' -G www www  \
		&& apk update  \
        && apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		build-base \
		zlib-dev \
		freetype-dev \
		git \
		libjpeg-turbo-dev \
		libpng-dev \
		libxml2-dev \
		libzip-dev \
		php7-json \
		php7-openssl \
		php7-pdo \
		php7-pdo_mysql \
		php7-session \
		php7-simplexml \
		php7-tokenizer \
		php7-xml \
		openssl-dev \
		autoconf \
		libmemcached-dev \
		libmemcached \
		openssh-client \
#		imagemagick \
#		imagemagick-libs \
#		imagemagick-dev \
#		php7-imagick \
		php7-pcntl \
		php7-zip \
		sqlite libxml2-dev \
	&& docker-php-ext-install -j$(nproc) soap sockets exif bcmath pdo_mysql pcntl mysqli xmlrpc \
	&& docker-php-ext-configure gd --with-jpeg --with-freetype \
	&& docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-install -j$(nproc) zip \
	&& docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache  \
# install imagick
#    && pecl install imagick && docker-php-ext-enable --ini-name 20-imagick.ini imagick  \
# install pcov
#    && pecl install pcov && docker-php-ext-enable pcov  \
# install MongoDb		
#    && pecl install mongodb && docker-php-ext-enable --ini-name 10-mongodb.ini mongodb  \
# install Redis
    && pecl install redis && docker-php-ext-enable --ini-name 10-redis.ini redis  \
# install Memcached
    && pecl install memcached && docker-php-ext-enable --ini-name 10-memcached.ini memcached  \
# install Xdebug
    && pecl install xdebug && docker-php-ext-enable --ini-name 10-xdebug.ini xdebug  \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/bin/composer

RUN runDeps="$( scanelf --needed --nobanner --recursive /usr/local | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
    runDeps="${runDeps} inotify-tools supervisor logrotate python3 tzdata"  \
    && apk add --no-cache --virtual .php-rundeps $runDeps  \
	&& cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini  \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#    && apk del .build-deps

COPY entrypoint.sh /entrypoint.sh
COPY php-fpm.conf /usr/local/etc/
ADD etc /etc

WORKDIR /data/wwwroot
EXPOSE 9000

CMD ["/bin/sh","/entrypoint.sh"]
