# docker-php

# Docker 安装
```bash
curl -Lks https://get.docker.com/ | sh
```

## 可用变量说明

| 变量名 | 默认值 | 描述 |
| -------- | ------------- | ----------- |
| MEM_LIMIT | 自动计算 | memory_limit的值 |
| EXPOSE_PHP | Off  | 可选值Off或者On |
| MEMCACHE | disable | PHP Memcache 插件开关 |
| REDIS | disable | PHP Redis 插件开关 |
| TIMEZONE | Asia/Shanghai | PHP 时区 |
| POST_MAX_SIZE | 100M | PHP post_max_size 值 |
| UPLOAD_MAX_FILESIZE | 50M | PHP upload_max_filesize 值 |
| MAX_EXECUTION_TIME | 5 | PHP脚本执行最大超时时间 |
| PHP_FPM_CONF | ${INSTALL_DIR}/etc/php-fpm.conf | PHP-FPM 配置文件路径 |
| PHP_FPM_PID | ${INSTALL_DIR}/var/run/php-fpm.pid | PHP-PID 路径 |
| PHP_DISABLE_FUNCTIONS | 见注1 | PHP disable_functions 值 |
| DISPLAY_ERROES | Off | 控制PHP错误是否输出 |
| OPCACHE | enable | 默认启用opcache |
| XDEBUG | disable | 控制启用Xdebug |
| XDEBUG_REMOTE_HOST | localhost | 设定Xdebug的监听地址 |
| XDEBUG_REMOTE_PORT | 9900 | 设定Xdebug的监听端口 |
| XDEBUG_DEFAULT_CONF | enable | 默认使用默认的Xdebug的配置文件 |

## 已安装扩展
Swoole、Redis、Xdebug、Event、Memcached、Memcache、ionCube、imagick


```bash
# 注1: PHP_DISABLE_FUNCTIONS=passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen
```
