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

# 安装宝塔面板
install_bt() {
    echo -e "${YELLOW}正在安装宝塔面板...${NC}"
    wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh
    echo y | bash install.sh
    rm -f install.sh
    echo -e "${GREEN}宝塔面板安装完成${NC}"
}

# 安装1Panel
install_1panel() {
    echo -e "${YELLOW}正在安装1Panel...${NC}"
    curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh
    bash quick_start.sh
    rm -f quick_start.sh
    echo -e "${GREEN}1Panel安装完成${NC}"
}

# 安装3x-ui
install_3xui() {
    echo -e "${YELLOW}正在安装3x-ui...${NC}"
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    echo -e "${GREEN}3x-ui安装完成${NC}"
}

# 主菜单
main() {
    check_root
    
    while true; do
        clear
        echo -e "${GREEN}=== 面板管理工具 ===${NC}"
        echo "1. 安装宝塔面板"
        echo "2. 安装1Panel"
        echo "3. 安装3x-ui"
        echo "4. 返回主菜单"
        
        read -p "请选择操作 (1-4): " choice
        
        case $choice in
            1) install_bt ;;
            2) install_1panel ;;
            3) install_3xui ;;
            4) return 0 ;;
            *) echo -e "${RED}无效选择${NC}" ;;
        esac
        
        read -p "按回车键继续..."
    done
}

main "$@" 