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

# 配置备份
configure_backup() {
    echo -e "${YELLOW}配置备份设置...${NC}"
    
    # 创建备份目录
    read -p "请输入备份目录路径 [默认: /backup]: " BACKUP_DIR
    BACKUP_DIR=${BACKUP_DIR:-/backup}
    mkdir -p $BACKUP_DIR
    
    # 配置备份保留天数
    read -p "请输入备份保留天数 [默认: 7]: " KEEP_DAYS
    KEEP_DAYS=${KEEP_DAYS:-7}
    
    # 保存配置
    cat > /etc/backup.conf << EOF
BACKUP_DIR=$BACKUP_DIR
KEEP_DAYS=$KEEP_DAYS
EOF
    
    echo -e "${GREEN}备份配置完成${NC}"
}

# 系统备份
backup_system() {
    echo -e "${YELLOW}开始系统备份...${NC}"
    
    # 加载配置
    source /etc/backup.conf
    
    # 创建备份文件名
    BACKUP_FILE="$BACKUP_DIR/system_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # 备份系统关键目录
    tar -czf $BACKUP_FILE /etc /root /home /var/www 2>/dev/null
    
    echo -e "${GREEN}系统备份完成: $BACKUP_FILE${NC}"
}

# 数据库备份
backup_database() {
    echo -e "${YELLOW}开始数据库备份...${NC}"
    
    # 加载配置
    source /etc/backup.conf
    
    # 检测数据库类型
    if command -v mysql >/dev/null 2>&1; then
        echo -e "${YELLOW}检测到MySQL/MariaDB...${NC}"
        read -p "请输入数据库root密码: " DB_PASS
        
        # 创建备份文件名
        BACKUP_FILE="$BACKUP_DIR/mysql_$(date +%Y%m%d_%H%M%S).sql"
        
        # 备份所有数据库
        mysqldump -uroot -p$DB_PASS --all-databases > $BACKUP_FILE
        
        echo -e "${GREEN}数据库备份完成: $BACKUP_FILE${NC}"
    fi
}

# 清理旧备份
cleanup_old_backups() {
    echo -e "${YELLOW}清理旧备份...${NC}"
    
    # 加载配置
    source /etc/backup.conf
    
    # 删除超过保留天数的备份
    find $BACKUP_DIR -type f -mtime +$KEEP_DAYS -delete
    
    echo -e "${GREEN}旧备份清理完成${NC}"
}

# 配置自动备份
setup_auto_backup() {
    echo -e "${YELLOW}配置自动备份...${NC}"
    
    # 创建备份脚本
    cat > /usr/local/bin/auto_backup.sh << 'EOF'
#!/bin/bash
source /etc/backup.conf
/root/scripts/backup.sh --system
/root/scripts/backup.sh --database
/root/scripts/backup.sh --cleanup
EOF
    
    chmod +x /usr/local/bin/auto_backup.sh
    
    # 添加到crontab
    (crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/auto_backup.sh") | crontab -
    
    echo -e "${GREEN}自动备份配置完成${NC}"
}

# 主菜单
main() {
    check_root
    
    # 处理命令行参数
    case "$1" in
        --system)
            backup_system
            exit 0
            ;;
        --database)
            backup_database
            exit 0
            ;;
        --cleanup)
            cleanup_old_backups
            exit 0
            ;;
    esac
    
    while true; do
        clear
        echo -e "${GREEN}=== 备份管理工具 ===${NC}"
        echo "1. 配置备份设置"
        echo "2. 系统备份"
        echo "3. 数据库备份"
        echo "4. 清理旧备份"
        echo "5. 配置自动备份"
        echo "6. 返回主菜单"
        
        read -p "请选择操作 (1-6): " choice
        
        case $choice in
            1) configure_backup ;;
            2) backup_system ;;
            3) backup_database ;;
            4) cleanup_old_backups ;;
            5) setup_auto_backup ;;
            6) return 0 ;;
            *) echo -e "${RED}无效选择${NC}" ;;
        esac
        
        read -p "按回车键继续..."
    done
}

main "$@" 