#!/bin/bash

# 测试nginx重定向是否正确处理端口号
# 使用方法: ./test-redirect.sh [port]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认端口
PORT=${1:-8080}
CONTAINER_NAME="test-redirect-nginx-fpm"

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%H:%M:%S')] ${message}${NC}"
}

# 清理函数
cleanup() {
    print_message $YELLOW "清理测试环境..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

# 设置清理陷阱
trap cleanup EXIT

print_message $BLUE "开始测试nginx重定向功能 (端口: $PORT)"

# 构建镜像
print_message $BLUE "构建测试镜像..."
docker build -t common-nginx-fpm-alpine . > /dev/null

# 启动容器
print_message $BLUE "启动测试容器..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:80 \
    -v $(pwd)/src:/var/www/html \
    common-nginx-fpm-alpine > /dev/null

# 等待容器启动
print_message $BLUE "等待服务启动..."
sleep 5

# 创建测试目录和文件
print_message $BLUE "创建测试文件..."
mkdir -p src/test
cat > src/test/redirect.php << 'EOF'
<?php
// 测试重定向
if (!isset($_GET['redirected'])) {
    // 执行重定向
    header("Location: /test/redirect.php?redirected=1");
    exit;
}

echo "重定向测试成功！";
echo "<br>当前URL: " . $_SERVER['REQUEST_URI'];
echo "<br>服务器端口: " . $_SERVER['SERVER_PORT'];
echo "<br>HTTP_HOST: " . $_SERVER['HTTP_HOST'];
?>
EOF

# 测试健康检查
print_message $BLUE "测试健康检查..."
if curl -s "http://localhost:$PORT/health" > /dev/null; then
    print_message $GREEN "✅ 健康检查通过"
else
    print_message $RED "❌ 健康检查失败"
    exit 1
fi

# 测试基本访问
print_message $BLUE "测试基本访问..."
if curl -s "http://localhost:$PORT/" | grep -q "PHP"; then
    print_message $GREEN "✅ 基本访问正常"
else
    print_message $RED "❌ 基本访问失败"
    exit 1
fi

# 测试重定向
print_message $BLUE "测试重定向功能..."
REDIRECT_RESPONSE=$(curl -s -I "http://localhost:$PORT/test/redirect.php")

if echo "$REDIRECT_RESPONSE" | grep -q "HTTP/1.1 302"; then
    LOCATION=$(echo "$REDIRECT_RESPONSE" | grep -i "location:" | tr -d '\r')
    print_message $GREEN "✅ 重定向响应正常"
    print_message $BLUE "重定向位置: $LOCATION"
    
    # 检查重定向URL是否包含错误的端口号
    if echo "$LOCATION" | grep -q ":80"; then
        print_message $RED "❌ 重定向URL包含内部端口号 :80"
        print_message $RED "这可能导致外部访问问题"
    else
        print_message $GREEN "✅ 重定向URL不包含内部端口号"
    fi
    
    # 测试跟随重定向
    FINAL_RESPONSE=$(curl -s -L "http://localhost:$PORT/test/redirect.php")
    if echo "$FINAL_RESPONSE" | grep -q "重定向测试成功"; then
        print_message $GREEN "✅ 重定向跟随成功"
    else
        print_message $RED "❌ 重定向跟随失败"
    fi
else
    print_message $RED "❌ 重定向测试失败"
fi

# 测试目录重定向 (trailing slash)
print_message $BLUE "测试目录重定向..."
mkdir -p src/testdir
echo "目录测试" > src/testdir/index.html

DIR_REDIRECT=$(curl -s -I "http://localhost:$PORT/testdir")
if echo "$DIR_REDIRECT" | grep -q "HTTP/1.1 301"; then
    LOCATION=$(echo "$DIR_REDIRECT" | grep -i "location:" | tr -d '\r')
    print_message $GREEN "✅ 目录重定向正常"
    print_message $BLUE "重定向位置: $LOCATION"
    
    if echo "$LOCATION" | grep -q ":80"; then
        print_message $RED "❌ 目录重定向包含内部端口号"
    else
        print_message $GREEN "✅ 目录重定向不包含内部端口号"
    fi
else
    print_message $YELLOW "⚠️ 目录重定向未触发 (可能已正确配置)"
fi

# 显示nginx配置相关信息
print_message $BLUE "检查nginx配置..."
docker exec $CONTAINER_NAME nginx -T 2>/dev/null | grep -E "(port_in_redirect|server_name_in_redirect)" || print_message $YELLOW "未找到重定向配置"

print_message $GREEN "🎉 重定向测试完成！"

# 清理测试文件
rm -rf src/test src/testdir
