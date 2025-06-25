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

## Docker Compose 示例

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
      - ./config/custom-nginx.conf:/etc/nginx/nginx.conf
      - ./config/custom-php.ini:/usr/local/etc/php/conf.d/custom.ini
    environment:
      - TZ=Asia/Shanghai
```

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

## 故障排除

### 查看日志

```bash
# 查看容器日志
docker logs <container_id>

# 进入容器查看详细日志
docker exec -it <container_id> bash
tail -f /var/log/nginx/error.log
tail -f /var/log/php-fpm/www-error.log
```

### 测试配置

```bash
# 测试 Nginx 配置
docker exec <container_id> nginx -t

# 测试 PHP-FPM 配置
docker exec <container_id> php-fpm -t
```
