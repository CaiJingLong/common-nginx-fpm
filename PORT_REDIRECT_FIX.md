# 端口重定向问题修复说明

## 问题描述

当Docker容器映射到非80端口时（例如 `docker run -p 8080:80`），nginx的重定向可能会出现端口号问题：

- **问题场景**: 容器内nginx监听80端口，但外部通过8080端口访问
- **错误行为**: nginx重定向时可能包含内部端口号（:80），导致外部访问失败
- **影响范围**: PHP重定向、目录trailing slash重定向、HTTPS重定向等

## 解决方案

### 1. nginx配置修复

在 `config/nginx.conf` 中添加了以下配置：

```nginx
# 重定向设置 - 解决端口映射问题
port_in_redirect off;
server_name_in_redirect off;

# 支持反向代理头 (用于负载均衡器/反向代理场景)
real_ip_header X-Forwarded-For;
set_real_ip_from 0.0.0.0/0;
```

### 2. 配置说明

- **`port_in_redirect off`**: 重定向时不包含端口号
- **`server_name_in_redirect off`**: 重定向时不包含服务器名
- **`real_ip_header`**: 支持反向代理场景下的真实IP获取
- **`set_real_ip_from`**: 信任所有来源的代理头（可根据需要限制）

## 测试验证

### 自动化测试

提供了自动化测试脚本 `tools/test-redirect.sh`：

```bash
# 测试8080端口的重定向功能
./tools/test-redirect.sh 8080

# 测试其他端口
./tools/test-redirect.sh 3000
```

### 测试内容

1. **健康检查测试**: 验证服务正常启动
2. **基本访问测试**: 验证PHP处理正常
3. **PHP重定向测试**: 验证PHP header重定向不包含错误端口
4. **目录重定向测试**: 验证nginx目录重定向正常
5. **配置验证**: 确认nginx配置生效

### 测试结果示例

```
✅ 健康检查通过
✅ 基本访问正常
✅ 重定向响应正常
✅ 重定向URL不包含内部端口号
✅ 重定向跟随成功
✅ 目录重定向正常
✅ 目录重定向不包含内部端口号
```

## 使用场景

### 1. 开发环境

```bash
# 使用非标准端口避免冲突
docker run -p 8080:80 common-nginx-fpm-alpine
```

### 2. 多实例部署

```bash
# 同时运行多个实例
docker run -p 8001:80 --name app1 common-nginx-fpm-alpine
docker run -p 8002:80 --name app2 common-nginx-fpm-alpine
docker run -p 8003:80 --name app3 common-nginx-fpm-alpine
```

### 3. 反向代理场景

```nginx
# 前端nginx配置
upstream backend {
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 兼容性说明

### 支持的场景

- ✅ 直接端口映射 (`-p 8080:80`)
- ✅ 反向代理部署
- ✅ 负载均衡器后端
- ✅ Docker Compose端口映射
- ✅ Kubernetes Service

### 注意事项

1. **HTTPS重定向**: 如需HTTPS重定向，需要额外配置SSL相关设置
2. **域名绑定**: 如使用特定域名，建议设置 `server_name`
3. **安全考虑**: 生产环境可限制 `set_real_ip_from` 的范围

## 最佳实践

### 1. 开发环境配置

```yaml
# docker-compose.yml
services:
  web:
    image: common-nginx-fpm-alpine
    ports:
      - "8080:80"  # 使用非80端口避免冲突
```

### 2. 生产环境配置

```yaml
# docker-compose.yml
services:
  web:
    image: common-nginx-fpm-alpine
    ports:
      - "80:80"    # 生产环境使用标准端口
    # 或通过反向代理访问，不暴露端口
```

### 3. 健康检查配置

```yaml
healthcheck:
  test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## 故障排除

### 1. 重定向仍包含端口号

检查nginx配置是否生效：

```bash
docker exec <container> nginx -T | grep -E "(port_in_redirect|server_name_in_redirect)"
```

### 2. 反向代理场景问题

确保代理服务器正确设置头信息：

```nginx
proxy_set_header X-Forwarded-For $remote_addr;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header Host $host;
```

### 3. 测试重定向

手动测试重定向：

```bash
# 测试PHP重定向
curl -I http://localhost:8080/your-redirect-script.php

# 测试目录重定向
curl -I http://localhost:8080/some-directory
```

## 总结

通过添加 `port_in_redirect off` 和 `server_name_in_redirect off` 配置，完全解决了Docker端口映射场景下的nginx重定向问题。这个修复确保了：

1. **端口透明**: 重定向不会暴露内部端口号
2. **场景兼容**: 支持各种部署场景
3. **向后兼容**: 不影响现有功能
4. **测试覆盖**: 提供自动化测试验证

现在无论使用什么端口映射，nginx重定向都能正常工作！
