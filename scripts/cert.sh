#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# 检查root权限
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}错误：请使用 root 用户运行此脚本${NC}"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    local deps=("curl" "socat" "openssl" "cron")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v $dep &>/dev/null; then
            missing+=($dep)
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${YELLOW}正在安装必要依赖: ${missing[*]}${NC}"
        if command -v apt &>/dev/null; then
            apt update
            apt install -y "${missing[@]}"
        elif command -v yum &>/dev/null; then
            yum install -y "${missing[@]}"
        fi
    fi
}

# 安装 acme.sh
install_acme() {
    if [ ! -f ~/.acme.sh/acme.sh ]; then
        echo -e "${YELLOW}正在安装 acme.sh...${NC}"
        curl https://get.acme.sh | sh -s email=$1
        source ~/.bashrc
        ~/.acme.sh/acme.sh --upgrade --auto-upgrade
        echo -e "${GREEN}acme.sh 安装完成${NC}"
    else
        echo -e "${GREEN}acme.sh 已安装${NC}"
    fi
}

# 申请证书
apply_cert() {
    local domain=$1
    local email=$2
    local web_root=$3
    
    echo -e "${YELLOW}正在申请证书 $domain...${NC}"
    
    # 检查域名解析
    local domain_ip=$(dig +short $domain)
    local server_ip=$(curl -s ipv4.icanhazip.com)
    
    if [ "$domain_ip" != "$server_ip" ]; then
        echo -e "${RED}警告: 域名 $domain 未解析到本服务器 IP ($server_ip)${NC}"
        read -p "是否继续？(y/n): " continue_apply
        if [ "$continue_apply" != "y" ]; then
            return 1
        fi
    fi
    
    # 申请证书
    ~/.acme.sh/acme.sh --issue -d $domain --webroot $web_root \
        --reloadcmd "systemctl reload nginx 2>/dev/null || systemctl reload httpd 2>/dev/null || true"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}证书申请成功！${NC}"
        # 安装证书
        local cert_dir="/etc/ssl/$domain"
        mkdir -p $cert_dir
        ~/.acme.sh/acme.sh --install-cert -d $domain \
            --key-file $cert_dir/private.key \
            --fullchain-file $cert_dir/fullchain.cer
        echo -e "${GREEN}证书已安装到 $cert_dir${NC}"
    else
        echo -e "${RED}证书申请失败${NC}"
        return 1
    fi
}

# 续签证书
renew_certs() {
    echo -e "${YELLOW}正在续签所有证书...${NC}"
    ~/.acme.sh/acme.sh --cron --home ~/.acme.sh/
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}证书续签完成${NC}"
    else
        echo -e "${RED}证书续签失败${NC}"
        return 1
    fi
}

# 查看证书
list_certs() {
    echo -e "${YELLOW}已安装的证书列表：${NC}"
    ~/.acme.sh/acme.sh --list
}

# 配置自动续签
setup_auto_renew() {
    if ! crontab -l | grep -q "acme.sh"; then
        echo -e "${YELLOW}配置自动续签...${NC}"
        (crontab -l 2>/dev/null; echo "0 0 * * * \"/root/.acme.sh\"/acme.sh --cron --home \"/root/.acme.sh\" > /dev/null") | crontab -
        echo -e "${GREEN}自动续签配置完成${NC}"
    else
        echo -e "${GREEN}自动续签已配置${NC}"
    fi
}

# 主菜单
show_menu() {
    echo -e "\n${GREEN}┌─────────── SSL证书管理 ───────────┐${NC}"
    echo -e "${WHITE}  1. 申请新证书"
    echo -e "  2. 续签证书"
    echo -e "  3. 查看证书"
    echo -e "  4. 配置自动续签"
    echo -e "  5. 返回主菜单"
    echo -e "${GREEN}└────────────────���───────────────┘${NC}"
}

# 主程序
main() {
    check_root
    check_dependencies
    
    while true; do
        show_menu
        echo -ne "\n${GREEN}[>]${WHITE} 请输入选项 (1-5): ${NC}"
        read choice
        
        case $choice in
            1)
                read -p "请输入域名: " domain
                read -p "请输入邮箱: " email
                read -p "请输入网站根目录: " web_root
                apply_cert "$domain" "$email" "$web_root"
                ;;
            2)
                renew_certs
                ;;
            3)
                list_certs
                ;;
            4)
                setup_auto_renew
                ;;
            5)
                return 0
                ;;
            *)
                echo -e "${RED}无效选择${NC}"
                ;;
        esac
        
        read -p "按回车键继续..."
    done
}

main "$@" 