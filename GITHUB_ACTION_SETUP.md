# GitHub Action 配置说明

## 概述

已为项目创建了 GitHub Action 工作流，用于自动构建 Docker 镜像并推送到阿里云容器镜像仓库。

## 配置文件

- **工作流文件**: `.github/workflows/docker-build-push.yml`
- **触发条件**: 
  - 推送到 `main` 分支
  - 创建 tag（以 `v` 开头）
  - Pull Request 到 `main` 分支
  - 手动触发

## 必需的 GitHub Secrets

在 GitHub 仓库的 Settings > Secrets and variables > Actions 中添加以下 Secrets：

### 必需配置
- `ALIYUN_REGISTRY` - 阿里云镜像仓库地址
  - 示例: `registry.cn-hangzhou.aliyuncs.com`
- `ALIYUN_USERNAME` - 阿里云镜像仓库用户名
- `ALIYUN_PASSWORD` - 阿里云镜像仓库密码

### 可选配置
- `IMAGE_NAME` - 镜像名称（可选）
  - 如果不设置，将使用 GitHub 仓库名称
  - 示例: `your-namespace/common-nginx-fpm`

## 镜像标签策略

工作流会自动生成以下标签：

### 分支推送
- `main` → `latest`, `alpine`
- 其他分支 → `branch-name`

### Tag 推送
- `v1.2.3` → `1.2.3`, `1.2`, `1`, `latest`, `alpine`
- `v2.0.0-beta.1` → `2.0.0-beta.1`

### Pull Request
- PR #123 → `pr-123`

## 功能特性

- ✅ 单架构构建 (linux/amd64)
- ✅ 构建缓存优化
- ✅ 自动标签管理
- ✅ 元数据标签
- ✅ 构建状态输出
- ✅ 支持手动触发

## 使用示例

### 1. 配置 Secrets

```bash
# 在 GitHub 仓库设置中添加以下 Secrets:
ALIYUN_REGISTRY=registry.cn-hangzhou.aliyuncs.com
ALIYUN_USERNAME=your-username
ALIYUN_PASSWORD=your-password
IMAGE_NAME=your-namespace/common-nginx-fpm  # 可选
```

### 2. 触发构建

```bash
# 方式1: 推送到 main 分支
git push origin main

# 方式2: 创建版本标签
git tag v1.0.0
git push origin v1.0.0

# 方式3: 在 GitHub 网页上手动触发
# Actions > Build and Push Docker Image to Aliyun Registry > Run workflow
```

### 3. 使用构建的镜像

```bash
# 拉取最新版本
docker pull registry.cn-hangzhou.aliyuncs.com/your-namespace/common-nginx-fpm:latest

# 拉取特定版本
docker pull registry.cn-hangzhou.aliyuncs.com/your-namespace/common-nginx-fpm:v1.0.0

# 运行容器
docker run -d -p 80:80 registry.cn-hangzhou.aliyuncs.com/your-namespace/common-nginx-fpm:latest
```

## 故障排除

### 1. 认证失败
- 检查 `ALIYUN_USERNAME` 和 `ALIYUN_PASSWORD` 是否正确
- 确认阿里云账号有推送权限

### 2. 镜像仓库不存在
- 在阿里云控制台创建对应的镜像仓库
- 确认 `ALIYUN_REGISTRY` 和 `IMAGE_NAME` 配置正确

### 3. 构建失败
- 查看 GitHub Actions 日志
- 检查 Dockerfile 语法
- 确认依赖包可用性

## 安全建议

1. **使用专用账号**: 为 CI/CD 创建专用的阿里云子账号
2. **最小权限**: 只授予必要的镜像推送权限
3. **定期轮换**: 定期更新密码和访问密钥
4. **监控日志**: 定期检查构建和推送日志

## 扩展功能

如需添加更多功能，可以考虑：

- 多架构构建 (linux/amd64, linux/arm64)
- 安全扫描集成
- 构建通知 (Slack, 钉钉等)
- 自动部署到测试环境
- 镜像签名验证
