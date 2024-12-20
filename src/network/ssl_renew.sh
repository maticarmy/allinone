#!/bin/bash

# SSL证书自动续签脚本
# 依赖: acme.sh

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置文件路径
CONFIG_FILE="$HOME/.ssl_renew_config"

# 检查acme.sh是否安装
check_acme() {
    if ! command -v acme.sh &> /dev/null; then
        echo -e "${RED}未检测到acme.sh，是否安装？(y/n)${NC}"
        read -r install_choice
        if [[ $install_choice == "y" ]]; then
            curl https://get.acme.sh | sh
            source "$HOME/.bashrc"
        else
            echo -e "${RED}请先安装acme.sh后再运行此脚本${NC}"
            exit 1
        fi
    fi
}

# 保存配置
save_config() {
    local domain=$1
    local email=$2
    local web_root=$3
    echo "DOMAIN=$domain" > "$CONFIG_FILE"
    echo "EMAIL=$email" >> "$CONFIG_FILE"
    echo "WEB_ROOT=$web_root" >> "$CONFIG_FILE"
}

# 加载配置
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        return 0
    fi
    return 1
}

# 主菜单
show_menu() {
    echo -e "${GREEN}=== SSL证书自动续签工具 ===${NC}"
    echo "1. 申请新证书"
    echo "2. 续签已有证书"
    echo "3. 查看证书状态"
    echo "4. 配置自动续签"
    echo "5. 退出"
    echo -n "请选择操作 (1-5): "
}

# 申请新证书
apply_new_cert() {
    echo -e "${YELLOW}请输入域名:${NC}"
    read -r domain
    echo -e "${YELLOW}请输入邮箱:${NC}"
    read -r email
    echo -e "${YELLOW}请输入网站根目录路径:${NC}"
    read -r web_root

    echo -e "${GREEN}正在申请证书...${NC}"
    acme.sh --issue -d "$domain" --webroot "$web_root" --email "$email"
    
    if [ $? -eq 0 ]; then
        save_config "$domain" "$email" "$web_root"
        echo -e "${GREEN}证书申请成功！${NC}"
    else
        echo -e "${RED}证书申请失败，请检查配置后重试${NC}"
    fi
}

# 续签证书
renew_cert() {
    if load_config; then
        echo -e "${GREEN}正在续签证书: $DOMAIN${NC}"
        acme.sh --renew -d "$DOMAIN"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}证书续签成功！${NC}"
        else
            echo -e "${RED}证书续签失败${NC}"
        fi
    else
        echo -e "${RED}未找到配置信息，请先申请证书${NC}"
    fi
}

# 查看证书状态
check_cert_status() {
    if load_config; then
        echo -e "${GREEN}证书信息 - 域名: $DOMAIN${NC}"
        acme.sh --list
    else
        echo -e "${RED}未找到配置信息${NC}"
    fi
}

# 配置自动续签
setup_auto_renew() {
    if ! load_config; then
        echo -e "${RED}请先申请证书${NC}"
        return
    fi

    echo "添加自动续签到crontab..."
    (crontab -l 2>/dev/null; echo "0 0 * * * acme.sh --cron --home \"$HOME/.acme.sh\"") | crontab -
    echo -e "${GREEN}自动续签配置完成！每天凌晨会检查并自动续签${NC}"
}

# 主程序
main() {
    check_acme
    while true; do
        show_menu
        read -r choice
        case $choice in
            1) apply_new_cert ;;
            2) renew_cert ;;
            3) check_cert_status ;;
            4) setup_auto_renew ;;
            5) echo -e "${GREEN}感谢使用！${NC}"; exit 0 ;;
            *) echo -e "${RED}无效选择${NC}" ;;
        esac
        echo
        echo -e "${YELLOW}按回车键继续...${NC}"
        read -r
        clear
    done
}

main 