# S1S2HiC 完整流程处理脚本使用指南

## 📋 概述

`S1S2HiC_Pipeline.py` 是一个集成化的Hi-C数据处理流程脚本，它将S1序列筛选、S2序列分割和HiC-Pro分析整合为一个完整的自动化流程。**现在支持配置文件模式，推荐使用配置文件来管理复杂的参数设置。**

## 🚀 主要功能

- ✅ **配置文件支持**：使用YAML配置文件管理所有参数，更易维护
- ✅ **S1序列筛选**：从原始文件中筛选匹配指定序列模式的reads
- ✅ **S2序列分割**：将筛选的reads根据分隔符分割为R1和R2配对文件
- ✅ **数据整理**：自动将R1/R2文件整理为HiC-Pro输入格式
- ✅ **HiC-Pro分析**：执行完整的Hi-C数据分析流程
- ✅ **流程控制**：支持跳过特定步骤，从中间步骤开始运行
- ✅ **报告生成**：自动生成详细的处理报告

## 📁 文件位置

```
sequence-processing-toolkit/
├── src/
│   ├── S1S2HiC_Pipeline.py      # 主流程脚本
│   ├── S1_Process_gen.py        # S1筛选脚本
│   └── S2_Split.py              # S2分割脚本
├── Scripts/
│   └── schic_analysis_pipeline.sh  # HiC-Pro分析脚本
├── config_template.yaml        # 配置文件模板
└── docs/
    └── README_S1S2HiC_Pipeline.md  # 本文档
```

## 🛠️ 系统要求

### 环境依赖
- **Python 3.6+**
- **PyYAML库**: `pip install pyyaml`
- **Bash 4.0+**
- **HiC-Pro** (通过conda安装)
- **Conda环境**: 默认为`hicpro3`

### 输入文件要求
- 原始FASTQ文件（`.gz`格式）
- 文件应包含待筛选的序列模式

## 🔄 推荐使用方法 - 配置文件模式

### 步骤1：生成配置文件模板

```bash
cd sequence-processing-toolkit/src/

# 生成配置文件模板
python S1S2HiC_Pipeline.py --generate-config my_config.yaml
```

### 步骤2：编辑配置文件

打开生成的配置文件进行编辑：

```bash
nano my_config.yaml
```

**配置文件示例：**
```yaml
# S1步骤配置 - 序列筛选
S1_config:
  patterns: "ATCGATCG,GCTAGCTA"
  description: "我的HiC项目"
  input_pattern: "*gz"
  lines_to_process: 100000
  jobs: 8
  output_dir: "S1_Matched"

# S2步骤配置 - 序列分割
S2_config:
  separator1: "GATCATGTCGGAACTGTTGCTTGTCCGACTGATC"
  separator2: "AGATCGGAAGA"
  min_length: 10
  output_dir: "S2_Split"

# HiC步骤配置 - HiC-Pro分析
HiC_config:
  input_dir: "HiC_Input"
  project_name: "MyProject_20240701"
  config_type: 1
  modules: "1,2,3"
  cpu_count: 16
  conda_env: "hicpro3"

# 流程控制配置
workflow_control:
  skip_s1: false
  skip_s2: false
  skip_hic: false
```

### 步骤3：运行流程

```bash
# 使用配置文件运行完整流程
python S1S2HiC_Pipeline.py -c my_config.yaml
```

## 📝 配置文件详细说明

### S1_config 配置项

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `patterns` | 字符串 | **必需** 逗号分隔的搜索序列 | `"ATCGATCG,GCTAGCTA"` |
| `description` | 字符串 | 项目描述 | `"细胞系A_HiC分析"` |
| `input_pattern` | 字符串 | 输入文件匹配模式 | `"*.fastq.gz"` |
| `lines_to_process` | 数字/字符串 | 处理行数 | `100000` 或 `"all"` |
| `jobs` | 数字 | 并行任务数 | `8` |
| `output_dir` | 字符串 | S1输出目录 | `"S1_Matched"` |

### S2_config 配置项

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `separator1` | 字符串 | 第一个分隔符序列 | `"GATCATGTCGGAACTGTTGCTTGTCCGACTGATC"` |
| `separator2` | 字符串 | 第二个分隔符序列 | `"AGATCGGAAGA"` |
| `min_length` | 数字 | 分割后序列最小长度 | `10` |
| `output_dir` | 字符串 | S2输出目录 | `"S2_Split"` |

### HiC_config 配置项

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `input_dir` | 字符串 | HiC输入目录 | `"HiC_Input"` |
| `project_name` | 字符串 | 项目名称（空则自动生成） | `"MyProject_20240701"` |
| `config_type` | 数字 | 配置文件类型（1-3） | `1` |
| `modules` | 字符串 | 运行的模块 | `"1,2,3"` |
| `cpu_count` | 数字 | CPU数量 | `16` |
| `conda_env` | 字符串 | Conda环境 | `"hicpro3"` |

### workflow_control 配置项

| 参数 | 类型 | 说明 |
|------|------|------|
| `skip_s1` | 布尔值 | 跳过S1步骤 |
| `skip_s2` | 布尔值 | 跳过S2步骤 |
| `skip_hic` | 布尔值 | 跳过HiC步骤 |

## 🔧 高级使用 - 命令行参数覆盖

可以使用命令行参数覆盖配置文件中的设置：

```bash
# 使用配置文件，但覆盖项目名称和CPU数
python S1S2HiC_Pipeline.py \
    -c my_config.yaml \
    --project-name "NewProject_20240701" \
    --hic-cpu 20
```

## 📝 使用示例

### 示例1：基本使用

```bash
# 1. 生成配置文件
python S1S2HiC_Pipeline.py --generate-config basic_config.yaml

# 2. 编辑配置文件中的patterns
# 将 patterns: "ATCGATCG,GCTAGCTA" 改为你的序列

# 3. 运行流程
python S1S2HiC_Pipeline.py -c basic_config.yaml
```

### 示例2：大数据处理

```yaml
# big_data_config.yaml
S1_config:
  patterns: "GATCGATC,ATCGATCG,GCTAGCTA"
  lines_to_process: "all"  # 处理所有行
  jobs: 16                 # 更多并行任务
  
HiC_config:
  cpu_count: 32           # 更多CPU
  project_name: "LargeDataset_HiC"
```

### 示例3：分步执行

```yaml
# step_by_step_config.yaml
workflow_control:
  skip_s1: false    # 只运行S1
  skip_s2: true
  skip_hic: true
```

```bash
# 只运行S1步骤
python S1S2HiC_Pipeline.py -c step_by_step_config.yaml
```

### 示例4：从中间步骤开始

```yaml
# continue_config.yaml  
workflow_control:
  skip_s1: true      # 跳过S1，使用现有结果
  skip_s2: false     # 从S2开始
  skip_hic: false
```

## 📊 输出结构

输出结构与之前相同：

```
当前目录/
├── S1_Matched/                     # S1筛选结果
├── S2_Split/                       # S2分割结果
├── HiC_Input/                      # HiC-Pro输入格式
├── Run3_hic/                       # HiC-Pro分析结果
├── Run4_HICdata*/                  # 最终HiC数据
└── S1S2HiC_Complete_Report_*.txt   # 处理报告
```

## 🔍 故障排除

### 配置文件相关错误

#### 1. YAML格式错误
```
错误: 配置文件格式错误
解决: 检查YAML语法，确保缩进正确，使用空格而非制表符
```

#### 2. 缺少必需配置
```
错误: S1_config缺少patterns配置
解决: 确保配置文件包含所有必需的配置项
```

#### 3. 配置文件不存在
```
错误: 配置文件不存在: my_config.yaml
解决: 检查文件路径，或使用--generate-config生成模板
```

### 兼容性模式（命令行参数）

如果不想使用配置文件，仍可使用命令行参数：

```bash
# 最简单的命令行模式
python S1S2HiC_Pipeline.py -p "ATCGATCG,GCTAGCTA" -d "我的项目"
```

## 💡 最佳实践

### 1. 配置文件管理
- 为不同项目创建不同的配置文件
- 使用有意义的文件名，如`project_celllineA.yaml`
- 在配置文件中添加注释说明参数用途

### 2. 大数据处理
- 首先用小数据集测试配置文件
- 逐步增加`lines_to_process`和`jobs`参数
- 监控系统资源使用情况

### 3. 流程管理
- 使用版本控制管理配置文件
- 保存成功运行的配置文件作为模板
- 定期备份重要的配置文件

## 📞 技术支持

### 获取帮助

```bash
# 查看完整帮助信息
python S1S2HiC_Pipeline.py --help

# 生成配置文件模板
python S1S2HiC_Pipeline.py --generate-config template.yaml
```

### 相关文档

- [配置文件模板](../config_template.yaml)
- [S1_Process_gen.py 使用指南](./README_process_sequences.md)
- [S2_Split.py 使用指南](./README_S2_Split.md)
- [HiC-Pro流程文档](./README_Suite.md)

---

*最后更新：2025年7月* 