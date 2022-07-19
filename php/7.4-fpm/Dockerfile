#FROM php:7.4.29-fpm-alpine3.15
FROM php:7.4-fpm-alpine3.13
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
#ADD install-php-extensions /usr/local/bin/
RUN set -xe && apk update && apk add --no-cache --virtual .build-deps wget curl git vim
RUN docker-php-ext-install -j$(nproc) pdo_mysql && \
	docker-php-ext-install -j$(nproc) bcmath && \
	docker-php-ext-install -j$(nproc) mysqli && \
	docker-php-ext-install -j$(nproc) sockets

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync
RUN install-php-extensions redis zip pcov  pcntl gd exif xlswriter memcached xmlrpc opcache mongodb
#RUN install-php-extensions swoole
RUN pecl install xdebug
