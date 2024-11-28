#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 配置文件路径
CLOUDFLARE_CREDS_DIR="/root/.secrets/certbot"
CLOUDFLARE_CREDS_FILE="${CLOUDFLARE_CREDS_DIR}/cloudflare.ini"

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}请使用root用户运行此脚本${NC}"
        exit 1
    fi
}

# 创建cloudflare凭证文件
create_cloudflare_credentials() {
    echo "请输入Cloudflare API Token:"
    read -r api_token
    
    mkdir -p "${CLOUDFLARE_CREDS_DIR}"
    cat > "${CLOUDFLARE_CREDS_FILE}" << EOF
# Cloudflare API token used by Certbot
dns_cloudflare_api_token = ${api_token}
EOF
    
    # 设置权限
    chmod 600 "${CLOUDFLARE_CREDS_FILE}"
}

# 安装certbot及其依赖
install_certbot() {
    echo -e "${GREEN}开始安装Certbot...${NC}"
    
    # 安装系统依赖
    apt update
    apt install -y python3 python3-venv libaugeas0
    
    # 删除旧版本
    apt remove -y certbot
    
    # 创建Python虚拟环境
    python3 -m venv /opt/certbot/
    /opt/certbot/bin/pip install --upgrade pip
    
    # 安装certbot和插件
    /opt/certbot/bin/pip install certbot certbot-nginx certbot-dns-cloudflare
    
    # 创建软链接
    ln -sf /opt/certbot/bin/certbot /usr/bin/certbot
    
    echo -e "${GREEN}Certbot安装完成${NC}"
}

# 生成证书
generate_certificate() {
    if [ ! -f "${CLOUDFLARE_CREDS_FILE}" ]; then
        echo -e "${RED}未找到Cloudflare凭证文件,请先创建${NC}"
        create_cloudflare_credentials
    fi
    
    echo "请输入需要申请证书的域名(多个域名用空格分隔):"
    read -r domains
    
    domain_args=""
    for domain in $domains; do
        domain_args="$domain_args -d $domain"
    done
    
    echo -e "${GREEN}开始申请证书...${NC}"
    certbot certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials "${CLOUDFLARE_CREDS_FILE}" \
        --dns-cloudflare-propagation-seconds 20 \
        $domain_args
        
    # 添加自动续期任务
    echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | tee -a /etc/crontab > /dev/null
}

# 显示使用帮助
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  install    安装Certbot及其插件"
    echo "  cert       申请SSL证书"
    echo "  auto       一键完成完整安装和证书申请流程"
    echo "  help       显示此帮助信息"
}

# 主程序
main() {
    check_root
    
    case "$1" in
        "install")
            install_certbot
            ;;
        "cert")
            generate_certificate
            ;;
        "auto")
            install_certbot
            generate_certificate
            ;;
        "help"|"")
            show_help
            ;;
        *)
            echo -e "${RED}无效的选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@" 