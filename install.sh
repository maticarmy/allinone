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
    echo -e "${CYAN}┌─────────── VPS 管理控制台 ───────────┐"
    echo -e "│              Ver $VERSION                │"
    echo -e "└────────────────────────────────────┘${NC}"
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
    echo -e "\n${GREEN}┌─────────── 系统控制面板 ───────────┐${NC}"
    echo -e "${WHITE}  1. 系统初始化          2. SSL证书管理"
    echo -e "  3. 防火墙配置          4. 面板管理"
    echo -e "  5. 备份管理            6. 更新系统"
    echo -e "  7. 退出"
    echo -e "${GREEN}└────────────────────────────────────┘${NC}"
}

# 子菜单样式
show_submenu() {
    local title=$1
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════��══════╗${NC}"
    echo -e "${BLUE}║${GREEN} $title ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
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
        
        # 定义脚本仓库地址
        REPO_URL="https://raw.githubusercontent.com/maticarmy/allinone/master"
        LOCAL_REPO="./scripts"  # 本地脚本目录
        
        # 定义要下载的脚本
        declare -A scripts=(
            ["init.sh"]="系统初始化模块"
            ["cert.sh"]="SSL证书管理模块"
            ["firewall.sh"]="防火墙配置模块"
            ["panel.sh"]="面板管理模块"
            ["backup.sh"]="备份管理模块"
        )
        
        # 下载或复制脚本
        for script in "${!scripts[@]}"; do
            show_tips "准备${scripts[$script]}..."
            
            # 优先使用本地文件
            if [ -f "${LOCAL_REPO}/${script}" ]; then
                cp "${LOCAL_REPO}/${script}" "${SCRIPT_DIR}/${script}"
                chmod +x "${SCRIPT_DIR}/${script}"
                echo -e "${GREEN}✓${NC} ${scripts[$script]}准备完成(本地)"
            else
                # 尝试从远程下载
                if curl -fsSL "$REPO_URL/scripts/$script" -o "${SCRIPT_DIR}/$script"; then
                    chmod +x "${SCRIPT_DIR}/$script"
                    echo -e "${GREEN}✓${NC} ${scripts[$script]}准备完成(远程)"
                else
                    show_warning "${scripts[$script]}获取失败"
                    return 1
                fi
            fi
        done
        
        echo "$VERSION" > ${SCRIPT_DIR}/.version
        show_tips "所有模块准备就绪！"
    fi
}

# 运行模块函数
run_module() {
    local module=$1
    local module_path="${SCRIPT_DIR}/${module}"
    
    if [ -x "$module_path" ]; then
        # 如果本地文件存在且可执行
        "$module_path"
    else
        show_warning "模块 $module 不存在或无执行权限"
        return 1
    fi
}

# 主程序
main() {
    show_logo
    if ! init_scripts; then
        show_warning "初始化失败，请检查网络连接后重试"
        exit 1
    fi
    
    while true; do
        show_menu
        echo -ne "\n${GREEN}[>]${WHITE} 请输入选项 (1-7): ${NC}"
        read choice
        
        case $choice in
            1) 
                show_tips "加载系统初始化模块..."
                show_progress 0.02
                run_module "init.sh"
                ;;
            2) run_module "cert.sh" ;;
            3) run_module "firewall.sh" ;;
            4) run_module "panel.sh" ;;
            5) run_module "backup.sh" ;;
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