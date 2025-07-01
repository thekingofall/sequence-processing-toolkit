# 第一章：快速开始指南

> 🚀 5分钟上手 S1S2HiC 序列处理工具包

## 1.1 一句话介绍

本工具包提供两套系统：
- **S1S2HiC系统** - 生物信息学Hi-C数据一键分析
- **通用并行系统** - 任意脚本并行执行框架

## 1.2 S1S2HiC数据分析 (生物信息学用户)

### 三步搞定分析

```bash
# 步骤1: 创建配置文件
./run_s1s2hic_auto.sh --create-template

# 步骤2: 编辑配置文件  
nano configs/templates/simple_config.conf
# 只需修改三个参数:
# PROJECT_NAME=my_experiment_20250126
# GROUPS=1,2,3
# DATA_ROOT=/your/data/path

# 步骤3: 启动分析
./run_s1s2hic_auto.sh configs/templates/simple_config.conf
```

### 预设组选择指南

| 组号 | 酶切类型 | 样本数 | 推荐场景 |
|------|----------|--------|----------|
| **Group1** | MboI+GATC+SeqA | 3 | 标准实验，数据量大 |
| **Group2** | MboI+GATC+SeqB | 1 | 快速测试，对照组 |
| **Group3** | MseI+CviQI+TA+SeqA | 3 | 双酶切实验 |
| **Group4** | MseI+CviQI+TA+SeqB | 1 | 双酶切对照 |
| **Group5** | MboI+CviQI+GATC+TA+SeqA | 1 | 多酶切实验 |

**快速选择建议：**
- 🚀 **快速测试**: `GROUPS=2` (最快，1个样本)
- 🧪 **标准分析**: `GROUPS=1,2,3,4,5` (全部组)
- 🎯 **自定义**: 根据实验设计选择对应组号

## 1.3 通用并行处理 (任意脚本)

### 使用预设配置

```bash
# 直接使用S1S2HiC预设组
./runsh.sh -c configs/templates/parallel_config.yaml
```

### 完全自定义配置

```bash
# 复制空白模板
cp configs/templates/blank_config.yaml my_project.yaml

# 编辑配置文件
vim my_project.yaml

# 运行自定义任务
./runsh.sh -c my_project.yaml
```

## 1.4 验证安装

```bash
# 检查帮助信息
./runsh.sh -h
./run_s1s2hic_auto.sh --help

# 验证配置文件
python3 scripts/config_parser.py configs/templates/parallel_config.yaml --validate

# 列出可用组
./runsh.sh -l -c configs/templates/parallel_config.yaml
```

## 1.5 下一步

- 📖 [第二章：S1S2HiC系统详解](02-s1s2hic-system.md) - 生物信息学用户
- ⚙️ [第三章：通用并行系统详解](03-parallel-system.md) - 通用脚本用户
- 🛠️ [第四章：配置文件详解](04-configuration.md) - 高级配置 