FROM benyoo/alpine:3.4.20160812

ENV PHP_VERSION="7.1.14" \
	INSTALL_DIR=/usr/local/php DATA_DIR=/data/wwwroot TEMP_DIR=/tmp/php \
	PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"

ENV PHP_INI_DIR="${INSTALL_DIR}/etc" \
	PATH="$INSTALL_DIR/bin:$INSTALL_DIR/sbin:$PATH" \
	PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www --with-fpm-group=www" \
	PHP_CPPFLAGS="$PHP_CFLAGS" \
	PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
	GPG_KEYS=A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 \
	PHP_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror" \
	PHP_ASC_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz.asc/from/this/mirror" \
	PHP_SHA256="71514386adf3e963df087c2044a0b3747900b8b1fc8da3a99f0a0ae9180d300b" \
	PHP_MD5="a74c13f8779349872b365e6732e8c98e"

RUN set -xe && \
#Mkdir INI_DIR
	mkdir -p ${DATA_DIR} ${PHP_INI_DIR}/php.d ${TEMP_DIR} && \
	cd ${TEMP_DIR} && \
#Add run php user&group
	addgroup -g 400 -S www && \
	adduser -u 400 -S -H -s /sbin/nologin -g 'PHP' -G www www && \
#Insall DEPS PKG
	export PERSISTENT_DEPS="ca-certificates curl tar xz" && \
	export PHPIZE_DEPS="autoconf file g++ gcc libc-dev make pkgconf re2c" && \
	export MEMCACHE_DEPS="libmemcached-dev cyrus-sasl-dev libsasl linux-headers git" && \
	apk add --no-cache --virtual .persistent-deps ${PERSISTENT_DEPS} && \
	apk add --no-cache --virtual .build-deps $PHPIZE_DEPS curl-dev libedit-dev libxml2-dev openssl-dev sqlite-dev \
		libjpeg-turbo-dev libpng-dev libmcrypt-dev icu-dev freetype-dev gettext-dev libxslt-dev zlib-dev ${MEMCACHE_DEPS} && \
#Build PHP
	export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
	curl -Lk "${PHP_URL}" | tar xJ -C ${TEMP_DIR} --strip-components=1 && \
	./configure \
		--prefix=${INSTALL_DIR} --with-config-file-path=${PHP_INI_DIR} \
		--with-config-file-scan-dir=${PHP_INI_DIR}/php.d \
		$PHP_EXTRA_CONFIGURE_ARGS \
		--enable-opcache \
		--enable-xml \
		--enable-bcmath \
		--enable-shmop \
		--enable-exif \
		--enable-sysvsem \
		--enable-inline-optimization \
		--enable-ftp \
		--enable-mbregex \
		--enable-pcntl \
		--enable-sockets \
		--enable-zip \
		--enable-soap \
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
		--with-iconv \
		--with-iconv-dir=/usr/local \
		--with-freetype-dir \
		--with-jpeg-dir \
		--with-png-dir \
		--with-zlib \
		--with-zlib-dir \
		--with-libxml-dir=/usr \
		--with-curl=/usr/local \
		--with-mcrypt \
		--with-gd \
		--enable-gd-native-ttf \
		--with-openssl \
		--with-mhash \
		--with-xmlrpc \
		--enable-intl \
		--with-xsl \
		--with-gettext \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
		--with-libedit \
		--disable-debug \
		--disable-cgi \
#		--disable-ipv6 \
		--disable-rpath && \
	make -j "$(getconf _NPROCESSORS_ONLN)" && \
	make install && \
	/bin/cp php.ini-production ${PHP_INI_DIR}/php.ini && \
	{ find /usr/local/php/bin /usr/local/php/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; } && \
	make clean && \
#Install Swoole
#	${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/swoole-1.9.4.tgz && \
#Install Redis
#	${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/redis-3.1.0.tgz && \
#Install Xdebug
#	${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/xdebug-2.5.0.tgz && \
	${INSTALL_DIR}/bin/pecl install http://pecl.php.net/get/mongodb-1.5.2.tgz && \
#Install Event
#	bash -c "mkdir -p /tmp/{libevent,event}" && \
##	LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz" && \
#	bash -c "curl -Lk ${LIBEVENT_URL} | tar -xz -C /tmp/libevent --strip-components=1" && \
#	cd /tmp/libevent && \
#	./configure && \
#	make -j "$(getconf _NPROCESSORS_ONLN)" && \
#	make install && \
#	${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/event-2.2.1.tgz && \
#Install Memcached
	mkdir -p /tmp/memcached /tmp/memcache && \
	git clone https://github.com/php-memcached-dev/php-memcached.git /tmp/memcached && \
	cd /tmp/memcached && \
	git checkout php7 && \
	${INSTALL_DIR}/bin/phpize && \
	./configure --with-php-config=${INSTALL_DIR}/bin/php-config && \
	make -j "$(getconf _NPROCESSORS_ONLN)" && \
	make install && \
#Install Memcache
#	git clone https://github.com/websupport-sk/pecl-memcache /tmp/memcache && \
#	cd /tmp/memcache && \
#	${INSTALL_DIR}/bin/phpize && \
#	./configure --with-php-config=${INSTALL_DIR}/bin/php-config && \
#	make -j "$(getconf _NPROCESSORS_ONLN)" && \
#	make install && \
#	\
	#docker-php-source delete && \
	runDeps="$( scanelf --needed --nobanner --recursive /usr/local | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
	apk add --no-cache --virtual .php-rundeps $runDeps && \
#Clear OS
	apk del .build-deps && \
	bash -c "rm -rf /tmp/{php,pear,memcache{,d},libevent,event}"

#COPY docker-php-source /usr/local/bin/
COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/
COPY php-fpm.conf ${PHP_INI_DIR}/

WORKDIR /data/wwwroot

ENTRYPOINT ["docker-php-entrypoint"]
EXPOSE 9000
CMD ["php-fpm"]
