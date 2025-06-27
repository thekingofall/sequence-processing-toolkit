# Sequence Processing Toolkit / 序列处理工具包

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Bash](https://img.shields.io/badge/bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)

**English** | [中文](#中文版本)

A comprehensive toolkit for high-throughput sequencing data processing, featuring sequence pattern analysis, FASTQ file manipulation, and batch processing capabilities.

## 🚀 Features

- **🔍 Sequence Pattern Analysis**: Search and quantify specific sequence motifs with forward and reverse complement matching
- **✂️ Intelligent FASTQ Splitting**: Split FASTQ files into paired R1/R2 reads based on separator sequences
- **⚡ High-Performance Batch Processing**: Process multiple compressed files in parallel with optimized performance
- **📊 Comprehensive Statistics**: Generate detailed reports with matching percentages and quality metrics
- **🧬 Reverse Complement Support**: Automatic reverse complement calculation and matching
- **📁 Batch Operations**: Process hundreds of files simultaneously with multi-core support

## 📋 Quick Start

### Prerequisites

```bash
# Python 3.6+ required
python --version

# Standard Unix tools (usually pre-installed)
which gzip grep awk wc head sort tee
```

### Installation

```bash
# Clone the repository
git clone https://github.com/thekingofall/sequence-processing-toolkit.git
cd sequence-processing-toolkit

# Make scripts executable
chmod +x src/*.py src/*.sh
```

### Basic Usage

```bash
# 1. Sequence pattern analysis
python src/S1_Process_gen.py -p "ATCGATCG,GCTAGCTA" -d "Pattern Analysis"

# 2. FASTQ file splitting
python src/S2_Split.py -i input.fastq.gz -o output_dir

# 3. Batch processing
./src/S3_process_sequences_count.sh -p "SEQUENCE1,SEQUENCE2" -j 8
```

## 🛠️ Tools Overview

| Tool | Purpose | Best For |
|------|---------|----------|
| **S1_Process_gen.py** | Sequence pattern search & statistics | Quality control, motif analysis |
| **S2_Split.py** | FASTQ file splitting & pairing | Data preprocessing, barcode separation |
| **S3_process_sequences_count.sh** | High-performance batch processing | Large-scale analysis, production pipelines |
| **S1S2_Pipeline.py** | S1→S2 integrated workflow | Streamlined sequence processing |
| **S1S2HiC_Pipeline.py** | Complete S1→S2→HiC-Pro workflow | End-to-end Hi-C analysis |

## 📁 Project Structure

```
sequence-processing-toolkit/
├── README.md                 # Main project documentation
├── src/                      # Source code
│   ├── S1_Process_gen.py     # Pattern analysis tool
│   ├── S2_Split.py           # FASTQ splitting tool
│   ├── S3_process_sequences_count.sh  # Batch processing tool
│   ├── S1S2_Pipeline.py      # S1→S2 integrated workflow
│   └── S1S2HiC_Pipeline.py   # Complete S1→S2→HiC-Pro workflow
├── Scripts/                  # External pipeline scripts
│   └── schic_analysis_pipeline.sh # Single-cell HiC analysis pipeline
├── docs/                     # Detailed documentation
│   ├── index.md              # Documentation index
│   ├── README.md             # S1 tool documentation
│   ├── README_S2_Split.md    # S2 tool documentation
│   ├── README_process_sequences.md  # S3 tool documentation
│   └── README_Suite.md       # Comprehensive toolkit guide
└── examples/                 # Usage examples and sample data
    ├── basic_usage.sh        # Basic usage examples
    ├── run_s1s2_example.sh   # S1S2 workflow examples
    └── run_s1s2hic_example.sh # Complete S1S2HiC workflow examples
```

## 🔧 Common Workflows

### Workflow 1: Data Quality Assessment
```bash
# Analyze sequence quality with pattern matching
python src/S1_Process_gen.py \
    -p "PRIMER1,PRIMER2" \
    -d "Quality Assessment" \
    -N all \
    --write-matching-reads
```

### Workflow 2: Data Preprocessing Pipeline
```bash
# Step 1: Split merged reads
python src/S2_Split.py \
    -i merged_reads.fastq.gz \
    -o split_data \
    --min-length 20

# Step 2: Quality analysis
python src/S1_Process_gen.py \
    -i "split_data/*_R1.fq.gz" \
    -p "QUALITY_MOTIF1,QUALITY_MOTIF2" \
    -d "Post-split QC"
```

### Workflow 3: Large-Scale Batch Processing
```bash
# High-performance processing of multiple files
./src/S3_process_sequences_count.sh \
    -p "TARGET_SEQ1,TARGET_SEQ2" \
    -i "data/*.gz" \
    -d "Batch Analysis" \
    -N 200000 \
    -j 16
```

### Workflow 4: Integrated S1→S2 Processing
```bash
# Streamlined S1 pattern matching → S2 splitting workflow
python src/S1S2_Pipeline.py \
    -p "ATCG,GCTA" \
    -d "Integrated Processing" \
    -N 100000 \
    --s1-output-dir "S1_Results" \
    --s2-output-dir "S2_Results"
```

### Workflow 5: Complete Hi-C Analysis Pipeline
```bash
# End-to-end S1→S2→HiC-Pro workflow for single-cell Hi-C
python src/S1S2HiC_Pipeline.py \
    -p "HI-C_MOTIF1,HI-C_MOTIF2" \
    -d "scHi-C Analysis" \
    --project-name "my_schic_project" \
    --hic-config 1 \
    --hic-cpu 16
```

## 📖 Documentation

### Quick References
- [🔍 **S1_Process_gen.py**](docs/README.md) - Detailed usage guide for pattern analysis
- [✂️ **S2_Split.py**](docs/README_S2_Split.md) - Complete splitting tool documentation
- [⚡ **S3_process_sequences_count.sh**](docs/README_process_sequences.md) - Batch processing advanced guide
- [📚 **Complete Toolkit Guide**](docs/README_Suite.md) - Comprehensive usage scenarios

### Getting Help
```bash
# Get help for any tool
python src/S1_Process_gen.py -h
python src/S2_Split.py -h
./src/S3_process_sequences_count.sh -h
```

## 🚀 Performance Optimization

### Hardware Recommendations
- **CPU**: Multi-core processor (8+ cores recommended)
- **Memory**: 8GB+ RAM (16GB+ for large datasets)
- **Storage**: SSD preferred for input/output operations

### Performance Tips
```bash
# 1. Optimize parallel processing
nproc  # Check available cores
./src/S3_process_sequences_count.sh -p "SEQ" -j $(nproc)

# 2. Use SSD storage for temporary files
export TMPDIR=/fast_storage/tmp

# 3. Process in chunks for memory efficiency
python src/S1_Process_gen.py -p "SEQ" -N 100000  # Limit lines processed
```

## 📊 Example Results

### Pattern Analysis Output
```
Sample          Description    Patterns              Forward_Matches  RC_Matches   Total_Reads  Forward_%  RC_%
sample1.fastq   Test Analysis  ATCGATCG,GCTAGCTA    1250            890          25000        5.00%      3.56%
sample2.fastq   Test Analysis  ATCGATCG,GCTAGCTA    1100            950          25000        4.40%      3.80%
```

### Splitting Statistics
```
=== Processing Complete ===
Total reads: 100,000
Successfully paired: 85,000
Discarded reads: 15,000
Pairing success rate: 85.00%

=== Orientation Statistics ===
Forward matches: 45,000
Reverse matches: 25,000
Mixed matches: 15,000
```

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for details.

### Development Setup
```bash
# Development environment setup
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Run tests
python -m pytest tests/  # If test suite available
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Version History

- **v1.0.0** (2025-05-28): Initial release
  - Complete toolkit with three main tools
  - Comprehensive documentation
  - Performance optimizations
  - Multi-platform support

## 🙋 Support

- **📚 Documentation**: Check the `docs/` directory for detailed guides
- **🐛 Issues**: Report bugs with detailed error messages and data characteristics
- **💡 Feature Requests**: Suggest improvements and new features
- **📧 Contact**: Reach out to the development team for support

## 🎯 Use Cases

- **🧬 Genomics Research**: Quality control and sequence analysis
- **🔬 Molecular Biology**: Primer/probe validation and design
- **📈 Bioinformatics**: High-throughput data processing pipelines
- **🏭 Production Environments**: Automated sequence processing workflows
- **🎓 Educational**: Teaching sequence analysis concepts

---

⭐ **如果您觉得这个仓库有用，请给它一个星标！**

**引用**: 如果您在研究中使用了这个工具包，请引用：[引用详情待添加]

# 中文版本

**[English](#sequence-processing-toolkit--序列处理工具包)** | 中文

一个综合性的高通量测序数据处理工具包，具备序列模式分析、FASTQ文件处理和批量处理功能。

## 🚀 主要功能

- **🔍 序列模式分析**：搜索和量化特定序列基序，支持正向和反向互补匹配
- **✂️ 智能FASTQ分割**：基于分隔符序列将FASTQ文件分割为配对的R1/R2 reads
- **⚡ 高性能批量处理**：并行处理多个压缩文件，性能优化
- **📊 全面统计分析**：生成详细报告，包含匹配百分比和质量指标
- **🧬 反向互补支持**：自动计算和匹配反向互补序列
- **📁 批量操作**：多核支持，同时处理数百个文件

## 📋 快速开始

### 系统要求

```bash
# 需要 Python 3.6+
python --version

# 标准Unix工具（通常已预装）
which gzip grep awk wc head sort tee
```

### 安装

```bash
# 克隆仓库
git clone https://github.com/thekingofall/sequence-processing-toolkit.git
cd sequence-processing-toolkit

# 设置脚本执行权限
chmod +x src/*.py src/*.sh
```

### 基本用法

```bash
# 1. 序列模式分析
python src/S1_Process_gen.py -p "ATCGATCG,GCTAGCTA" -d "模式分析"

# 2. FASTQ文件分割
python src/S2_Split.py -i input.fastq.gz -o output_dir

# 3. 批量处理
./src/S3_process_sequences_count.sh -p "序列1,序列2" -j 8
```

## 🛠️ 工具概览

| 工具 | 用途 | 适用场景 |
|------|------|----------|
| **S1_Process_gen.py** | 序列模式搜索与统计 | 质量控制、基序分析 |
| **S2_Split.py** | FASTQ文件分割与配对 | 数据预处理、条形码分离 |
| **S3_process_sequences_count.sh** | 高性能批量处理 | 大规模分析、生产流水线 |

## 📁 项目结构

```
sequence-processing-toolkit/
├── README.md                 # 主项目文档
├── src/                      # 源代码
│   ├── S1_Process_gen.py     # 模式分析工具
│   ├── S2_Split.py           # FASTQ分割工具
│   └── S3_process_sequences_count.sh  # 批量处理工具
├── docs/                     # 详细文档
│   ├── index.md              # 文档索引
│   ├── README.md             # S1工具文档
│   ├── README_S2_Split.md    # S2工具文档
│   ├── README_process_sequences.md  # S3工具文档
│   └── README_Suite.md       # 工具包综合指南
└── examples/                 # 使用示例和样本数据
    └── basic_usage.sh        # 基础使用示例
```

## 🔧 常用工作流程

### 工作流程1：数据质量评估
```bash
# 通过模式匹配分析序列质量
python src/S1_Process_gen.py \
    -p "引物1,引物2" \
    -d "质量评估" \
    -N all \
    --write-matching-reads
```

### 工作流程2：数据预处理流水线
```bash
# 步骤1：分割合并的reads
python src/S2_Split.py \
    -i merged_reads.fastq.gz \
    -o split_data \
    --min-length 20

# 步骤2：质量分析
python src/S1_Process_gen.py \
    -i "split_data/*_R1.fq.gz" \
    -p "质量基序1,质量基序2" \
    -d "分割后质控"
```

### 工作流程3：大规模批量处理
```bash
# 多文件高性能处理
./src/S3_process_sequences_count.sh \
    -p "目标序列1,目标序列2" \
    -i "data/*.gz" \
    -d "批量分析" \
    -N 200000 \
    -j 16
```

## 📖 文档

### 快速参考
- [🔍 **S1_Process_gen.py**](docs/README.md) - 模式分析详细使用指南
- [✂️ **S2_Split.py**](docs/README_S2_Split.md) - 分割工具完整文档
- [⚡ **S3_process_sequences_count.sh**](docs/README_process_sequences.md) - 批量处理高级指南
- [📚 **完整工具包指南**](docs/README_Suite.md) - 综合使用场景

### 获取帮助
```bash
# 获取各工具帮助信息
python src/S1_Process_gen.py -h
python src/S2_Split.py -h
./src/S3_process_sequences_count.sh -h
```

## 🚀 性能优化

### 硬件建议
- **CPU**：多核处理器（推荐8核以上）
- **内存**：8GB以上内存（大数据集需16GB以上）
- **存储**：SSD硬盘优先用于输入/输出操作

### 性能技巧
```bash
# 1. 优化并行处理
nproc  # 查看可用核心数
./src/S3_process_sequences_count.sh -p "序列" -j $(nproc)

# 2. 使用SSD存储临时文件
export TMPDIR=/fast_storage/tmp

# 3. 分块处理提高内存效率
python src/S1_Process_gen.py -p "序列" -N 100000  # 限制处理行数
```

## 📊 示例结果

### 模式分析输出
```
样本            描述       模式                    正向匹配数   反向匹配数   总reads数   正向%    反向%
sample1.fastq   测试分析   ATCGATCG,GCTAGCTA      1250        890         25000      5.00%   3.56%
sample2.fastq   测试分析   ATCGATCG,GCTAGCTA      1100        950         25000      4.40%   3.80%
```

### 分割统计
```
=== 处理完成 ===
总reads数: 100,000
成功配对: 85,000
丢弃reads: 15,000
配对成功率: 85.00%

=== 方向统计 ===
正向匹配: 45,000
反向匹配: 25,000
混合匹配: 15,000
```

## 🤝 贡献

我们欢迎贡献！请查看我们的贡献指南了解详情。

### 开发环境设置
```bash
# 开发环境设置
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# 运行测试
python -m pytest tests/  # 如果有测试套件
```

## 📝 许可证

本项目采用MIT许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🏷️ 版本历史

- **v1.0.0** (2025-05-28): 初始发布
  - 包含三个主要工具的完整工具包
  - 综合文档
  - 性能优化
  - 多平台支持

## 🙋 支持

- **📚 文档**：查看 `docs/` 目录获取详细指南
- **🐛 问题报告**：请提供详细的错误信息和数据特征
- **💡 功能建议**：欢迎提出改进建议和新功能
- **📧 联系**：联系开发团队获取支持

## 🎯 使用场景

- **🧬 基因组学研究**：质量控制和序列分析
- **🔬 分子生物学**：引物/探针验证和设计
- **📈 生物信息学**：高通量数据处理流水线
- **🏭 生产环境**：自动化序列处理工作流
- **🎓 教育**：序列分析概念教学

---

⭐ **如果您觉得这个仓库有用，请给它一个星标！**

**引用**: 如果您在研究中使用了这个工具包，请引用：[引用详情待添加]

一个用于处理DNA序列数据的综合工具包，特别适用于单细胞Hi-C (scHi-C) 分析流程。

## 🚀 功能特性

### 核心工具
- **S1_Process_gen.py**: 高性能序列模式筛选工具
- **S2_Split.py**: FASTQ文件智能分割工具
- **S1S2_Pipeline.py**: S1→S2整合流程
- **S1S2HiC_Pipeline.py**: 端到端分析流程（S1→S2→HiC-Pro）

### 新增HiC分析流程 (2024年6月)
- **schic_analysis_pipeline.sh**: 标准化的单细胞Hi-C分析流水线
- **完整标准化路径**: 所有依赖文件已迁移到 `/data1/Ref/hicpro/`
- **HiC-Pro-3.1.0**: 完整安装，包含所有配置和工具

## 📂 项目结构

```
sequence-processing-toolkit/
├── src/                          # 核心处理脚本
│   ├── S1_Process_gen.py         # 序列模式筛选
│   ├── S2_Split.py               # FASTQ分割
│   ├── S1S2_Pipeline.py          # S1S2整合流程
│   └── S1S2HiC_Pipeline.py       # 完整端到端流程
├── Scripts/                      # 分析流水线脚本
│   └── schic_analysis_pipeline.sh # 单细胞Hi-C分析流水线
├── examples/                     # 使用示例
│   ├── run_s1s2_example.sh       # S1S2流程示例
│   └── run_s1s2hic_example.sh    # 完整流程示例
├── README.md                     # 项目说明
└── HICPRO_SETUP.md              # HiC-Pro环境设置说明
```

## 🔧 标准化环境

所有HiC-Pro相关依赖已标准化到 `/data1/Ref/hicpro/`：

```
/data1/Ref/hicpro/
├── HiC-Pro-3.1.0/               # 完整HiC-Pro安装
├── configs/                     # 配置文件
├── genome/                      # 参考基因组
├── scripts/                     # 辅助脚本
└── tools/                       # 第三方工具
```

**优势**:
- ✅ 路径独立 - 不再依赖用户特定路径
- ✅ 完整安装 - HiC-Pro配置系统完整可用
- ✅ 易于维护 - 统一的标准化结构
- ✅ 高可移植性 - 可在不同环境中部署

## 🚀 快速开始

### 1. 基本S1S2流程
```bash
# S1序列筛选 → S2分割
python3 src/S1S2_Pipeline.py \
    -p "ATCG,GCTA" \
    -d "测试序列" \
    --sep1 "GATCATGTCGGAACTGTTGCTTGTCCGACTGATC" \
    --sep2 "AGATCGGAAGA"
```

### 2. 完整scHi-C流程  
```bash
# S1筛选 → S2分割 → HiC-Pro分析
python3 src/S1S2HiC_Pipeline.py \
    -p "ATCG,GCTA" \
    -d "scHi-C分析" \
    --project-name "my_schic_project" \
    --hic-config 1
```

### 3. 直接HiC分析
```bash
# 使用现有FASTQ文件进行HiC分析
./Scripts/schic_analysis_pipeline.sh \
    -p "my_project" \
    -i "input_fastq_dir" \
    -n 1  # 使用scCARE配置
```

## 📊 工作流程

### 端到端scHi-C分析流程:
```
原始FASTQ文件
    ↓ (S1_Process_gen.py)
筛选含目标序列的reads
    ↓ (S2_Split.py)  
分割为R1/R2配对文件
    ↓ (数据整理)
HiC-Pro标准输入格式
    ↓ (schic_analysis_pipeline.sh)
完整Hi-C分析结果
```

## 🛠️ 工具详情

### S1_Process_gen.py
- **功能**: 从FASTQ文件中筛选包含指定序列模式的reads
- **特性**: 并行处理、反向互补支持、灵活输出选项
- **输出**: 匹配的reads、统计报告

### S2_Split.py  
- **功能**: 根据分隔符序列将reads分割为R1/R2配对
- **特性**: 智能序列识别、质量保持、配对验证
- **输出**: 标准化的R1/R2 FASTQ文件

### S1S2HiC_Pipeline.py
- **功能**: 完整的端到端分析流程
- **包含**: S1筛选 + S2分割 + 数据整理 + HiC-Pro分析
- **输出**: 完整的Hi-C分析结果和交互矩阵

### schic_analysis_pipeline.sh
- **功能**: 标准化的单细胞Hi-C分析流水线
- **支持**: 多种配置、模块化执行、自动清理
- **输出**: Hi-C接触矩阵、质控报告、可视化文件

## 📋 配置选项

### HiC-Pro配置文件:
1. **scCARE.txt** - scCARE-seq专用配置
2. **SCCARE_INlaIIl.txt** - SCCARE InlaIII配置  
3. **hicpro_config.txt** - 通用配置

### 运行模块:
1. **模块1**: trim_galore质控和修剪
2. **模块2**: HiC-Pro核心分析  
3. **模块3**: Juicebox格式转换
4. **模块4**: 结果文件收集

## 🔍 验证安装

```bash
# 检查HiC-Pro
export PATH="/data1/Ref/hicpro/HiC-Pro-3.1.0/bin:$PATH"
HiC-Pro --version

# 测试工具
python3 src/S1_Process_gen.py --help
python3 src/S2_Split.py --help
./Scripts/schic_analysis_pipeline.sh -h
```

## 📝 注意事项

1. **环境要求**: Python 3.6+, bash, HiC-Pro依赖包
2. **内存需求**: 根据数据量调整，建议16GB+
3. **存储空间**: Hi-C分析需要大量临时存储空间
4. **权限设置**: 确保对 `/data1/Ref/hicpro/` 有读取权限

## 🆕 最新更新 (2024年6月24日)

### ✅ 路径标准化完成
- **HiC-Pro完整安装**: 复制完整的HiC-Pro-3.1.0目录，确保配置系统正常工作
- **路径更新**: 所有脚本中的路径已更新到标准化位置
- **功能验证**: HiC-Pro现在可以正常运行，解决了"config system not detected"错误
- **文档更新**: HICPRO_SETUP.md已更新，反映正确的目录结构

### 🔧 路径变量化优化
- **变量化设计**: 引入 `HICPRO_BASE_DIR` 变量统一管理所有路径
- **易于维护**: 只需修改一个变量即可更改所有相关路径
- **提高可移植性**: 轻松适配不同环境的目录结构
- **简化配置**: 统一管理避免重复硬编码路径

### 📍 标准化路径映射
| 组件 | 新标准化路径 |
|------|-------------|
| 基础路径变量 | `HICPRO_BASE_DIR="/data1/Ref/hicpro"` |
| HiC-Pro主程序 | `${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/HiC-Pro` |
| Juicebox转换 | `${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/utils/hicpro2juicebox.sh` |
| 辅助脚本 | `${HICPRO_BASE_DIR}/scripts/` |
| 配置文件 | `${HICPRO_BASE_DIR}/configs/` |
| 基因组文件 | `${HICPRO_BASE_DIR}/genome/` |
| 第三方工具 | `${HICPRO_BASE_DIR}/tools/` |

**路径迁移示例**:
```bash
# 如需更改安装位置，只需修改一个变量
HICPRO_BASE_DIR="/your/custom/path"
```

现在整个流程已经完全标准化、变量化并可以正常工作！

## 📧 支持

如有问题或建议，请查看相关文档或联系开发团队。

---
**sequence-processing-toolkit** - 让序列处理和scHi-C分析更简单！ 