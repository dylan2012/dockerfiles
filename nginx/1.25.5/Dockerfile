FROM alpine:3.19
MAINTAINER from Dylan

ARG VERSION=${VERSION:-1.25.5}
ARG AUTOINDEX_NAME_LEN=${AUTOINDEX_NAME_LEN:-100}

ENV INSTALL_DIR=/usr/local/nginx \
        DATA_DIR=/data/wwwroot \
                GEOIP_VERSION=3.3 \
        TEMP_DIR=/tmp/nginx
COPY nginx_mod_h264_streaming-2.2.7.tar.gz /tmp/
RUN set -x && \
        mkdir -p $(dirname ${DATA_DIR}) ${TEMP_DIR} /tmp/ngx_http_geoip2_module && \
        apk update && \
        apk --update --no-cache upgrade && \  
		export PERSISTENT_DEPS="bash wget curl xz ca-certificates tar git iproute2 openssl  " && \
		apk add --no-cache --virtual .persistent-deps ${PERSISTENT_DEPS} && \
        apk add --no-cache --virtual .build-deps geoip geoip-dev pcre libxslt gd libssh2 ncurses-terminfo pkgconf pkgconfig libice libsm libxt libxpm openssl-dev pcre-dev zlib-dev  \
        build-base linux-headers libxslt-dev gd-dev libmaxminddb-dev libstdc++ libgcc patch git luajit-dev && \
        cd ${TEMP_DIR} && \
        DOWN_URL="http://nginx.org/download" && \
        DOWN_URL="${DOWN_URL}/nginx-${VERSION}.tar.gz" && \
        FILE_NAME=${DOWN_URL##*/} && mkdir -p ${TEMP_DIR}/${FILE_NAME%%\.tar*} && \
        curl -Lk ${DOWN_URL} | tar xz -C ${TEMP_DIR} --strip-components=1 && \
        GEOIP_DOWN_URL="https://github.com/leev/ngx_http_geoip2_module/archive/$GEOIP_VERSION.tar.gz" && \
        curl -Lk ${GEOIP_DOWN_URL} | tar xz -C /tmp/ngx_http_geoip2_module --strip-components=1 && \
        #H264_DOWN_URL="https://github.com/code-shop-com/h264/blob/main/download/nginx_mod_h264_streaming-2.2.7.tar.gz" && \
        #wget ${H264_DOWN_URL} && tar -zxvf nginx_mod_h264_streaming-2.2.7.tar.gz -C /tmp/nginx_mod_h264_streaming && \
		tar -zxvf /tmp/nginx_mod_h264_streaming-2.2.7.tar.gz -C /tmp/ && \
		mv /tmp/nginx_mod_h264_streaming-2.2.7 /tmp/nginx_mod_h264_streaming && \
        sed -i '158,161d' /tmp/nginx_mod_h264_streaming/src/ngx_http_streaming_module.c && \
        git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
        git clone https://github.com/aperezdc/ngx-fancyindex.git && \
        git clone https://github.com/simplresty/ngx_devel_kit.git && \
        git clone https://github.com/openresty/lua-nginx-module.git && \
        git clone https://github.com/vozlt/nginx-module-vts.git && \
        git clone https://github.com/yaoweibin/nginx_upstream_check_module.git && \
		patch -p1 < ./nginx_upstream_check_module/check_1.20.1+.patch && \
        git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git && \
        git clone https://github.com/yzprofile/ngx_http_dyups_module.git && \
        git clone https://github.com/cfsego/ngx_log_if.git && \
        git clone https://github.com/openresty/headers-more-nginx-module.git && \
        git clone https://github.com/ipipdotnet/nginx-ipip-module.git && \
		git clone https://github.com/openresty/lua-resty-core.git && \
		cd lua-resty-core && \
		make install LUA_LIB_DIR=/usr/local/share/lua/5.1 && \
		cd ${TEMP_DIR} && \
		git clone https://github.com/openresty/lua-resty-lrucache.git && \
		cd lua-resty-lrucache/ && \
		make install LUA_LIB_DIR=/usr/local/share/lua/5.1 && \
		cd ${TEMP_DIR} && \
        addgroup -g 400 -S www && \
        adduser -u 400 -S -h ${DATA_DIR} -s /sbin/nologin -g 'WEB Server' -G www www && \
        export LUAJIT_LIB=/usr/lib && \
        export LUAJIT_INC=/usr/include/luajit-2.1 && \
        CFLAGS=-Wno-unused-but-set-variable ./configure --prefix=${INSTALL_DIR} \
                --user=www --group=www \
                --error-log-path=/data/wwwlogs/error.log \
                --http-log-path=/data/wwwlogs/access.log \
                --pid-path=/usr/local/nginx/nginx.pid \
                --lock-path=/var/lock/nginx.lock \
                --with-pcre \
                --with-mail \
                --with-mail_ssl_module \
                --with-pcre-jit \
                --with-file-aio \
                --with-compat \
                --with-threads \
                --with-stream \
                --with-stream_ssl_module \
                --with-http_ssl_module \
                --with-http_flv_module \
                --with-http_v2_module \
                --with-http_realip_module \
                --with-http_gzip_static_module \
                --with-http_stub_status_module \
                --with-http_sub_module \
                --with-http_mp4_module \
                --with-http_image_filter_module \
                --with-http_addition_module \
                --with-http_auth_request_module \
                --with-http_dav_module \
                --with-http_degradation_module \
                --with-http_geoip_module \
                --with-http_xslt_module \
                --with-http_gunzip_module \
                --with-http_secure_link_module \
                --with-http_slice_module \
                --add-module=./ngx-fancyindex \
                --add-module=./ngx_http_substitutions_filter_module \
                --add-module=./ngx_devel_kit \
                --add-module=./lua-nginx-module \
                --add-module=./nginx-module-vts \
                --add-module=./nginx_upstream_check_module \
                --add-module=./ngx_log_if \
                --add-module=./ngx_http_dyups_module \
                --add-module=./headers-more-nginx-module \
                --add-dynamic-module=./nginx-ipip-module \
                --add-dynamic-module=/tmp/ngx_http_geoip2_module \
                --add-module=/tmp/nginx_mod_h264_streaming \
        && \
        make -j$(getconf _NPROCESSORS_ONLN) && \
        make install && \
        runDeps="$( scanelf --needed --nobanner --recursive /usr/local/ | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
        runDeps="${runDeps} inotify-tools supervisor logrotate luajit-dev certbot certbot-nginx" && \
        apk del .build-deps && \
        apk add --no-cache --virtual .ngx-rundeps $runDeps && \
        echo "0       3       */7     *       *       /usr/bin/certbot renew --renew-hook 'nginx -s reload'"|tee -a /etc/crontabs/root > /dev/null && \
        rm -rf /var/cache/apk/* /tmp/* 

ENV PATH=${INSTALL_DIR}/sbin:$PATH \
        TERM=linux

ADD etc /etc
RUN set -x && mv /etc/entrypoint.sh entrypoint.sh && chmod +x /entrypoint.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
