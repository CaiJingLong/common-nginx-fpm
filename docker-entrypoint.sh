#!/bin/sh
set -e

# 创建必要的目录
mkdir -p /var/log/nginx
mkdir -p /var/log/php-fpm
mkdir -p /var/lib/php/sessions
mkdir -p /var/log/supervisor

# 设置权限
chown -R nginx:nginx /var/www/html
chown -R nginx:nginx /var/lib/php/sessions
chmod 755 /var/lib/php/sessions

# 检查并复制配置文件（支持外部覆盖）
echo "Checking configuration files..."

# 检查nginx配置
if [ -f "/etc/nginx/conf.d/default.conf" ]; then
    echo "Using custom nginx configuration from /etc/nginx/conf.d/default.conf"
elif [ ! -f "/etc/nginx/nginx.conf" ]; then
    echo "Copying default nginx configuration..."
    cp /etc/nginx/nginx.conf.default /etc/nginx/nginx.conf
fi

# 检查PHP配置
if [ -f "/usr/local/etc/php/conf.d/custom.ini" ]; then
    echo "Using custom PHP configuration from /usr/local/etc/php/conf.d/custom.ini"
fi

# 检查PHP-FPM配置
if [ -f "/usr/local/etc/php-fpm.d/custom.conf" ]; then
    echo "Using custom PHP-FPM configuration from /usr/local/etc/php-fpm.d/custom.conf"
fi

# 测试nginx配置
echo "Testing nginx configuration..."
nginx -t

# 测试PHP-FPM配置
echo "Testing PHP-FPM configuration..."
php-fpm -t

echo "Starting services..."

# 执行传入的命令
exec "$@"
