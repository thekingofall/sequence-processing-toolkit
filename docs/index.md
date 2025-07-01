# 📖 S1S2HiC序列处理工具包 - 用户手册索引

> 📚 **完整用户手册** - 从入门到精通的7章指南

## 🎯 快速导航

### 按用户类型分类

#### 🧬 生物信息学用户
- **新手入门**: [第一章 快速开始](chapters/01-quick-start.md#12-s1s2hic数据分析-生物信息学用户) → [第二章 S1S2HiC系统详解](chapters/02-s1s2hic-system.md)
- **深度配置**: [第四章 配置文件详解](chapters/04-configuration.md#42-s1s2hic配置文件-simple_configconf)
- **故障排除**: [第七章 故障排除](chapters/07-troubleshooting.md)

#### ⚙️ 通用脚本用户  
- **新手入门**: [第一章 快速开始](chapters/01-quick-start.md#13-通用并行处理-任意脚本) → [第三章 通用并行系统详解](chapters/03-parallel-system.md)
- **高级配置**: [第四章 配置文件详解](chapters/04-configuration.md#43-通用系统配置文件-yaml格式)
- **性能调优**: [第三章 性能调优](chapters/03-parallel-system.md#37-性能调优)

#### 🛠️ 运维管理员
- **命令参考**: [第五章 命令参考](chapters/05-commands.md)
- **文件结构**: [第六章 文件结构详解](chapters/06-file-structure.md)
- **故障诊断**: [第七章 故障排除](chapters/07-troubleshooting.md)

#### 👨‍💻 开发者
- **系统架构**: [第三章 核心架构](chapters/03-parallel-system.md#32-核心架构)
- **文件组织**: [第六章 文件结构详解](chapters/06-file-structure.md)
- **扩展开发**: [第六章 项目扩展](chapters/06-file-structure.md#671-项目扩展)

### 按问题类型分类

#### 🚀 快速开始
- [5分钟上手指南](chapters/01-quick-start.md)
- [S1S2HiC三步搞定](chapters/01-quick-start.md#12-s1s2hic数据分析-生物信息学用户)
- [通用系统快速开始](chapters/01-quick-start.md#13-通用并行处理-任意脚本)

#### ⚙️ 配置相关
- [配置文件模板选择](chapters/04-configuration.md#41-配置模板总览)
- [YAML格式详解](chapters/04-configuration.md#43-通用系统配置文件-yaml格式)
- [路径配置技巧](chapters/04-configuration.md#44-路径配置高级技巧)
- [配置验证](chapters/04-configuration.md#46-配置验证)

#### 🔧 运行和监控
- [命令使用方法](chapters/05-commands.md)
- [日志监控](chapters/05-commands.md#56-日志和监控命令)
- [进程管理](chapters/05-commands.md#57-系统管理命令)

#### 🆘 故障排除
- [环境问题](chapters/07-troubleshooting.md#72-环境问题)
- [配置问题](chapters/07-troubleshooting.md#73-配置问题)
- [运行时问题](chapters/07-troubleshooting.md#74-运行时问题)
- [性能问题](chapters/07-troubleshooting.md#76-性能问题)

## 📚 完整章节目录

### [第一章：快速开始指南](chapters/01-quick-start.md)
> 🚀 5分钟上手 S1S2HiC 序列处理工具包

**内容概览:**
- 1.1 一句话介绍
- 1.2 S1S2HiC数据分析 (生物信息学用户)
- 1.3 通用并行处理 (任意脚本)
- 1.4 验证安装
- 1.5 下一步

**适合读者**: 所有新用户  
**预计时间**: 5分钟

---

### [第二章：S1S2HiC系统详解](chapters/02-s1s2hic-system.md)
> 🧬 专为生物信息学Hi-C数据分析设计的一键式处理工具

**内容概览:**
- 2.1 系统概述
- 2.2 预设实验组详解 (Group1-5)
- 2.3 配置文件详解
- 2.4 数据目录结构要求
- 2.5 工作流程详解 (S1→S2→HiC→结果)
- 2.6 结果文件说明
- 2.7 性能优化建议
- 2.8 常见使用场景

**适合读者**: 生物信息学研究者  
**预计时间**: 15分钟

---

### [第三章：通用并行系统详解](chapters/03-parallel-system.md)
> ⚙️ 配置驱动的任意脚本并行执行框架

**内容概览:**
- 3.1 系统概述
- 3.2 核心架构
- 3.3 配置文件结构详解
- 3.4 支持的脚本类型 (Python/Bash/R)
- 3.5 使用场景示例
- 3.6 高级功能 (信号处理、日志管理)
- 3.7 性能调优
- 3.8 与S1S2HiC系统的关系
- 3.9 最佳实践

**适合读者**: 通用脚本用户、开发者  
**预计时间**: 20分钟

---

### [第四章：配置文件详解](chapters/04-configuration.md)
> 🛠️ 深入理解配置文件格式和高级配置技巧

**内容概览:**
- 4.1 配置模板总览
- 4.2 S1S2HiC配置文件 (simple_config.conf)
- 4.3 通用系统配置文件 (YAML格式)
- 4.4 路径配置高级技巧
- 4.5 高级配置技巧
- 4.6 配置验证
- 4.7 配置文件模板选择指南

**适合读者**: 高级用户、需要自定义配置的用户  
**预计时间**: 25分钟

---

### [第五章：命令参考](chapters/05-commands.md)
> 📋 完整的命令行参考手册和使用示例

**内容概览:**
- 5.1 命令概览
- 5.2 runsh.sh - 通用并行处理主脚本
- 5.3 run_s1s2hic_auto.sh - S1S2HiC自动化脚本
- 5.4 config_parser.py - 配置解析工具
- 5.5 check_setup.sh - 环境检查工具
- 5.6 日志和监控命令
- 5.7 系统管理命令
- 5.8 常用命令组合

**适合读者**: 运维用户、需要命令参考的用户  
**预计时间**: 10分钟（参考手册）

---

### [第六章：文件结构详解](chapters/06-file-structure.md)
> 📁 深入理解项目组织结构和文件分布

**内容概览:**
- 6.1 整体架构
- 6.2 完整目录结构
- 6.3 文件功能详解
- 6.4 路径规则和约定
- 6.5 文件权限和所有权
- 6.6 存储空间规划
- 6.7 文件组织最佳实践

**适合读者**: 开发者、运维人员  
**预计时间**: 15分钟

---

### [第七章：故障排除](chapters/07-troubleshooting.md)
> 🔧 常见问题诊断和解决方案

**内容概览:**
- 7.1 问题分类
- 7.2 环境问题 (Python、依赖包、权限)
- 7.3 配置问题 (YAML语法、路径错误)
- 7.4 运行时问题 (内存、磁盘、进程)
- 7.5 结果问题 (输出异常、数据丢失)
- 7.6 性能问题 (速度慢、内存高)
- 7.7 调试技巧
- 7.8 常见问题FAQ

**适合读者**: 遇到问题的所有用户  
**预计时间**: 按需查阅

## 🎓 学习路径建议

### 🔰 新手用户路径
```
第一章 快速开始 (5分钟)
    ↓
第二章/第三章 系统详解 (15-20分钟)  
    ↓
第四章 配置详解 (25分钟)
    ↓
第五章 命令参考 (备查)
```

### 🎯 问题导向路径
```
遇到问题
    ↓
第七章 故障排除 (查找解决方案)
    ↓
相关章节深入阅读
```

### 👨‍💻 开发者路径
```
第三章 系统架构 (20分钟)
    ↓
第六章 文件结构 (15分钟)
    ↓
第四章 配置详解 (25分钟)
    ↓
第五章 命令参考 (备查)
```

## 📱 快速查找

### 常用快捷链接

| 需求 | 直达链接 |
|------|----------|
| 立即开始使用 | [30秒上手](chapters/01-quick-start.md#30秒上手) |
| S1S2HiC组详解 | [预设实验组](chapters/02-s1s2hic-system.md#22-预设实验组详解) |
| 配置文件模板 | [模板选择指南](chapters/04-configuration.md#47-配置文件模板选择指南) |
| 错误解决方案 | [故障排除FAQ](chapters/07-troubleshooting.md#78-常见问题faq) |
| 命令快速参考 | [命令概览](chapters/05-commands.md#51-命令概览) |
| 性能优化 | [性能调优](chapters/03-parallel-system.md#37-性能调优) |

### 按关键词搜索

**配置相关**: [第四章](chapters/04-configuration.md)  
**命令相关**: [第五章](chapters/05-commands.md)  
**错误相关**: [第七章](chapters/07-troubleshooting.md)  
**架构相关**: [第三章](chapters/03-parallel-system.md) + [第六章](chapters/06-file-structure.md)  
**生物信息**: [第二章](chapters/02-s1s2hic-system.md)

## 💡 使用建议

1. **第一次使用**: 建议从[第一章](chapters/01-quick-start.md)开始，花5分钟了解基本概念
2. **特定需求**: 直接跳转到对应章节，文档支持独立阅读
3. **遇到问题**: 优先查看[第七章 故障排除](chapters/07-troubleshooting.md)
4. **深入学习**: 按推荐路径逐章阅读
5. **日常参考**: 收藏[第五章 命令参考](chapters/05-commands.md)

---

📖 **返回**: [主README](../README.md) | 🚀 **开始**: [第一章 快速开始](chapters/01-quick-start.md) 