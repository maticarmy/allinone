#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本信息
VERSION="1.0.0"

# 显示logo
show_logo() {
    clear
    echo -e "${GREEN}"
    echo "    _    _ _ ___ _   _  ___  _   _ _____"
    echo "   / \  | | |_ _| \ | |/ _ \| \ | | ____|"
    echo "  / _ \ | | || ||  \| | | | |  \| |  _|  "
    echo " / ___ \| | || || |\  | |_| | |\  | |___ "
    echo "/_/   \_\_|_|___|_| \_|\___/|_| \_|_____|"
    echo -e "${NC}"
    echo -e "${YELLOW}VPS一键配置工具 v${VERSION}${NC}"
    echo -e "${YELLOW}作者: maticarmy${NC}\n"
}

# 主菜单
show_menu() {
    echo -e "\n${GREEN}=== 主菜单 ===${NC}"
    echo "1. 系统初始化"
    echo "2. SSL证书管理"
    echo "3. 防火墙配置"
    echo "4. 面板管理"
    echo "5. 备份管理"
    echo "6. 更新脚本"
    echo "7. 退出"
}

# 检查更新
check_update() {
    echo -e "${YELLOW}正在检查更新...${NC}"
    # TODO: 实现更新检查逻辑
}

# 主程序
main() {
    show_logo
    
    while true; do
        show_menu
        read -p "请选择操作 (1-7): " choice
        
        case $choice in
            1) bash <(curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/init.sh) ;;
            2) bash <(curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/cert.sh) ;;
            3) bash <(curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/firewall.sh) ;;
            4) bash <(curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/panel.sh) ;;
            5) bash <(curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/backup.sh) ;;
            6) check_update ;;
            7) 
                echo -e "${GREEN}感谢使用！${NC}"
                exit 0 
                ;;
            *) echo -e "${RED}无效选择${NC}" ;;
        esac
    done
}

main "$@" 