# All in One Shell Scripts

这是一个实用的Shell脚本集合，旨在简化日常运维和开发工作。

## 目录结构

```
daily-shell-scripts/
├── src/                           # 源代码目录
│   ├── network/                   # 网络工具脚本
│   │   └── ssl_renew.sh          # SSL证书自动续签工具
│   └── ...                       # 其他工具目录
```

## 脚本列表

### 1. SSL证书自动续签工具 (ssl_renew.sh)

自动化SSL证书申请和续签的交互式工具，基于acme.sh。

#### 功能特点：
- 自动检查并安装acme.sh
- 支持申请新证书
- 自动续签已有证书
- 查看证书状态
- 配置自动续签（通过crontab）
- 友好的交互界面

#### 使用方法：
1. 确保脚本有执行权限：
```bash
chmod +x src/network/ssl_renew.sh
```

2. 运行脚本：
```bash
./src/network/ssl_renew.sh
```

3. 按照菜单提示进行操作：
   - 选项1：申请新证书
   - 选项2：续签已有证书
   - 选项3：查看证书状态
   - 选项4：配置自动续签

#### 依赖：
- acme.sh（脚本会自动检查���提示安装）
- bash
- curl

## 贡献指南

欢迎提交Issue和Pull Request来帮助改进这个项目。

## 许可证

MIT License 