# 🧬 S1S2HiC 序列处理工具包

> **配置驱动的生物信息学并行处理系统**  
> 一个命令 + 一个配置文件 = 解决所有并行任务

## 📖 用户手册目录

| 章节 | 标题 | 适合读者 | 预计时间 |
|------|------|----------|----------|
| [第一章](docs/chapters/01-quick-start.md) | 🚀 快速开始指南 | 所有用户 | 5分钟 |
| [第二章](docs/chapters/02-s1s2hic-system.md) | 🧬 S1S2HiC系统详解 | 生物信息学用户 | 15分钟 |
| [第三章](docs/chapters/03-parallel-system.md) | ⚙️ 通用并行系统详解 | 通用脚本用户 | 20分钟 |
| [第四章](docs/chapters/04-configuration.md) | 🛠️ 配置文件详解 | 高级用户 | 25分钟 |
| [第五章](docs/chapters/05-commands.md) | 📋 命令参考 | 运维用户 | 10分钟 |
| [第六章](docs/chapters/06-file-structure.md) | 📁 文件结构详解 | 开发者 | 15分钟 |
| [第七章](docs/chapters/07-troubleshooting.md) | 🔧 故障排除 | 运维用户 | 按需查阅 |
| [第八章](docs/chapters/08-individual-tools.md) | 🛠️ 单个工具详解 | 开发者/高级用户 | 30分钟 |
| [第九章](docs/chapters/09-download-tools.md) | 📥 数据下载工具 | 数据管理用户 | 15分钟 |

## 🎯 快速决策

### 我是什么用户？

```
├── 🧬 生物信息学用户（Hi-C数据分析）
│   ├── 第一次使用 → [第一章 快速开始](docs/chapters/01-quick-start.md#12-s1s2hic数据分析-生物信息学用户)
│   └── 深入学习 → [第二章 S1S2HiC系统](docs/chapters/02-s1s2hic-system.md)
│
├── ⚙️ 通用脚本用户（任意并行任务）
│   ├── 第一次使用 → [第一章 快速开始](docs/chapters/01-quick-start.md#13-通用并行处理-任意脚本)
│   └── 深入学习 → [第三章 通用并行系统](docs/chapters/03-parallel-system.md)
│
├── 🛠️ 高级用户（自定义配置）
│   └── 直接阅读 → [第四章 配置文件详解](docs/chapters/04-configuration.md)
│
└── 🆘 遇到问题
    └── 查看解决方案 → [第七章 故障排除](docs/chapters/07-troubleshooting.md)
```

## ⚡ 30秒上手

### S1S2HiC数据分析
```bash
# 创建配置 → 编辑参数 → 启动分析
./run_s1s2hic_auto.sh --create-template
nano configs/templates/simple_config.conf  # 修改3个参数
./run_s1s2hic_auto.sh configs/templates/simple_config.conf
```

### 通用并行处理
```bash
# 使用模板 → 运行任务
./runsh.sh -c configs/templates/parallel_config.yaml
```

## 🎨 核心特色

| 特色 | S1S2HiC系统 | 通用并行系统 |
|------|-------------|--------------|
| **目标用户** | 生物信息学研究者 | 任意脚本用户 |
| **预设功能** | 5个Hi-C实验组 | 完全可配置 |
| **配置格式** | `.conf` (bash格式) | `.yaml` (通用格式) |
| **使用命令** | `run_s1s2hic_auto.sh` | `runsh.sh` |
| **学习成本** | 极低（3个参数） | 中等（YAML配置） |
| **灵活程度** | 固定流程 | 无限灵活 |

## 🔥 核心优势

- **🚀 零学习成本** - 生物信息学用户只需修改3个参数
- **⚙️ 完全解耦** - 通用用户永远不需要修改代码
- **🔄 自动并行** - 智能管理多任务，支持优雅中断
- **📊 实时监控** - 独立日志，进度可视，错误隔离
- **🛠️ 灵活路径** - 支持环境变量、相对路径、自动检测
- **📚 完整文档** - 7章手册，从入门到精通

## 🗂️ 项目结构

```
sequence-processing-toolkit/
├── 🚀 主脚本
│   ├── runsh.sh                 # 通用并行处理
│   └── run_s1s2hic_auto.sh     # S1S2HiC自动化
├── ⚙️ 配置系统
│   ├── configs/templates/       # 配置模板
│   ├── configs/environments/    # 环境配置  
│   └── configs/Group*.yaml     # S1S2HiC组配置
├── 🔧 工具脚本
│   └── scripts/                # 解析器、检查器、清理器
├── 📚 源代码
│   └── src/                    # S1S2HiC流程、处理模块
├── 📖 用户手册
│   └── docs/chapters/          # 7章完整文档
└── 📝 日志系统
    ├── auto_logs/              # S1S2HiC日志
    └── parallel_logs/          # 并行处理日志
```

## 📞 技术支持

### 🆘 遇到问题？

1. **配置错误** → [第四章 配置文件详解](docs/chapters/04-configuration.md)
2. **命令不熟** → [第五章 命令参考](docs/chapters/05-commands.md)  
3. **运行报错** → [第七章 故障排除](docs/chapters/07-troubleshooting.md)
4. **工具使用** → [第八章 单个工具详解](docs/chapters/08-individual-tools.md)
5. **数据下载** → [第九章 数据下载工具](docs/chapters/09-download-tools.md)
6. **性能优化** → [第七章 性能问题](docs/chapters/07-troubleshooting.md#76-性能问题)

### 🎓 深入学习

- 🔰 **新手** → 按章节顺序阅读 1→2/3→4
- 🎯 **特定需求** → 直接跳转到对应章节
- 🛠️ **工具使用** → 参考 [第八章 单个工具详解](docs/chapters/08-individual-tools.md)
- 📥 **数据下载** → 参考 [第九章 数据下载工具](docs/chapters/09-download-tools.md)
- 🚀 **快速参考** → 查看 [第五章 命令参考](docs/chapters/05-commands.md)

### 📊 实用工具

```bash
# 环境检查
bash scripts/check_setup.sh

# 配置验证  
python3 scripts/config_parser.py config.yaml --validate

# 列出任务组
./runsh.sh -l -c config.yaml

# 实时监控
tail -f auto_logs/*.log parallel_logs/*.log
```

---

**💡 提示**: 第一次使用建议从 [第一章 快速开始](docs/chapters/01-quick-start.md) 开始，5分钟即可上手！ 