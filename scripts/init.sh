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

# 系统更新
system_update() {
    echo -e "${YELLOW}正在更新系统...${NC}"
    case $OS in
        ubuntu|debian)
            apt update -y
            apt upgrade -y
            apt autoremove -y
            apt clean
            ;;
        centos|rhel)
            yum update -y
            yum clean all
            ;;
    esac
    echo -e "${GREEN}系统更新完成${NC}"
}

# 安装基础工具
install_basic_tools() {
    echo -e "${YELLOW}正在安装基础工具...${NC}"
    case $OS in
        ubuntu|debian)
            apt install -y wget curl git vim unzip htop net-tools screen lsof
            ;;
        centos|rhel)
            yum install -y wget curl git vim unzip htop net-tools screen lsof
            ;;
    esac
    echo -e "${GREEN}基础工具安装完成${NC}"
}

# 配置SSH安全
secure_ssh() {
    echo -e "${YELLOW}配置SSH安全...${NC}"
    
    # 备份SSH配置
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    
    # 修改SSH配置
    sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    # 重启SSH服务
    systemctl restart sshd
    
    echo -e "${GREEN}SSH安全配置完成${NC}"
}

# 系统优化
system_optimize() {
    echo -e "${YELLOW}正在优化系统配置...${NC}"
    
    # 调整系统限制
    cat > /etc/security/limits.conf << EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF

    # 优化内核参数
    cat > /etc/sysctl.d/99-sysctl.conf << EOF
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.somaxconn = 65535
net.ipv4.tcp_congestion_control = bbr
EOF

    sysctl -p /etc/sysctl.d/99-sysctl.conf
    
    echo -e "${GREEN}系统优化完成${NC}"
}

# 配置时区
set_timezone() {
    echo -e "${YELLOW}配置系统时区...${NC}"
    timedatectl set-timezone Asia/Shanghai
    echo -e "${GREEN}时区配置完成${NC}"
}

# 配置BBR
enable_bbr() {
    echo -e "${YELLOW}正在启用BBR...${NC}"
    
    if ! grep -q "tcp_bbr" /etc/modules-load.d/modules.conf; then
        echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
    fi
    
    if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    fi
    
    sysctl -p
    
    echo -e "${GREEN}BBR 配置完成${NC}"
}

# 重置服务器
reset_server() {
    echo -e "${RED}警告：此操作将删除所有数据并重置服务器！${NC}"
    echo -e "${RED}此操作不可恢复！${NC}"
    echo -e "${YELLOW}请输入 'RESET' 确认操作：${NC}"
    read -p "> " confirm
    
    if [ "$confirm" != "RESET" ]; then
        echo -e "${GREEN}操作已取消${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}开始重置服务器...${NC}"
    
    # 停止常见服务
    echo -e "${YELLOW}停止服务...${NC}"
    systemctl stop nginx 2>/dev/null
    systemctl stop apache2 2>/dev/null
    systemctl stop httpd 2>/dev/null
    systemctl stop mysql 2>/dev/null
    systemctl stop mariadb 2>/dev/null
    systemctl stop docker 2>/dev/null
    
    # 卸载面板
    echo -e "${YELLOW}卸载面板...${NC}"
    if [ -f /etc/init.d/bt ]; then
        /etc/init.d/bt stop
        chkconfig --del bt
        rm -f /etc/init.d/bt
        rm -rf /www/server/panel
    fi
    
    # 清理数据目录
    echo -e "${YELLOW}清理数据...${NC}"
    rm -rf /www/* 2>/dev/null
    rm -rf /www/.* 2>/dev/null
    rm -rf /root/.acme.sh 2>/dev/null
    rm -rf /root/.ssh/known_hosts 2>/dev/null
    
    # 清理数据库
    echo -e "${YELLOW}清理数据库...${NC}"
    if command -v mysql >/dev/null 2>&1; then
        service mysql stop 2>/dev/null
        apt-get remove --purge mysql* -y 2>/dev/null
        apt-get remove --purge mariadb* -y 2>/dev/null
        rm -rf /var/lib/mysql
        rm -rf /etc/mysql
    fi
    
    # 清理面板相关
    echo -e "${YELLOW}清理面板...${NC}"
    rm -rf /www/server
    rm -rf /www/wwwroot
    rm -rf /etc/nginx
    rm -rf /etc/apache2
    rm -rf /etc/httpd
    
    # 清理系统日志
    echo -e "${YELLOW}清理日志...${NC}"
    rm -rf /var/log/*
    
    # 清理包管理器缓存
    echo -e "${YELLOW}清理系统缓存...${NC}"
    case $OS in
        ubuntu|debian)
            apt clean
            apt autoremove -y
            ;;
        centos|rhel)
            yum clean all
            ;;
    esac
    
    # 清理用户目录
    echo -e "${YELLOW}清理用户数据...${NC}"
    rm -rf /root/.cache
    rm -rf /root/.config
    rm -rf /root/.local
    
    # 重置防火墙
    echo -e "${YELLOW}重置防火墙...${NC}"
    if command -v ufw >/dev/null 2>&1; then
        ufw reset
        ufw enable
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
    fi
    
    # 清理定时任务
    echo -e "${YELLOW}清理定时任务...${NC}"
    crontab -r
    
    echo -e "${GREEN}服务器重置完成！${NC}"
    echo -e "${YELLOW}建议重启服务器以应用所有更改。${NC}"
    read -p "是否现在重启服务器？(y/n): " reboot_now
    if [ "$reboot_now" = "y" ]; then
        reboot
    fi
}

# DD重装系统
dd_system() {
    echo -e "${RED}警告：此操作将重装系统！所有数据将丢失！${NC}"
    echo -e "${RED}请确保您有可用的 SSH 密钥登录方式！${NC}"
    echo -e "${YELLOW}请输入 'DD' 确认操作：${NC}"
    read -p "> " confirm
    
    if [ "$confirm" != "DD" ]; then
        echo -e "${GREEN}操作已取消${NC}"
        return 1
    fi
    
    # 选择系统
    echo -e "\n${GREEN}可用的系统：${NC}"
    echo "1. Debian 11"
    echo "2. Debian 12"
    echo "3. Ubuntu 20.04"
    echo "4. Ubuntu 22.04"
    echo "5. CentOS 7"
    echo "6. 自定义镜像"
    
    read -p "请选择要安装的系统 (1-6): " os_choice
    
    # 设置变量
    case $os_choice in
        1)
            SYSTEM_NAME="Debian 11"
            DD_URL="https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh"
            DD_ARGS="-d 11 -v 64 -a"
            ;;
        2)
            SYSTEM_NAME="Debian 12"
            DD_URL="https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh"
            DD_ARGS="-d 12 -v 64 -a --mirror 'https://deb.debian.org/debian/'"
            ;;
        3)
            SYSTEM_NAME="Ubuntu 20.04"
            DD_URL="https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh"
            DD_ARGS="-u 20.04 -v 64 -a --mirror 'https://mirrors.ustc.edu.cn/ubuntu/'"
            ;;
        4)
            SYSTEM_NAME="Ubuntu 22.04"
            DD_URL="https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh"
            DD_ARGS="-u 22.04 -v 64 -a --mirror 'https://mirrors.ustc.edu.cn/ubuntu/'"
            ;;
        5)
            SYSTEM_NAME="CentOS 7"
            DD_URL="https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh"
            DD_ARGS="-c 7 -v 64 -a --mirror 'https://mirrors.aliyun.com/centos/'"
            ;;
        6)
            echo -e "${YELLOW}请输入自定义镜像URL：${NC}"
            read -p "> " CUSTOM_URL
            SYSTEM_NAME="自定义系统"
            DD_URL=$CUSTOM_URL
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            return 1
            ;;
    esac
    
    # 设置密码
    echo -e "\n${YELLOW}请设置root密码（不输入将使用随机密码）：${NC}"
    read -s -p "Password: " ROOT_PASS
    echo
    
    if [ -z "$ROOT_PASS" ]; then
        ROOT_PASS=$(tr -dc 'A-Za-z0-9!@#$%^&*()' </dev/urandom | head -c 16)
        echo -e "${GREEN}已生成随机密码：${ROOT_PASS}${NC}"
    fi
    
    # 确认信息
    echo -e "\n${YELLOW}请确认以下信息：${NC}"
    echo -e "系统：${GREEN}${SYSTEM_NAME}${NC}"
    echo -e "密码：${GREEN}${ROOT_PASS}${NC}"
    echo -e "\n${RED}最后警告：此操作将删除所有数据！${NC}"
    read -p "确认继续？(y/n): " final_confirm
    
    if [ "$final_confirm" != "y" ]; then
        echo -e "${GREEN}操作已取消${NC}"
        return 1
    fi
    
    # 开始安装
    echo -e "${YELLOW}开始安装系统...${NC}"
    echo -e "${RED}请不要关闭SSH连接！${NC}"
    
    # 下载安装脚本
    wget --no-check-certificate -qO InstallNET.sh ${DD_URL}
    chmod +x InstallNET.sh
    
    # 备份当前 SSH 配置
    cp /etc/ssh/sshd_config /root/sshd_config.bak
    
    # 执行安装
    if [ "$os_choice" = "6" ]; then
        bash InstallNET.sh $DD_URL
    else
        bash InstallNET.sh $DD_ARGS -p "${ROOT_PASS}"
    fi
    
    # 清理
    rm -f InstallNET.sh
    
    echo -e "${GREEN}安装命令已执行！${NC}"
    echo -e "${YELLOW}系统将在重启后完成安装${NC}"
    echo -e "${YELLOW}请记住以下信息：${NC}"
    echo -e "用户名：${GREEN}root${NC}"
    echo -e "密码：${GREEN}${ROOT_PASS}${NC}"
    echo -e "\n${RED}重要：请确保记住了上述信息再继续！${NC}"
    read -p "按回车键重启服务器..."
    
    reboot
}

# 主菜单
main() {
    check_root
    check_system
    
    while true; do
        clear
        echo -e "${GREEN}=== 系统初始化工具 ===${NC}"
        echo "1. 系统更新"
        echo "2. 安装基础工具"
        echo "3. 配置SSH安全"
        echo "4. 系统优化"
        echo "5. 配置时区"
        echo "6. 启用BBR"
        echo "7. 执行所有操作"
        echo "8. 重置服务器"
        echo "9. DD重装系统"
        echo "10. 返回主菜单"
        
        read -p "请选择操作 (1-10): " choice
        
        case $choice in
            1) system_update ;;
            2) install_basic_tools ;;
            3) secure_ssh ;;
            4) system_optimize ;;
            5) set_timezone ;;
            6) enable_bbr ;;
            7)
                system_update
                install_basic_tools
                secure_ssh
                system_optimize
                set_timezone
                enable_bbr
                ;;
            8) reset_server ;;
            9) dd_system ;;
            10) return 0 ;;
            *) echo -e "${RED}无效选择${NC}" ;;
        esac
        
        read -p "按回车键继续..."
    done
}

main "$@" 