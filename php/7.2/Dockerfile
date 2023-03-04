FROM centos:centos7
ENV PHP_VERSION="7.2" \
    TEMP_DIR=/tmp/php
RUN set -xe  && \
		mkdir -p ${TEMP_DIR} && cd ${TEMP_DIR} && \
        yum install -y epel-release && yum install -y wget curl git gcc make gcc-c++ openssl openssl-devel&& \
        rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm && \
        yum -y install php72w php72w-cli php72w-fpm php72w-common php72w-devel php72w-embedded php72w-gd php72w-mbstring php72w-mysqlnd php72w-opcache php72w-pdo php72w-xml php72w-process && \
	#install yaconf
		wget http://pear.php.net/go-pear.phar && php go-pear.phar && pecl install yaconf && \
		echo 'extension=yaconf.so' > /etc/php.d/yaconf.ini && \
	#install swoole
		wget https://github.com/swoole/swoole-src/archive/refs/tags/v4.3.3.tar.gz && \
        tar xf v4.3.3.tar.gz  && \
        cd swoole-src-4.3.3/  && \
        phpize  && \
        ./configure --enable-openssl  --enable-http2 --enable-mysqlnd  && \
        make -j4  && \
        make install && \
		echo 'extension=swoole.so' > /etc/php.d/swoole.ini &&\
	#install phptars
		git clone https://github.com/TarsPHP/tars-extension.git && \
        cd tars-extension && \
        /usr/bin/phpize && \
        ./configure --with-php-config=/usr/bin/php-config && \
        make -j4 && make install && \
		echo 'extension=phptars.so' > /etc/php.d/phptars.ini && \
		rm -rf ${TEMP_DIR} && yum remove -y gcc make gcc-c++ openssl-devel git
