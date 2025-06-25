# 使用官方PHP-FPM Alpine镜像作为基础
FROM php:8.4-fpm-alpine

# 设置维护者信息
LABEL maintainer="Common Nginx PHP-FPM Image"

# 安装系统依赖和nginx
RUN apk add --no-cache \
    nginx \
    supervisor \
    postgresql-dev \
    mysql-dev \
    && rm -rf /var/cache/apk/*

# 安装常用PHP扩展
RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    mysqli \
    opcache

# 创建必要的目录
RUN mkdir -p /var/www/html \
    /var/log/nginx \
    /var/log/php-fpm \
    /etc/supervisor/conf.d \
    /var/lib/php/sessions \
    /run/nginx && \
    chown -R nginx:nginx /var/www/html \
    /var/log/nginx \
    /var/log/php-fpm \
    /var/lib/php/sessions \
    /run/nginx

# 复制配置文件
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/php.ini /usr/local/etc/php/php.ini
COPY config/www.conf /usr/local/etc/php-fpm.d/www.conf

# 复制supervisor配置
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 设置工作目录
WORKDIR /var/www/html

# 创建默认的index.php文件
RUN echo '<?php phpinfo(); ?>' > /var/www/html/index.php

# 暴露端口
EXPOSE 80

# 设置启动命令
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
