# Common Nginx + PHP-FPM Docker Image

这是一个通用的 Nginx + PHP-FPM Docker 镜像，支持外部配置文件覆盖。

## 🔒 安全版本说明

提供两个版本供选择：

### Alpine版本 (推荐生产环境)
- **镜像标签**: `common-nginx-fpm-alpine`
- **基础镜像**: `php:8.4-fpm-alpine`
- **安全状态**: ✅ 0个高危漏洞
- **镜像大小**: ~754MB
- **推荐用途**: 生产环境、安全要求高的场景

### Debian版本 (开发环境可选)
- **镜像标签**: `common-nginx-fpm`
- **基础镜像**: `php:8.4-fpm`
- **安全状态**: ⚠️ 152个高危漏洞
- **镜像大小**: ~569MB
- **推荐用途**: 开发环境、需要glibc兼容性的场景

> 📋 详细安全对比请查看 [SECURITY_REPORT.md](SECURITY_REPORT.md)

## 特性

- 基于官方 PHP 8.4 FPM 镜像
- 集成 Nginx 作为 Web 服务器
- 支持 PHP 文件动态处理和静态资源服务
- 预装常用 PHP 扩展（PDO MySQL, PDO PostgreSQL, PostgreSQL, MySQLi, OPcache）
- 支持外部配置文件覆盖
- **端口重定向修复** - 支持任意端口映射 (如 `-p 8080:80`)
- 使用 Supervisor 管理进程
- 包含健康检查端点

## 快速开始

### 构建镜像

```bash
# 构建Alpine版本 (推荐)
docker build -t common-nginx-fpm-alpine .

# 构建Debian版本 (需要修改Dockerfile第一行)
# 将 FROM php:8.4-fpm-alpine 改为 FROM php:8.4-fpm
docker build -t common-nginx-fpm .
```

### 运行容器

```bash
# Alpine版本 - 基本运行
docker run -d -p 80:80 common-nginx-fpm-alpine

# Alpine版本 - 挂载代码目录
docker run -d -p 80:80 -v /path/to/your/code:/var/www/html common-nginx-fpm-alpine

# Alpine版本 - 安全运行 (推荐生产环境)
docker run -d -p 80:80 \
  --name web-app \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/run \
  --memory=512m \
  --cpus=1.0 \
  -v /path/to/your/code:/var/www/html:ro \
  -v /path/to/custom/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v /path/to/custom/php.ini:/usr/local/etc/php/conf.d/custom.ini:ro \
  common-nginx-fpm-alpine

# Debian版本 - 基本运行
docker run -d -p 80:80 common-nginx-fpm
```

## 配置覆盖

### Nginx 配置

- 默认配置：`/etc/nginx/nginx.conf`
- 自定义配置：挂载到 `/etc/nginx/nginx.conf` 或 `/etc/nginx/conf.d/default.conf`

### PHP 配置

- 默认配置：`/usr/local/etc/php/php.ini`
- 自定义配置：挂载到 `/usr/local/etc/php/conf.d/custom.ini`

### PHP-FPM 配置

- 默认配置：`/usr/local/etc/php-fpm.d/www.conf`
- 自定义配置：挂载到 `/usr/local/etc/php-fpm.d/custom.conf`

## 目录结构

```
/var/www/html/          # Web 根目录
/var/log/nginx/         # Nginx 日志
/var/log/php-fpm/       # PHP-FPM 日志
/var/lib/php/sessions/  # PHP 会话存储
```

## 端口

- `80`: HTTP 端口

## 健康检查

访问 `http://localhost/health` 进行健康检查。

## Docker Compose 使用

### 🚀 一键启动 (推荐)

使用提供的启动脚本，一键配置和启动环境：

```bash
# 启动开发环境 (端口8000)
./start.sh dev

# 启动生产环境 (端口80)
./start.sh prod

# 查看服务状态
./start.sh status

# 查看日志
./start.sh logs

# 停止服务
./start.sh stop
```

### 📋 手动配置

如果需要手动配置，请按以下步骤：

1. **复制环境变量文件**
   ```bash
   cp .env.example .env
   ```

2. **编辑配置** (根据需要修改 `.env` 文件)
   ```bash
   # 基础配置
   PROJECT_NAME=my-web-app
   WEB_PORT=80
   CODE_PATH=./src

   # 数据库配置
   MYSQL_PASSWORD=your_strong_password
   ```

3. **启动服务**
   ```bash
   # 启动服务
   docker-compose up -d

   # 查看日志
   docker-compose logs -f
   ```

### 环境配置

详细的环境变量配置请参考 `.env.example` 文件，主要包括：

- **项目配置**: 项目名称、时区设置
- **Web服务**: 端口、代码路径
- **性能配置**: 内存和CPU限制
- **自定义配置**: 可选的配置文件覆盖

## 环境变量

- `TZ`: 时区设置（默认：Asia/Shanghai）

## 安全注意事项

- 默认禁用了一些危险的 PHP 函数
- 设置了 open_basedir 限制
- 隐藏了敏感文件和目录
- 添加了安全响应头

## 日志

- Nginx 访问日志：`/var/log/nginx/access.log`
- Nginx 错误日志：`/var/log/nginx/error.log`
- PHP-FPM 错误日志：`/var/log/php-fpm/www-error.log`
- PHP-FPM 慢日志：`/var/log/php-fpm/slow.log`

## 使用示例

### 开发环境设置

```bash
# 1. 克隆或创建项目
mkdir my-web-project && cd my-web-project

# 2. 复制Docker配置
cp /path/to/common-nginx-fpm/* .

# 3. 设置环境变量
cp .env.example .env
# 编辑 .env 文件设置开发环境配置

# 4. 创建代码目录
mkdir -p src

# 5. 启动开发环境
docker-compose up -d web mysql redis

# 6. 访问应用
open http://localhost
```

### 生产环境部署

```bash
# 1. 设置生产环境变量
cat > .env << EOF
PROJECT_NAME=prod-webapp
WEB_PORT=80
CODE_MOUNT_MODE=ro
READ_ONLY=true
MEMORY_LIMIT=512M
CPU_LIMIT=1.0
MYSQL_PASSWORD=your_very_strong_password
EOF

# 2. 启动生产环境
docker-compose up -d

# 3. 验证部署
curl http://localhost/health
```

## 故障排除

### 常见问题

**1. 容器启动失败**
```bash
# 查看容器状态
docker-compose ps

# 查看启动日志
docker-compose logs web
```

**2. PHP文件不执行，显示源码**
```bash
# 检查nginx配置
docker exec <container> nginx -t

# 检查PHP-FPM状态
docker exec <container> php-fpm -t
```

**3. 端口重定向问题**
```bash
# 测试重定向功能
./tools/test-redirect.sh 8080

# 检查nginx重定向配置
docker exec <container> nginx -T | grep -E "(port_in_redirect|server_name_in_redirect)"
```

### 查看日志

```bash
# Docker Compose日志
docker-compose logs -f web
docker-compose logs -f mysql

# 容器内日志
docker exec <container> tail -f /var/log/nginx/error.log
docker exec <container> tail -f /var/log/php-fpm/www-error.log
```

### 配置测试

```bash
# 测试 Nginx 配置
docker exec <container> nginx -t

# 测试 PHP-FPM 配置
docker exec <container> php-fpm -t

# 测试 PHP 扩展
docker exec <container> php -m
```

### 性能调优

```bash
# 查看资源使用
docker stats

# 调整PHP-FPM进程数
# 编辑 config/www.conf
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
```
