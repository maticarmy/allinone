#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}错误：请使用 root 用户运行此脚本${NC}"
        exit 1
    fi
}

# 初始化防火墙
init_firewall() {
    echo -e "${YELLOW}正在初始化防火墙...${NC}"
    
    # 安装 UFW
    if ! command -v ufw &> /dev/null; then
        echo -e "${YELLOW}正在安装 UFW...${NC}"
        apt update &>/dev/null
        apt install ufw -y &>/dev/null
    fi
    
    # 配置基础规则
    ufw default deny incoming
    ufw default allow outgoing
    
    # 允许 SSH
    ufw allow ssh
    
    # 允许 HTTP/HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # 启用防火墙
    echo "y" | ufw enable
    
    echo -e "${GREEN}防火墙初始化完成${NC}"
}

# 检查防火墙端口
check_firewall() {
    echo -e "${YELLOW}检查防火墙配置...${NC}"
    
    # 检查 UFW 状态
    if command -v ufw &> /dev/null; then
        if ! ufw status | grep -q "80/tcp.*ALLOW"; then
            echo -e "${YELLOW}正在开放 80 端口...${NC}"
            ufw allow 80/tcp
        fi
        if ! ufw status | grep -q "443/tcp.*ALLOW"; then
            echo -e "${YELLOW}正在开放 443 端口...${NC}"
            ufw allow 443/tcp
        fi
    else
        echo -e "${YELLOW}未检测到 UFW，正在安装...${NC}"
        init_firewall
    fi
    
    echo -e "${GREEN}防火墙配置检查完成${NC}"
}

# 配置自定义端口
configure_custom_ports() {
    while true; do
        echo -e "\n${YELLOW}是否需要开放其他端口？(y/n)${NC}"
        read -r answer
        case $answer in
            [Yy]*)
                echo -e "请输入要开放的端口号（例如：3306）："
                read -r port
                echo -e "请选择协议类型："
                echo "1) TCP"
                echo "2) UDP"
                echo "3) TCP+UDP"
                read -r proto
                case $proto in
                    1) ufw allow "$port"/tcp
                       echo -e "${GREEN}已开放 TCP 端口 $port${NC}" ;;
                    2) ufw allow "$port"/udp
                       echo -e "${GREEN}已开放 UDP 端口 $port${NC}" ;;
                    3) ufw allow "$port"
                       echo -e "${GREEN}已开放 TCP/UDP 端口 $port${NC}" ;;
                    *) echo -e "${RED}无效的选择${NC}" ;;
                esac
                ;;
            [Nn]*) break ;;
            *) echo -e "${RED}请输入 y 或 n${NC}" ;;
        esac
    done
}

# 显示防火墙状态
show_firewall_status() {
    echo -e "\n${YELLOW}当前防火墙状态：${NC}"
    ufw status numbered
}

# 检查是否安装了宝塔面板
if [ -f "/etc/init.d/bt" ]; then
    BT_PANEL=true
    echo -e "${GREEN}检测到宝塔面板环境${NC}"
else
    BT_PANEL=false
fi

# 申请新证书函数
apply_cert() {
    local domain=$1
    local email=$2
    local web_root=$3
    
    # 检查防火墙
    check_firewall
    
    if [ "$BT_PANEL" = true ]; then
        # 使用宝塔命令申请证书
        echo -e "${YELLOW}使用宝塔面板申请证书...${NC}"
        bt ssl $domain
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}证书申请成功！${NC}"
        else
            echo -e "${RED}证书申请失败，请检查配置后重试${NC}"
        fi
    else
        # 原来的 acme.sh 方式
        if ! command -v acme.sh &> /dev/null; then
            echo -e "${YELLOW}正在安装 acme.sh...${NC}"
            curl https://get.acme.sh | sh -s email=$email
            source ~/.bashrc
        fi
        
        echo -e "${YELLOW}正在申请证书...${NC}"
        acme.sh --issue -d $domain -w $web_root
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}证书申请成功！${NC}"
        else
            echo -e "${RED}证书申请失败，请检查配置后重试${NC}"
        fi
    fi
}

# 主菜单
while true; do
    clear
    echo -e "${GREEN}=== SSL证书自动续签工具 ===${NC}"
    echo "1. 申请新证书"
    echo "2. 续签已有证书"
    echo "3. 查看证书状态"
    echo "4. 配置自动续签"
    echo "5. 配置防火墙"
    echo "6. 查看防火墙状态"
    echo "7. 退出"
    
    read -p "请选择操作 (1-7): " choice
    
    case $choice in
        1)
            read -p "请输入域名: " domain
            read -p "请输入邮箱: " email
            if [ "$BT_PANEL" = false ]; then
                read -p "请输入网站根目录路径: " web_root
            else
                web_root=""
            fi
            apply_cert "$domain" "$email" "$web_root"
            ;;
        2)
            if [ "$BT_PANEL" = true ]; then
                echo -e "${YELLOW}使用宝塔面板续签证书...${NC}"
                bt ssl -r
            else
                echo -e "${YELLOW}使用 acme.sh 续签证书...${NC}"
                acme.sh --renew-all
            fi
            ;;
        3)
            if [ "$BT_PANEL" = true ]; then
                echo -e "${YELLOW}查看宝塔面板证书状态...${NC}"
                bt ssl
            else
                echo -e "${YELLOW}查看证书状态...${NC}"
                acme.sh --list
            fi
            ;;
        4)
            if [ "$BT_PANEL" = true ]; then
                echo -e "${GREEN}宝塔面板已自动配置证书续签${NC}"
            else
                echo -e "${YELLOW}配置 acme.sh 自动续签...${NC}"
                (crontab -l 2>/dev/null; echo "0 0 * * * /root/.acme.sh/acme.sh --cron --home /root/.acme.sh") | crontab -
                echo -e "${GREEN}自动续签配置完成${NC}"
            fi
            ;;
        5)
            check_firewall
            configure_custom_ports
            ;;
        6)
            show_firewall_status
            ;;
        7)
            echo -e "${GREEN}退出程序${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            ;;
    esac
    
    read -p "按回车键继续..."
done 