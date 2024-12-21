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

# Matrix字符集
CHARS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%^&*()"

# 版本信息
VERSION="1.0.0"

# Matrix加载动画
show_matrix_loading() {
    clear
    local lines=$(tput lines)
    local cols=$(tput cols)
    local mid_line=$((lines/2))
    local mid_col=$((cols/2))
    
    # 显示加载文字
    echo -ne "\033[${mid_line};$((mid_col-10))H${GREEN}INITIALIZING...${NC}"
    
    # Matrix效果
    for i in {1..50}; do
        for j in {1..20}; do
            local line=$((RANDOM % lines))
            local col=$((RANDOM % cols))
            local char="${CHARS:$((RANDOM % ${#CHARS})):1}"
            echo -ne "\033[${line};${col}H${GREEN}${char}${NC}"
        done
        sleep 0.05
        
        # 更新加载进度
        if [ $i -lt 10 ]; then
            echo -ne "\033[${mid_line};$((mid_col-10))H${GREEN}INITIALIZING[${i}0%]${NC}"
        fi
    done
    
    # 清屏特效
    for i in $(seq 1 $lines); do
        echo -ne "\033[${i};1H${GREEN}"
        printf '%*s' "$cols" | tr ' ' '0'
        echo -ne "${NC}"
        sleep 0.02
    done
    
    # 显示系统信息
    clear
    echo -ne "\033[${mid_line};$((mid_col-15))H${GREEN}SYSTEM LOADING...${NC}"
    sleep 0.5
    echo -ne "\033[${mid_line};$((mid_col-15))H${GREEN}ACCESS GRANTED...${NC}"
    sleep 0.5
    
    # 最终清屏
    for i in $(seq 1 $lines); do
        echo -ne "\033[${i};1H${GREEN}"
        printf '%*s' "$cols" | tr ' ' ' '
        echo -ne "${NC}"
        sleep 0.01
    done
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
    echo "    ┌──────────── VPS 管理控制台 ────────────┐"
    echo "    │               Ver $VERSION                 │"
    echo "    └─────────────────────────────────────┘"
    echo -e "${NC}"
    echo -e "${GREEN}[+]${WHITE} 系统就绪...${NC}"
    echo -e "${GREEN}[+]${WHITE} 加载模块...${NC}"
    echo -e "${GREEN}[+]${WHITE} 初始化界面...${NC}"
    sleep 0.5
}

# 主菜单
show_menu() {
    echo -e "\n${GREEN}┌─────────────── 系统控制面板 ───────────────┐${NC}"
    echo -e "${WHITE}  1. 系统初始化          2. SSL证书管理"
    echo -e "  3. 防火墙配置          4. 面板管理"
    echo -e "  5. 备份管理            6. 更新系统"
    echo -e "  7. 退出"
    echo -e "${GREEN}└───────────────────────────────────────┘${NC}"
}

# 子菜单样式
show_submenu() {
    local title=$1
    echo -e "\n${BLUE}╔════════════════���═══════════════════════════════════════════╗${NC}"
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
    show_matrix_loading
    show_logo
    show_progress 0.01
    
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