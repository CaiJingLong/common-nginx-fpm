# 项目上下文信息

- 创建了nginx+php-fpm通用Docker镜像，提供Alpine和Debian两个版本。Alpine版本安全性更高(0漏洞 vs 152漏洞)，推荐生产环境使用。包含完整的配置文件、安全扫描报告和使用文档。
- 更新Dockerfile添加了完整的PHP扩展集合，包括bcmath、bz2、dom、exif、fileinfo、ftp、gd、gettext、iconv、mbstring、mysqli、opcache、pcntl、pdo系列、pgsql、posix、shmop、simplexml、soap、sockets、sqlite3、sysvsem、sysvshm、xml系列、xsl、zip、ldap、redis等扩展，满足用户的全面需求
- 为common-nginx-fpm项目创建了GitHub Action工作流，支持自动构建Docker镜像并推送到阿里云镜像仓库，使用GitHub Secrets管理认证信息，支持多种触发条件和自动标签管理
