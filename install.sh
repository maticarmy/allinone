#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# 版本信息
VERSION="1.0.0"

# 显示logo
show_logo() {
    clear
    echo -e "${GREEN}"
    echo "    ███╗   ███╗ █████╗ ████████╗██████╗ ██╗██╗  ██╗"
    echo "    ████╗ ████║██╔══██╗╚══██╔══╝██╔══██╗██║╚██╗██╔╝"
    echo "    ██╔████╔██║███████║   ██║   ██████╔╝██║ ╚███╔╝ "
    echo "    ██║╚██╔╝██║██╔══██║   ██║   ██╔══██╗██║ ██╔██╗ "
    echo "    ██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██║██╔╝ ██╗"
    echo "    ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${CYAN}┌──────────────── VPS 管理控制台 ────────────────┐"
    echo -e "│                   Ver $VERSION                     │"
    echo -e "└──────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${GREEN}[+]${WHITE} 系统初始化...${NC}"
    
    # 简单的加载进度条
    echo -ne "\n${GREEN}[${NC}"
    for i in {1..50}; do
        echo -ne "${GREEN}#${NC}"
        sleep 0.02
    done
    echo -e "${GREEN}]${NC}"
    sleep 0.5
}

# 主菜单
show_menu() {
    echo -e "\n${GREEN}┌─────────────── 系统控制面板 ───────────────┐${NC}"
    echo -e "${WHITE}  1. 系统初始化          2. SSL证书管理"
    echo -e "  3. 防火墙配置          4. 面板管理"
    echo -e "  5. 备份管理            6. 更新系统"
    echo -e "  7. 退出"
    echo -e "${GREEN}└──────────────────────────────────────┘${NC}"
}

# 子菜单样式
show_submenu() {
    local title=$1
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${GREEN} $title ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

# 操作提示样式
show_tips() {
    echo -e "\n${GREEN}[*]${WHITE} $1${NC}"
}

# 警告提示样式
show_warning() {
    echo -e "\n${RED}[!] 警告 ${NC}"
    echo -e "${RED}[!]${WHITE} $1${NC}"
}

# 进度条
show_progress() {
    local duration=$1
    local width=50
    local progress=0
    while [ $progress -le 100 ]; do
        local count=$(($width * $progress / 100))
        local spaces=$((width - count))
        printf "\r[${GREEN}"
        printf "%-${count}s" | tr ' ' '█'
        printf "${WHITE}"
        printf "%-${spaces}s" | tr ' ' '░'
        printf "${NC}] ${progress}%%"
        progress=$((progress + 2))
        sleep $duration
    done
    echo
}

# 初始化函数
init_scripts() {
    SCRIPT_DIR="/usr/local/allinone"
    mkdir -p $SCRIPT_DIR
    
    if [ ! -f "${SCRIPT_DIR}/.version" ] || [ "$(cat ${SCRIPT_DIR}/.version)" != "$VERSION" ]; then
        show_tips "正在下载脚本..."
        
        curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/init.sh -o ${SCRIPT_DIR}/init.sh
        curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/cert.sh -o ${SCRIPT_DIR}/cert.sh
        curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/firewall.sh -o ${SCRIPT_DIR}/firewall.sh
        curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/panel.sh -o ${SCRIPT_DIR}/panel.sh
        curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/backup.sh -o ${SCRIPT_DIR}/backup.sh
        
        chmod +x ${SCRIPT_DIR}/*.sh
        echo "$VERSION" > ${SCRIPT_DIR}/.version
        
        show_tips "脚本下载完成！"
    fi
}

# 主程序
main() {
    show_logo
    init_scripts
    
    while true; do
        show_menu
        echo -ne "\n${GREEN}[>]${WHITE} 请输入选项 (1-7): ${NC}"
        read choice
        
        case $choice in
            1) 
                show_tips "加载系统初始化模块..."
                show_progress 0.02
                bash ${SCRIPT_DIR}/init.sh
                ;;
            2) bash ${SCRIPT_DIR}/cert.sh ;;
            3) bash ${SCRIPT_DIR}/firewall.sh ;;
            4) bash ${SCRIPT_DIR}/panel.sh ;;
            5) bash ${SCRIPT_DIR}/backup.sh ;;
            6) 
                show_tips "检查更新..."
                init_scripts
                show_tips "更新完成！"
                ;;
            7) 
                echo -e "${GREEN}感谢使用！${NC}"
                exit 0 
                ;;
            *) echo -e "${RED}无效选择${NC}" ;;
        esac
    done
}

main "$@" 