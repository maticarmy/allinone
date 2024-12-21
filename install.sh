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

# Matrix效果
show_matrix() {
    clear
    for i in {1..10}; do
        echo -ne "\033[$((RANDOM % 40 + 1));$((RANDOM % 80 + 1))H\033[32m$((RANDOM % 2))"
    done
    sleep 0.1
}

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
    echo -e "${CYAN}"
    echo "    ╔══════════════════════════════════════════════╗"
    echo "    ║             VPS MASTER CONTROL              ║"
    echo "    ║                Ver $VERSION                    ║"
    echo "    ╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}[+]${WHITE} System Ready...${NC}"
    echo -e "${GREEN}[+]${WHITE} Loading Modules...${NC}"
    echo -e "${GREEN}[+]${WHITE} Initialize Interface...${NC}"
    sleep 0.5
}

# 主菜单
show_menu() {
    echo -e "\n${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${GREEN}                     SYSTEM CONTROL PANEL                      ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  [1] System Initialize          [2] SSL Certificate Manager   ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [3] Firewall Configuration    [4] Panel Management          ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [5] Backup Management         [6] Update System             ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}  [7] Exit                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
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
    echo -e "\n${GREEN}[*] ${WHITE}$1${NC}"
}

# 警告提示样式
show_warning() {
    echo -e "\n${RED}[!] WARNING ${WHITE}════════════════════════════════════════════${NC}"
    echo -e "${RED}[!]${WHITE} $1${NC}"
    echo -e "${RED}[!]${WHITE} ════════════════════════════════════════════════════${NC}"
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

# 主程序
main() {
    for i in {1..3}; do
        show_matrix
    done
    show_logo
    show_progress 0.01
    
    while true; do
        show_menu
        echo -ne "\n${GREEN}[>]${WHITE} Enter your choice (1-7): ${NC}"
        read choice
        
        case $choice in
            1) 
                show_tips "Loading System Initialize Module..."
                show_progress 0.02
                bash <(curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/scripts/init.sh) 
                ;;
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