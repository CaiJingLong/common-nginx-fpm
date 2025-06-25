#!/bin/bash

# 测试PHP扩展安装脚本
echo "🔍 测试PHP扩展安装..."

# 构建镜像
echo "📦 构建Docker镜像..."
docker build -t common-nginx-fpm:test . || {
    echo "❌ 镜像构建失败"
    exit 1
}

echo "✅ 镜像构建成功"

# 运行容器并测试扩展
echo "🧪 测试PHP扩展..."
docker run --rm common-nginx-fpm:test php -m > /tmp/php_modules.txt

echo "📋 已安装的PHP扩展："
cat /tmp/php_modules.txt

echo ""
echo "🔍 检查关键扩展："

# 检查关键扩展
extensions=(
    "bcmath"
    "bz2" 
    "curl"
    "dom"
    "exif"
    "fileinfo"
    "ftp"
    "gd"
    "gettext"
    "iconv"
    "ldap"
    "mbstring"
    "mysqli"
    "opcache"
    "pcntl"
    "pdo"
    "pdo_mysql"
    "pdo_pgsql"
    "pdo_sqlite"
    "pgsql"
    "posix"
    "redis"
    "shmop"
    "simplexml"
    "soap"
    "sockets"
    "sqlite3"
    "xml"
    "xmlreader"
    "xmlwriter"
    "xsl"
    "zip"
)

missing_extensions=()

for ext in "${extensions[@]}"; do
    # 特殊处理一些扩展名称的变体
    case $ext in
        "opcache")
            if grep -q "^Zend OPcache$" /tmp/php_modules.txt; then
                echo "✅ $ext"
            else
                echo "❌ $ext (缺失)"
                missing_extensions+=("$ext")
            fi
            ;;
        "pdo")
            if grep -q "^PDO$" /tmp/php_modules.txt; then
                echo "✅ $ext"
            else
                echo "❌ $ext (缺失)"
                missing_extensions+=("$ext")
            fi
            ;;
        "simplexml")
            if grep -q "^SimpleXML$" /tmp/php_modules.txt; then
                echo "✅ $ext"
            else
                echo "❌ $ext (缺失)"
                missing_extensions+=("$ext")
            fi
            ;;
        *)
            if grep -q "^$ext$" /tmp/php_modules.txt; then
                echo "✅ $ext"
            else
                echo "❌ $ext (缺失)"
                missing_extensions+=("$ext")
            fi
            ;;
    esac
done

if [ ${#missing_extensions[@]} -eq 0 ]; then
    echo ""
    echo "🎉 所有扩展安装成功！"
else
    echo ""
    echo "⚠️  缺失的扩展: ${missing_extensions[*]}"
fi

# 清理临时文件
rm -f /tmp/php_modules.txt

echo ""
echo "📊 镜像信息："
docker images common-nginx-fpm:test --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
