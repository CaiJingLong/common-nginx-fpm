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
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libxpm-dev \
    libzip-dev \
    bzip2-dev \
    gettext-dev \
    libxslt-dev \
    openldap-dev \
    libsodium-dev \
    oniguruma-dev \
    linux-headers \
    autoconf \
    && rm -rf /var/cache/apk/*

# 配置GD扩展
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-xpm

# 安装PHP扩展 - 单独安装以最大化缓存利用
# 基础数学扩展
RUN docker-php-ext-install -j$(nproc) bcmath
RUN docker-php-ext-install -j$(nproc) bz2
RUN docker-php-ext-install -j$(nproc) zip

# 图像处理扩展
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) exif

# 数据库核心扩展
RUN docker-php-ext-install -j$(nproc) pdo
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) pdo_pgsql
RUN docker-php-ext-install -j$(nproc) pdo_sqlite
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) pgsql

# XML处理扩展
RUN docker-php-ext-install -j$(nproc) dom
RUN docker-php-ext-install -j$(nproc) xml
RUN docker-php-ext-install -j$(nproc) xmlreader
RUN docker-php-ext-install -j$(nproc) xmlwriter
RUN docker-php-ext-install -j$(nproc) simplexml
RUN docker-php-ext-install -j$(nproc) xsl
RUN docker-php-ext-install -j$(nproc) soap

# 系统和网络扩展
RUN docker-php-ext-install -j$(nproc) pcntl
RUN docker-php-ext-install -j$(nproc) posix
RUN docker-php-ext-install -j$(nproc) sockets
# 安装FTP扩展前添加构建依赖
RUN apk add --no-cache --virtual .build-deps file re2c g++
RUN docker-php-ext-install -j$(nproc) ftp
RUN apk del .build-deps

# 其他常用扩展
RUN docker-php-ext-install -j$(nproc) fileinfo
RUN docker-php-ext-install -j$(nproc) gettext
RUN docker-php-ext-install -j$(nproc) mbstring
RUN docker-php-ext-install -j$(nproc) opcache
RUN docker-php-ext-install -j$(nproc) shmop

# 安装LDAP扩展 (需要特殊配置)
RUN docker-php-ext-configure ldap --with-libdir=lib/ && \
    docker-php-ext-install ldap

# 安装Redis扩展
RUN apk add --no-cache make
RUN pecl install redis && docker-php-ext-enable redis

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
