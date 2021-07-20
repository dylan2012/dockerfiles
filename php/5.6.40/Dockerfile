FROM benyoo/alpine:3.5.20170325
MAINTAINER from dylan

ARG VERSION=${VERSION:-5.6.40}
ARG SHA256=${SHA256:-9004995fdf55f111cd9020e8b8aff975df3d8d4191776c601a46988c375f3553}
#ARG SWOOLE_VERSION=${SWOOLE_VERSION:-1.7.17}
ARG SWOOLE_VERSION=${SWOOLE_VERSION:-1.9.4}

ENV INSTALL_DIR=/usr/local/php \
	TEMP_DIR=/tmp/php

#Install PHP iconv from source
RUN set -x && \
# Change Mirrors
	PHP_URL="https://secure.php.net/get/php-${VERSION}.tar.xz/from/this/mirror" && \
	LIBICONV_VERSION=1.15 && \
	LIBICONV_DIR=/tmp/libiconv && \
	MEMCACHE_DEPS="libmemcached-dev cyrus-sasl-dev libsasl linux-headers git" && \
	PHPIZE_DEPS="autoconf file g++ gcc libc-dev make m4 pkgconf re2c xz tar" && \
	PHPIZE_BUILD="curl-dev libjpeg-turbo-dev libpng-dev libmcrypt-dev icu-dev imap-dev gettext-dev" && \
	PHPIZE_BUILD="$PHPIZE_BUILD libxslt-dev libxpm-dev libxml2-dev freetype-dev libaio-dev libedit-dev" && \
	PHPIZE_BUILD="$PHPIZE_BUILD sqlite-dev zlib-dev imap-dev libressl-dev readline-dev" && \
#Mkdir TEMP_DIR
	mkdir -p ${LIBICONV_DIR} ${TEMP_DIR} /tmp/memcached && cd /tmp && \
#Upgrade OS and install
	apk --update --no-cache upgrade && \
	apk add --no-cache --virtual .build-deps $MEMCACHE_DEPS $PHPIZE_DEPS $PHPIZE_BUILD && \
#Add run php user&group
	addgroup -g 400 -S www && \
	adduser -u 400 -S -H -s /sbin/nologin -g 'PHP' -G www www && \
#Download File
	curl -Lk "${PHP_URL}" | tar xJ -C ${TEMP_DIR} --strip-components=1 && \
	curl -SL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz | tar -xz -C ${LIBICONV_DIR} --strip-components=1 && \
#Install libiconv
	rm /usr/bin/iconv && \
	cd ${LIBICONV_DIR} && \
	./configure --prefix=/usr/local && \
	make -j "$(getconf _NPROCESSORS_ONLN)" && \
	make install && \
#Install PHP
	cd ${TEMP_DIR}/ && \
	export LD_PRELOAD=/usr/local/lib/preloadable_libiconv.so && \
	PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www --with-fpm-group=www" && \
	./configure --prefix=${INSTALL_DIR} \
		--with-config-file-path=${INSTALL_DIR}/etc \
		--with-config-file-scan-dir=${INSTALL_DIR}/etc/php.d \
		${PHP_EXTRA_CONFIGURE_ARGS} \
		--enable-opcache \
		--disable-fileinfo \
		--with-mysql=mysqlnd \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
		--with-iconv=/usr/local \
		--with-freetype-dir \
		--with-jpeg-dir \
		--with-png-dir \
		--with-zlib \
		--with-zlib-dir \
		--with-libxml-dir=/usr \
		--enable-xml \
		--disable-rpath \
		--enable-bcmath \
		--enable-shmop \
		--enable-exif \
		--enable-sysvsem \
		--enable-inline-optimization \
		--with-curl \
		--enable-mbregex \
		--enable-mbstring \
		--with-mcrypt \
		--with-gd \
		--enable-gd-native-ttf \
		--enable-gd-jis-conv \
		--with-openssl \
		--with-mhash \
		--enable-pcntl \
		--enable-sockets \
		--with-xmlrpc \
		--enable-ftp \
		--enable-intl \
		--with-xsl \
		--with-gettext \
		--enable-zip \
		--enable-soap \
		--disable-ipv6 \
		--disable-debug \
		--with-layout=GNU \
		--with-pic \
		--enable-cli \
		--with-xpm-dir \
		--enable-shared \
		--with-imap \
		--enable-memcache && \
	make -j$(getconf _NPROCESSORS_ONLN) && \
	make install && \
	[ ! -e "${INSTALL_DIR}/etc/php.d" ] && mkdir -p ${INSTALL_DIR}/etc/php.d && \
	/bin/cp php.ini-production ${INSTALL_DIR}/etc/php.ini && \
#Install libmemcached memcache-3.0.8
	apk add --no-cache php5-memcache libmemcached-dev && \
	mv /usr/lib/php5/modules/memcache.so ${INSTALL_DIR}/lib/php/20131226/memcache.so && \
#Install memcached-2.2.0
	${INSTALL_DIR}/bin/pecl install http://pecl.php.net/get/memcached-2.2.0.tgz && \
#Install redis-2.2.8
	${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/redis-2.2.8.tgz && \
#Install swoole
	#${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz && \
	#curl -Lk "https://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz" | tar xz -C /tmp && \
	#cd /tmp/swoole-${SWOOLE_VERSION} && \
	#${INSTALL_DIR}/bin/phpize && \
	#./configure --with-php-config=${INSTALL_DIR}/bin/php-config && \
	#make -j "$(getconf _NPROCESSORS_ONLN)" && \
	#make install && \
#Install xdebug
	#${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/xdebug-2.5.0.tgz && \
#Add iconv
	cd ${TEMP_DIR}/ext/iconv && \
	${INSTALL_DIR}/bin/phpize && \
	./configure --with-php-config=${INSTALL_DIR}/bin/php-config && \
	make -j "$(getconf _NPROCESSORS_ONLN)" && \
	make install && \
	#echo "extension=iconv.so" > ${INSTALL_DIR}/etc/php.d/iconv.ini && \
#install fileinfo
	cd ${TEMP_DIR}/ext/fileinfo && \
	${INSTALL_DIR}/bin/phpize && \
 	./configure --with-php-config=${INSTALL_DIR}/bin/php-config && \
	make -j "$(getconf _NPROCESSORS_ONLN)" && \
	make install && \
#Install MongoDB
	#${INSTALL_DIR}/bin/pecl install mongo && \
	#${INSTALL_DIR}/bin/pecl install mongodb && \
#Uninstalll Build software an clean OS
	#docker-php-source delete && \
	RUN_DEPS="$( scanelf --needed --nobanner --recursive /usr/local/ | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
	RUN_DEPS="${RUN_DEPS} inotify-tools supervisor logrotate python" && \
	apk add --no-cache --virtual .php-rundeps $RUN_DEPS && \
	apk del .build-deps && \
	rm -rf /var/cache/apk/* /tmp/* && \
	echo "Built finsh"

ENV PATH=${INSTALL_DIR}/bin:$PATH \
	TERM=linux \
	LD_PRELOAD=/usr/local/lib/preloadable_libiconv.so
ENV PATH=${INSTALL_DIR}/sbin:$PATH

COPY entrypoint.sh /entrypoint.sh
ADD etc /etc
ADD php-fpm.conf ${INSTALL_DIR}/etc/php-fpm.conf

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["php-fpm"]
