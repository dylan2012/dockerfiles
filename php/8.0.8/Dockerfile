FROM dylan2012/alpine:3.14
MAINTAINER from dylan

ENV PHP_VERSION="8.0.8" \
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
    PHP_SHA256="4380b80ef98267c3823c3416eb05f7729ba7a33de6b3d14ec96013215d62c35e" \
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
        libjpeg-turbo-dev libpng-dev libmcrypt-dev icu-dev freetype-dev gettext-dev libxslt-dev zlib-dev libzip-dev \
        oniguruma-dev imagemagick-dev ${MEMCACHE_DEPS} && \
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
        --with-pear \
        --with-gettext \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-libedit \
        --disable-debug \
        --disable-cgi \
#               --disable-ipv6 \
        --disable-rpath && \
    make -j "$(getconf _NPROCESSORS_ONLN)" && \
    make install && \
    /bin/cp php.ini-production ${PHP_INI_DIR}/php.ini && \
    { find /usr/local/php/bin /usr/local/php/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; } && \
    make clean && \
###     echo
#Install Swoole
    ${INSTALL_DIR}/bin/pecl install swoole && \
#Install Redis
    ${INSTALL_DIR}/bin/pecl install redis && \
#Install Xdebug
    ${INSTALL_DIR}/bin/pecl install xdebug && \
#Install Event
    bash -c "mkdir -p /tmp/{libevent,event}" && \
    LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz" && \
    bash -c "curl -Lk ${LIBEVENT_URL} | tar -xz -C /tmp/libevent --strip-components=1" && \
    cd /tmp/libevent && \
    ./configure && \
    make -j "$(getconf _NPROCESSORS_ONLN)" && \
    make install && \
    cd - && \
###    ${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/event-2.5.1.tgz && \
    ${INSTALL_DIR}/bin/pecl install event && \
####Install Memcached
    ${INSTALL_DIR}/bin/pecl install memcached && \
####Install Memcache
    ${INSTALL_DIR}/bin/pecl install memcache && \
####Install ionCube
###    mkdir -p ${TEMP_DIR}/ioncube && \
###    curl -Lk https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz | tar -xz -C ${TEMP_DIR}/ioncube/ --strip-components=1 && \
###    cp ${TEMP_DIR}/ioncube/ioncube_loader_lin_7.3.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/ && \
###    echo -e '[ionCube Loader]\nzend_extension = ioncube_loader_lin_7.3.so' > ${PHP_INI_DIR}/php.d/10-ioncube.ini && \
####Install ImageMagick
###    mkdir -p ${TEMP_DIR}/ImageMagick && \
###    curl -Lks https://imagemagick.org/download/ImageMagick-7.0.8-47.tar.gz|tar -xz -C ${TEMP_DIR}/ImageMagick/ --strip-components=1 && \
###    cd ${TEMP_DIR}/ImageMagick && \
###    ./configure --prefix=/usr/local/imagemagick && \
###    make -j "$(getconf _NPROCESSORS_ONLN)" && \
###    make install && \
###    cd - && \
####Install imagick
###    ${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/imagick-3.4.4.tgz && \
###    echo -e '[ImageMagick]\nextension = imagick.so' > ${PHP_INI_DIR}/php.d/10-ImageMagick.ini && \
#Modify file permissions
###     chmod +x -R /usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/ && \
    chmod +x -R /usr/local/php/lib/php/extensions/no-debug-non-zts-20200930/ && \
\
    #docker-php-source delete && \
    runDeps="$( scanelf --needed --nobanner --recursive /usr/local | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
    runDeps="${runDeps} inotify-tools supervisor logrotate python3 tzdata" && \
    apk add --no-cache --virtual .php-rundeps $runDeps && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
#Clear OS
    apk del .build-deps && \
###    bash -c "rm -rf /tmp/{php,pear,memcache{,d},libevent,event}"
    echo

COPY docker-php-ext-* /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
COPY php-fpm.conf ${PHP_INI_DIR}/
ADD etc /etc
#ADD php-fpm.conf ${INSTALL_DIR}/etc/php-fpm.conf

WORKDIR /data/wwwroot

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/php/sbin/php-fpm"]
