#!/bin/bash
set -e
#unset PHP_INI_DIR PHP_ASC_URL TEMP_DIR PHP_CFLAGS PHP_MD5 PHPIZE_DEPS PHP_URL PHP_LDFLAGS GPG_KEYS PHP_CPPFLAGS PHP_SHA256 PHP_EXTRA_CONFIGURE_ARGS
[[ "${1#-}" != "$1" ]] && set -- php-fpm "$@"

[ -d /data/wwwroot ] || mkdir -p /data/wwwroot
[[ ! "$NO_CHOWN" =~ ^[yY][eE][sS]$ ]] && chown -R www.www /data/wwwroot
[ "$EXPOSE_PHP" != "On" ] && EXPOSE_PHP=Off

PHP_INI_DIR=${PHP_INI_DIR:-$INSTALL_DIR/etc}
PHP_INI_CONF=${PHP_INI_CONF:-enable}
PHP_CLI=${PHP_CLI:-disable}
PHP_CLI_COMMAND=${PHP_CLI_COMMAND:-"php -a"}
OPCACHE=${OPCACHE:-enable}
EVENT=${EVENT:-enable}
REDIS=${REDIS:-enable}
MONGODB=${MONGODB:-enable}
MEMCACHE=${MEMCACHE:-enable}

XDEBUG_DEFAULT_CONF=${XDEBUG_DEFAULT_CONF:-enable}
XDEBUG=${XDEBUG:-disable}
XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-localhost}
XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:-9900}


TIMEZONE=${TIMEZONE-Asia/Shanghai}
POST_MAX_SIZE=${POST_MAX_SIZE:-100M}
UPLOAD_MAX_FILESIZE=${UPLOAD_MAX_FILESIZE:-50M}
MAX_EXECUTION_TIME=${MAX_EXECUTION_TIME:-5}
PHP_FPM_CONF=${PHP_FPM_CONF:-${PHP_INI_DIR}/php-fpm.conf}
PHP_FPM_PID=${PHP_FPM_PID:-${INSTALL_DIR}/var/run/php-fpm.pid}
PHP_SESSION_DIR=${PHP_SESSION_DIR:-${INSTALL_DIR}/var/session}
PHP_DISABLE_FUNCTIONS=${PHP_DISABLE_FUNCTIONS:-passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen}
DISPLAY_ERROES=${DISPLAY_ERROES:-Off}

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

[ -z "${MEM_LIMIT}" ] && mem_sum
set -- "$@" -F
set -- "$@" -y ${PHP_FPM_CONF}
set -- "$@" --pid ${PHP_FPM_PID}

sed -i "s@\$HOSTNAME@$HOSTNAME@" ${PHP_FPM_CONF}


if [[ $PHP_INI_CONF =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	sed -i "s@^memory_limit.*@memory_limit = ${MEM_LIMIT}M@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^output_buffering =@output_buffering = On\noutput_buffering =@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^short_open_tag = Off@short_open_tag = On@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^expose_php = On@expose_php = ${EXPOSE_PHP}@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^request_order.*@request_order = \"CGP\"@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^;date.timezone.*@date.timezone = ${TIMEZONE}@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^post_max_size.*@post_max_size = ${POST_MAX_SIZE}@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^upload_max_filesize.*@upload_max_filesize = ${UPLOAD_MAX_FILESIZE}@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^max_execution_time.*@max_execution_time = ${MAX_EXECUTION_TIME}@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^disable_functions.*@disable_functions = ${PHP_DISABLE_FUNCTIONS}@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@" ${PHP_INI_DIR}/php.ini
	sed -i "s@^display_errors.*@display_errors = ${DISPLAY_ERROES}@" ${PHP_INI_DIR}/php.ini
	[ -f ${PHP_SESSION_DIR} ] && { mkdir -p ${PHP_SESSION_DIR} && chown -R www:www ${INSTALL_DIR}/var; }
	sed -i "s@^;session.save_path = .*@session.save_path = \"${PHP_SESSION_DIR}\"@" ${PHP_INI_DIR}/php.ini
fi

if [[ "${OPCACHE}" =~ [eE][nN][aA][bB][lL][eE] ]]; then
	cat > ${PHP_INI_DIR}/php.d/10-opcache.ini <<-EOF
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

if [[ "${EVENT}" =~ [eE][nN][aA][bB][lL][eE] ]]; then
	cat > ${PHP_INI_DIR}/php.d/10-event.ini <<-EOF
		[event]
		extension=event.so
	EOF
fi

if [[ "$MEMCACHE" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	echo 'extension=memcache.so' > ${PHP_INI_DIR}/php.d/10-memcache.ini
	cat > ${PHP_INI_DIR}/php.d/10-memcached.ini <<-EOF
		[memcached]
		extension=memcached.so
		memcached.use_sasl=1
	EOF
fi

if [[ "$MONGODB" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	cat > ${PHP_INI_DIR}/php.d/10-mongodb.ini <<-EOF
		[mongodb]
		extension=mongodb.so
	EOF
fi

if [[ "$REDIS" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	cat > ${PHP_INI_DIR}/php.d/10-redis.ini <<-EOF
		[redis]
		extension=redis.so
	EOF
fi

if [[ "${SWOOLE}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	cat > ${PHP_INI_DIR}/php.d/10-swoole.ini <<-EOF
		[swoole]
		extension=swoole.so
	EOF
fi

if [[ "${XDEBUG}" =~ [eE][nN][aA][bB][lL][eE] ]]; then
	if [[ "${XDEBUG_DEFAULT_CONF}" =~ [eE][nN][aA][bB][lL][eE] ]]; then
		cat >> ${PHP_INI_DIR}/php.d/10-xdebug.ini <<-EOF
			[xdebug]
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
	elif [[ ! -f ${PHP_INI_DIR}/php.d/10-xdebug.ini ]]; then
		echo >&2 "error:  missing Can't found ${PHP_INI_DIR}/php.d/10-xdebug.ini"
		echo >&2 "Did you forget to add -v /xdebug_config_file:${PHP_INI_DIR}/php.d/10-xdebug.ini"
		exit 1
	fi
fi

[[ "${PHP_CLI}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]] && { shift $# && set -- ${PHP_CLI_COMMAND} $@; }

#exec "$@"

[ -f /var/log/supervisor ] || mkdir -p /var/log/supervisor
[ -f /data/wwwlogs/supervisor ] || mkdir -p /data/wwwlogs/supervisor

supervisord -n -c /etc/supervisord.conf
