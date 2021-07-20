#!/bin/bash
#########################################################################
# File Name: entrypoint.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年08月13日 星期六 00时50分04秒
#########################################################################

set -e

[ "${1:0:1}" = '-' ] && set -- php-fpm "$@"

mem_sum() {
	Mem=`free -m | awk '/Mem:/{print $2}'`
	Swap=`free -m | awk '/Swap:/{print $2}'`

	if [ $Mem -le 640 ];then
		MEM_LIMIT=64
	elif [ $Mem -gt 640 -a $Mem -le 1280 ];then
		MEM_LIMIT=128
	elif [ $Mem -gt 1280 -a $Mem -le 2500 ];then
		MEM_LIMIT=192
	elif [ $Mem -gt 2500 -a $Mem -le 3500 ];then
		MEM_LIMIT=256
	elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
		MEM_LIMIT=320
	elif [ $Mem -gt 4500 -a $Mem -le 8000 ];then
		MEM_LIMIT=384
	elif [ $Mem -gt 8000 ];then
		MEM_LIMIT=448
	fi
}

[ -d /data/wwwroot ] || mkdir -p /data/wwwroot
[ -d /data/wwwlogs/supervisor ] || mkdir -p /data/wwwlogs/supervisor
[ -d /var/log/supervisor ] || mkdir -p /var/log/supervisor
chown -R www.www /data/wwwroot
[ -z "${MEM_LIMIT}" ] && mem_sum
[ "$EXPOSE_PHP" != "On" ] && EXPOSE_PHP=Off
PHP_INI_CONF=${PHP_INI_CONF:-enable}
PHP_FPM_CONF_DEF=${PHP_FPM_CONF_DEF:-enable}

if [[ "$MEMCACHE" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	echo 'extension=memcache.so' > ${INSTALL_DIR}/etc/php.d/ext-memcache.ini
	cat > ${INSTALL_DIR}/etc/php.d/ext-memcached.ini <<-EOF
		extension=memcached.so
		memcached.use_sasl=1
	EOF
fi

if [[ "$REDIS" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	cat > ${INSTALL_DIR}/etc/php.d/ext-redis.ini <<-EOF
		[redis]
		extension=redis.so
	EOF
fi

if [[ "${SWOOLE}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	echo 'extension=swoole.so' > ${INSTALL_DIR}/etc/php.d/ext-swoole.ini
fi

if [[ "${MONGO}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	echo 'extension=mongo.so' > ${INSTALL_DIR}/etc/php.d/ext-mongo.ini
fi

if [[ "${MONGODB}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	echo 'extension=mongodb.so' > ${INSTALL_DIR}/etc/php.d/ext-mongodb.ini
fi

if [[ "$FILEINFO" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	echo 'extension=fileinfo.so' > ${INSTALL_DIR}/etc/php.d/ext-fileinfo.ini
fi

OPCACHE=${OPCACHE:-enable}

XDEBUG_DEFAULT_CONF=${XDEBUG_DEFAULT_CONF:-enable}
XDEBUG=${XDEBUG:-disable}
XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-localhost}
XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:-9900}


TIMEZONE=${TIMEZONE-Asia/Shanghai}
POST_MAX_SIZE=${POST_MAX_SIZE-100M}
UPLOAD_MAX_FILESIZE=${UPLOAD_MAX_FILESIZE-50M}
MAX_EXECUTION_TIME=${MAX_EXECUTION_TIME-5}
PHP_FPM_CONF=${PHP_FPM_CONF-${INSTALL_DIR}/etc/php-fpm.conf}
PHP_FPM_PID=${PHP_FPM_PID-${INSTALL_DIR}/var/run/php-fpm.pid}
PHP_DISABLE_FUNCTIONS=${PHP_DISABLE_FUNCTIONS:-passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen}
DISPLAY_ERROES=${DISPLAY_ERROES:-Off}

set -- "$@" -F
set -- "$@" -y ${PHP_FPM_CONF}
set -- "$@" --pid ${PHP_FPM_PID}

if [[ $PHP_FPM_CONF_DEF =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	sed -i "s@\$HOSTNAME@$HOSTNAME@" ${PHP_FPM_CONF}
fi

if [[ $PHP_INI_CONF =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	sed -i "s@^memory_limit.*@memory_limit = ${MEM_LIMIT}M@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^output_buffering =.*@output_buffering = On@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^short_open_tag = Off@short_open_tag = On@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^expose_php = On@expose_php = ${EXPOSE_PHP}@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^request_order.*@request_order = \"CGP\"@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^;date.timezone.*@date.timezone = ${TIMEZONE}@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^post_max_size.*@post_max_size = ${POST_MAX_SIZE}@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^upload_max_filesize.*@upload_max_filesize = ${UPLOAD_MAX_FILESIZE}@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^max_execution_time.*@max_execution_time = ${MAX_EXECUTION_TIME}@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^disable_functions.*@disable_functions = ${PHP_DISABLE_FUNCTIONS}@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@" ${INSTALL_DIR}/etc/php.ini
	sed -i "s@^display_errors.*@display_errors = ${DISPLAY_ERROES}@" ${INSTALL_DIR}/etc/php.ini
fi

if [[ "${ICONV}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	echo "extension=iconv.so" > ${INSTALL_DIR}/etc/php.d/iconv.ini
fi

if [[ "${OPCACHE}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	cat > ${INSTALL_DIR}/etc/php.d/ext-opcache.ini <<-EOF
		[opcache]
		zend_extension=opcache.so
		opcache.enable=1
		opcache.memory_consumption=$MEM_LIMIT
		opcache.interned_strings_buffer=8
		opcache.max_accelerated_files=4000
		opcache.revalidate_freq=60
		opcache.save_comments=0
		opcache.fast_shutdown=1
		opcache.enable_cli=1
		;opcache.optimization_level=0
	EOF
fi

if [[ "${XDEBUG}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	if [[ "${XDEBUG_DEFAULT_CONF}" =~ [eE][nN][aA][bB][lL][eE] ]]; then
		cat >> ${INSTALL_DIR}/etc/php.d/ext-xdebug.ini <<-EOF
			zend_extension="xdebug.so"
			xdebug.remote_enable=on
			;远程调试开关
			xdebug.remote_handler="dbgp"
			;官方文档说从xdebug2.1以后的版本只支持dbgp这个协议
			xdebug.remote_host = "${XDEBUG_REMOTE_HOST}"
			;远程调试xdebug回连的主机ip，如果开启了remote_connect_back，则该配置无效
			xdebug.remote_port = $XDEBUG_REMOTE_PORT
			;远程调试回连的port，默认即为9000，如果有端口冲突，可以修改，对应ide的debug配置里面也要同步修改
			xdebug.remote_connect_back=1
			;是否回连，如果开启该选项，那么xdebug回连的ip会是发起调试请求对应的ip
			xdebug.auto_trace=on
			;当此设置被设置为on，函数调用跟踪将要启用的脚本运行之前。这使得有可能跟踪代码中的auto_prepend_file。
			xdebug.auto_profile=on
			xdebug.collect_params=on
			xdebug.collect_return = on
			xdebug.profiler_enable = on
			xdebug.trace_output_dir = "/tmp"
			xdebug.profiler_output_dir = "/tmp"
			xdebug.dump.GET = *
			xdebug.dump.POST = *
			xdebug.dump.COOKIE = *
			xdebug.dump.SESSION = *
			xdebug.var_display_max_data = 4056
			xdebug.var_display_max_depth = 5
			;xdebug.idekey=netbeans
			;调试使用的关键字，发起IDE上的idekey应该和这里配置的idekey一致，不一致则无效
		EOF
	elif [[ ! -f ${INSTALL_DIR}/etc/php.d/ext-xdebug.ini ]]; then
		echo >&2 "error:  missing Can't found ${INSTALL_DIR}/etc/php.d/ext-xdebug.ini"
		echo >&2 "Did you forget to add -v /xdebug_config_file:${INSTALL_DIR}/etc/php.d/ext-xdebug.ini"
		exit 1
	fi
fi

#exec "$@"
supervisord -n -c /etc/supervisord.conf
