#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查root权限
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}错误：请使用 root 用户运行此脚本${NC}"
        exit 1
    fi
}

# 检测系统类型
check_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${RED}无法确定系统类型${NC}"
        exit 1
    fi
}

# 安装防火墙
install_firewall() {
    echo -e "${YELLOW}正在安装防火墙...${NC}"
    case $OS in
        ubuntu|debian)
            apt update -y
            apt install -y ufw
            ;;
        centos|rhel)
            yum install -y firewalld
            systemctl enable firewalld
            ;;
        *)
            echo -e "${RED}不支持的系统类型${NC}"
            exit 1
            ;;
    esac
}

# 配置基础规则
configure_basic_rules() {
    echo -e "${YELLOW}配置基础防火墙规则...${NC}"
    case $OS in
        ubuntu|debian)
            ufw default deny incoming
            ufw default allow outgoing
            ufw allow ssh
            ufw allow 80/tcp
            ufw allow 443/tcp
            echo "y" | ufw enable
            ;;
        centos|rhel)
            systemctl start firewalld
            firewall-cmd --zone=public --add-service=ssh --permanent
            firewall-cmd --zone=public --add-service=http --permanent
            firewall-cmd --zone=public --add-service=https --permanent
            firewall-cmd --reload
            ;;
    esac
    echo -e "${GREEN}基础规则配置完成${NC}"
}

# 添加自定义端口
add_custom_port() {
    echo -e "\n${YELLOW}添加自定义端口${NC}"
    read -p "请输入端口号: " port
    read -p "请选择协议 (tcp/udp/both): " proto
    
    case $OS in
        ubuntu|debian)
            case $proto in
                tcp) ufw allow $port/tcp ;;
                udp) ufw allow $port/udp ;;
                both) ufw allow $port ;;
                *) echo -e "${RED}无效的协议${NC}"; return 1 ;;
            esac
            ;;
        centos|rhel)
            case $proto in
                tcp) firewall-cmd --zone=public --add-port=$port/tcp --permanent ;;
                udp) firewall-cmd --zone=public --add-port=$port/udp --permanent ;;
                both)
                    firewall-cmd --zone=public --add-port=$port/tcp --permanent
                    firewall-cmd --zone=public --add-port=$port/udp --permanent
                    ;;
                *) echo -e "${RED}无效的协议${NC}"; return 1 ;;
            esac
            firewall-cmd --reload
            ;;
    esac
    echo -e "${GREEN}端口添加成功${NC}"
}

# 显示防火墙状态
show_status() {
    echo -e "\n${YELLOW}防火墙状态：${NC}"
    case $OS in
        ubuntu|debian)
            ufw status numbered
            ;;
        centos|rhel)
            firewall-cmd --list-all
            ;;
    esac
}

# 主菜单
main() {
    check_root
    check_system
    
    while true; do
        clear
        echo -e "${GREEN}=== 防火墙配置工具 ===${NC}"
        echo "1. 安装并配置防火墙"
        echo "2. 添加自定义端口"
        echo "3. 查看防火墙状态"
        echo "4. 返回主菜单"
        
        read -p "请选择操作 (1-4): " choice
        
        case $choice in
            1)
                install_firewall
                configure_basic_rules
                ;;
            2)
                add_custom_port
                ;;
            3)
                show_status
                ;;
            4)
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