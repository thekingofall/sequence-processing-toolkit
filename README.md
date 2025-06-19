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

## 📁 Project Structure

```
sequence-processing-toolkit/
├── README.md                 # Main project documentation
├── src/                      # Source code
│   ├── S1_Process_gen.py     # Pattern analysis tool
│   ├── S2_Split.py           # FASTQ splitting tool
│   └── S3_process_sequences_count.sh  # Batch processing tool
├── docs/                     # Detailed documentation
│   ├── index.md              # Documentation index
│   ├── README.md             # S1 tool documentation
│   ├── README_S2_Split.md    # S2 tool documentation
│   ├── README_process_sequences.md  # S3 tool documentation
│   └── README_Suite.md       # Comprehensive toolkit guide
└── examples/                 # Usage examples and sample data
    └── basic_usage.sh        # Basic usage examples
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