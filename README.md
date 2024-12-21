<h1 align="center">🚀 VPS 管理控制台</h1>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000" />
  <img src="https://img.shields.io/badge/bash-%23121011.svg?style=flat&logo=gnu-bash&logoColor=white" />
  <img src="https://img.shields.io/badge/license-MIT-green.svg" />
</p>

<p align="center">一个功能强大的 VPS 管理工具，集成系统初始化、安全加固、面板安装等功能</p>

## 🌟 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/maticarmy/allinone/master/install.sh)
```

## ✨ 功能特点

### 🔧 系统初始化
- 系统更新和清理
- 基础工具安装
- SSH 安全配置
- 系统参数优化
- BBR 加速配置
- 时区设置

### 🔐 SSL证书管理
- 自动申请证书
- 自动续签
- 支持宝塔面板
- 多域名管理

### 🛡️ 防火墙配置
- 智能端口管理
- 基础安全规则
- UFW/Firewalld 支持
- 自定义规则配置

### 📊 面板管理
- 宝塔面板
- 1Panel
- 3x-ui
- 一键安装/卸载

### 💾 备份管理
- 系统备份
- 数据库备份
- 自动备份计划
- 定期清理

### 🔄 系统重装
- DD 重装系统
- 支持主流系统
  - Debian 11/12
  - Ubuntu 20.04/22.04
  - CentOS 7
- 可自定义镜像
- 安全确认机制

## 📖 使用指南

### 🚀 新服务器推荐流程
1. 运行一键脚本
2. 选择系统初始化
3. 配置防火墙规则
4. 安装所需面板
5. 设置自动备份

### ⚠️ 重要操作说明
1. DD重装系统
   - 确保有备用登录方式
   - 记录重要信息
   - 提前备份数据

2. 重置服务器
   - 清理所有数据
   - 重置系统设置
   - 需二次确认

## 📝 注意事项

- 需要 root 权限运行
- 重要操作有二次确认
- 建议操作前备份
- 保持 SSH 连接稳定

## 🔧 环境要求

- 系统支持：Debian/Ubuntu/CentOS
- 需要 root 权限
- 需要稳定的网络连接

## 🆕 更新日志

### v1.0.0
- 首次发布
- 集成基础功能
- 支持主流系统
- Matrix 风格界面
- 完整的备份功能
- DD 重装系统支持

## 🤝 问题反馈

如有问题请提交 [Issues](https://github.com/maticarmy/allinone/issues)

## 📜 开源协议

本项目采用 MIT 协议开源，使用请注明来源。