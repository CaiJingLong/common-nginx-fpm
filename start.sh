#!/bin/bash

# Common Nginx + PHP-FPM Docker 快速启动脚本
# 使用方法: ./start.sh [dev|prod|stop|logs|status]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目名称
PROJECT_NAME="common-nginx-fpm"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

# 检查Docker和Docker Compose
check_requirements() {
    if ! command -v docker &> /dev/null; then
        print_message $RED "错误: Docker 未安装或未在PATH中"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_message $RED "错误: Docker Compose 未安装或未在PATH中"
        exit 1
    fi
}

# 创建必要的目录
create_directories() {
    print_message $BLUE "创建必要的目录..."
    mkdir -p src logs config/mysql config/postgres
    
    # 如果src目录为空，创建示例文件
    if [ ! -f "src/index.php" ]; then
        print_message $YELLOW "创建示例 index.php 文件..."
        # index.php 已经存在，这里不需要重复创建
    fi
}

# 设置环境变量
setup_env() {
    local env_type=$1
    
    if [ ! -f ".env" ]; then
        print_message $BLUE "复制环境变量文件..."
        cp .env.example .env
    fi
    
    case $env_type in
        "dev")
            print_message $BLUE "配置开发环境..."
            sed -i.bak 's/PROJECT_NAME=.*/PROJECT_NAME=dev-webapp/' .env
            sed -i.bak 's/WEB_PORT=.*/WEB_PORT=8000/' .env
            sed -i.bak 's/CODE_MOUNT_MODE=.*/CODE_MOUNT_MODE=rw/' .env
            sed -i.bak 's/READ_ONLY=.*/READ_ONLY=false/' .env
            sed -i.bak 's/MEMORY_LIMIT=.*/MEMORY_LIMIT=1G/' .env
            sed -i.bak 's/CPU_LIMIT=.*/CPU_LIMIT=2.0/' .env
            rm -f .env.bak
            ;;
        "prod")
            print_message $BLUE "配置生产环境..."
            sed -i.bak 's/PROJECT_NAME=.*/PROJECT_NAME=prod-webapp/' .env
            sed -i.bak 's/WEB_PORT=.*/WEB_PORT=80/' .env
            sed -i.bak 's/CODE_MOUNT_MODE=.*/CODE_MOUNT_MODE=ro/' .env
            sed -i.bak 's/READ_ONLY=.*/READ_ONLY=true/' .env
            sed -i.bak 's/MEMORY_LIMIT=.*/MEMORY_LIMIT=512M/' .env
            sed -i.bak 's/CPU_LIMIT=.*/CPU_LIMIT=1.0/' .env
            rm -f .env.bak
            
            print_message $YELLOW "请确保已设置强密码！"
            ;;
    esac
}

# 启动服务
start_services() {
    local env_type=$1
    
    print_message $BLUE "构建镜像..."
    docker-compose build
    
    case $env_type in
        "dev")
            print_message $GREEN "启动开发环境..."
            docker-compose up -d
            ;;
        "prod")
            print_message $GREEN "启动生产环境..."
            docker-compose up -d
            ;;
    esac
    
    # 等待服务启动
    print_message $BLUE "等待服务启动..."
    sleep 10
    
    # 健康检查
    local port=$(grep WEB_PORT .env | cut -d'=' -f2)
    if curl -s "http://localhost:${port}/health" > /dev/null; then
        print_message $GREEN "✅ 服务启动成功！"
        print_message $GREEN "🌐 访问地址: http://localhost:${port}"
        

    else
        print_message $RED "❌ 服务启动失败，请检查日志"
        docker-compose logs web
    fi
}

# 停止服务
stop_services() {
    print_message $YELLOW "停止所有服务..."
    docker-compose down
    print_message $GREEN "✅ 服务已停止"
}

# 查看日志
show_logs() {
    print_message $BLUE "显示服务日志..."
    docker-compose logs -f --tail=100
}

# 查看状态
show_status() {
    print_message $BLUE "服务状态:"
    docker-compose ps
    
    print_message $BLUE "资源使用:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}

# 显示帮助
show_help() {
    echo "Common Nginx + PHP-FPM Docker 快速启动脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 dev     - 启动开发环境 (端口8000)"
    echo "  $0 prod    - 启动生产环境 (端口80)"
    echo "  $0 stop    - 停止所有服务"
    echo "  $0 logs    - 查看服务日志"
    echo "  $0 status  - 查看服务状态"
    echo "  $0 help    - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 dev     # 启动开发环境"
    echo "  $0 prod    # 启动生产环境"
    echo "  $0 logs    # 查看日志"
}

# 主函数
main() {
    local command=${1:-help}
    
    case $command in
        "dev"|"prod")
            check_requirements
            create_directories
            setup_env $command
            start_services $command
            ;;
        "stop")
            stop_services
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@"
