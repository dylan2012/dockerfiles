FROM dylan2012/alpine:3.14
MAINTAINER from dylan

ENV PHP_VERSION="7.4.25" \
    INSTALL_DIR=/usr/local/php DATA_DIR=/data/wwwroot TEMP_DIR=/tmp/php \
    PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"

ENV PHP_INI_DIR="${INSTALL_DIR}/etc" \
    PATH="$INSTALL_DIR/bin:$INSTALL_DIR/sbin:$PATH" \
    PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www --with-fpm-group=www" \
    PHP_CPPFLAGS="$PHP_CFLAGS" \
    PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
    GPG_KEYS=5A52880781F755608BF815FC910DEB46F53EA312 \
    PHP_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror" \
    PHP_ASC_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz.asc/from/this/mirror" \
    PHP_SHA256="1fa46ca6790d780bf2cb48961df65f0ca3640c4533f0bca743cd61b71cb66335" \
    PHP_MD5="6e0b6f6ac5c726e1194bff67f421cb5f"

# GPG_KEYS=
# 5.3 0B96609E270F565C13292B24C13C70B87267B52D
# 5.4 F38252826ACD957EF380D39F2F7956BC5DA04B5D
# 5.5 0BD78B5F97500D450838F95DFE857D9A90D90EC1
# 5.6 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3
# 7.0 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763
# 7.1 A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0
# 7.2 1729F83938DA44E27BA0F4D3DBDB397470D12172
# 7.3 CBAF69F173A0FEA4B537F470D66C9593118BCCB6
# 7.4 5A52880781F755608BF815FC910DEB46F53EA312
# 8.0 1729F83938DA44E27BA0F4D3DBDB397470D12172
# 8.1 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E

# d7b95830ccbc909980bd0c202e6606ad  php-8.0.6.tar.xz
# e9871d3b6c391fe9e89f86f6334852dcc10eeaaa8d5565beb8436e7f0cf30e20  php-8.0.6.tar.xz
# ae27a7444ede5f2e118b6fd869d29958  php-8.0.5.tar.xz
# 5dd358b35ecd5890a4f09fb68035a72fe6b45d3ead6999ea95981a107fd1f2ab  php-8.0.5.tar.xz
# 6baaddeea5823ade61609f4c4d90f7a7  php-8.0.3.tar.xz
# c9816aa9745a9695672951eaff3a35ca5eddcb9cacf87a4f04b9fb1169010251  php-8.0.3.tar.xz
# 4fc1c90ee10b72d6a56447f8491a9857  php-8.0.2.tar.xz
# 84dd6e36f48c3a71ff5dceba375c1f6b34b71d4fa9e06b720780127176468ccc  php-8.0.2.tar.xz
# f860a700a0eb929444c85f3ca53faa60  php-8.0.1.tar.xz
# 208b3330af881b44a6a8c6858d569c72db78dab97810332978cc65206b0ec2dc  php-8.0.1.tar.xz
# 52ad70ea64968d6095c6e38139533d57  php-8.0.0.tar.xz
# b5278b3eef584f0c075d15666da4e952fa3859ee509d6b0cc2ed13df13f65ebb  php-8.0.0.tar.x
# 
# 6e0b6f6ac5c726e1194bff67f421cb5f  php-7.4.20.tar.xz
# 1fa46ca6790d780bf2cb48961df65f0ca3640c4533f0bca743cd61b71cb66335  php-7.4.20.tar.xz
# 287ee24d4401489881be7338eff87f77  php-7.4.19.tar.xz
# 6c17172c4a411ccb694d9752de899bb63c72a0a3ebe5089116bc13658a1467b2  php-7.4.19.tar.xz
# 
# 1be06424d70625db235c79209f939a87  php-7.3.28.tar.xz
# a2a84dbec8c1eee3f46c5f249eaaa2ecb3f9e7a6f5d0604d2df44ff8d4904dbe  php-7.3.28.tar.xz
# f43ed3ac572a0ec7452be15f4ae7c28c  php-7.3.27.tar.xz
# 65f616e2d5b6faacedf62830fa047951b0136d5da34ae59e6744cbaf5dca148d  php-7.3.27.tar.xz

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
        libjpeg-turbo-dev libpng-dev libmcrypt-dev icu-dev freetype-dev gettext-dev libxslt-dev zlib-dev libzip-dev freetype zlib libjpeg libpng \
        oniguruma-dev imagemagick-dev ${MEMCACHE_DEPS} && \
    apk add yasm && apk add ffmpeg && \
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
        --with-zip \
        --enable-soap \
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
        --enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
        --enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
        --enable-mysqlnd \
        --with-iconv \
        --with-iconv-dir=/usr/local \
        --with-freetype \
        --with-jpeg \
        --with-zlib \
        --with-zlib-dir \
        --with-libxml-dir=/usr \
        --with-curl=/usr/local \
        --with-mcrypt \
        --enable-gd \
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
#Install MongoDb
    ${INSTALL_DIR}/bin/pecl install mongodb && \
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
###    ${INSTALL_DIR}/bin/pecl install memcache && \
###php8.0
###    ${INSTALL_DIR}/bin/pecl install http://pecl.php.net/get/memcache-8.0.tgz && \
###php7.4.20
    ${INSTALL_DIR}/bin/pecl install http://pecl.php.net/get/memcache-4.0.5.2.tgz && \
####Install ionCube
###    mkdir -p ${TEMP_DIR}/ioncube && \
###    curl -Lk https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz | tar -xz -C ${TEMP_DIR}/ioncube/ --strip-components=1 && \
###    cp ${TEMP_DIR}/ioncube/ioncube_loader_lin_7.3.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/ && \
###    echo -e '[ionCube Loader]\nzend_extension = ioncube_loader_lin_7.3.so' > ${PHP_INI_DIR}/php.d/10-ioncube.ini && \
####Install ImageMagick
    mkdir -p ${TEMP_DIR}/ImageMagick && \
    curl -Lks http://www.imagemagick.org/download/ImageMagick.tar.gz|tar -xz -C ${TEMP_DIR}/ImageMagick/ --strip-components=1 && \
    cd ${TEMP_DIR}/ImageMagick && \
    ./configure --prefix=/usr/local/imagemagick && \
    make -j "$(getconf _NPROCESSORS_ONLN)" && \
    make install && \
    cd - && \
####Install imagick
    ${INSTALL_DIR}/bin/pecl install https://pecl.php.net/get/imagick-3.4.4.tgz && \
    echo -e '[ImageMagick]\nextension = imagick.so' > ${PHP_INI_DIR}/php.d/10-ImageMagick.ini && \
#Modify file permissions
###
###chmod +x -R /usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/ && \
###php7.4.x
    chmod +x -R /usr/local/php/lib/php/extensions/no-debug-non-zts-20190902/ && \
###php8.0.6-8.0.7
####    chmod +x -R /usr/local/php/lib/php/extensions/no-debug-non-zts-20200930/ && \
\
    #docker-php-source delete && \
    runDeps="$( scanelf --needed --nobanner --recursive /usr/local | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
    runDeps="${runDeps} inotify-tools supervisor logrotate python3 tzdata" && \
    apk add --no-cache --virtual .php-rundeps $runDeps && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
#Clear OS
    apk del .build-deps && \
    bash -c "rm -rf /tmp/{php,pear,memcache{,d},libevent,event,ImageMagick}"
#    echo

COPY docker-php-ext-* /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
COPY php-fpm.conf ${PHP_INI_DIR}/
ADD etc /etc
#ADD php-fpm.conf ${INSTALL_DIR}/etc/php-fpm.conf

WORKDIR /data/wwwroot

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/php/sbin/php-fpm"]
