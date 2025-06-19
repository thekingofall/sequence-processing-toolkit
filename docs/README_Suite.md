# Process_Seq_script_v20250528 脚本套件使用说明

## 概述

本脚本套件包含三个专业的序列处理工具，用于高通量测序数据的分析和处理。每个脚本都有特定的功能，可以单独使用或组合使用以完成复杂的序列处理任务。

## 脚本组成

### 🐍 S1_Process_gen.py
**Python脚本 - 序列模式搜索和统计**

- **主要功能**：在FASTQ文件中搜索指定序列模式，支持正向和反向互补匹配
- **核心特性**：并行处理、详细统计、FASTQ输出
- **适用场景**：序列质控、模式分析、特征统计

```bash
# 基本用法
python S1_Process_gen.py -p "ATCGATCG,GCTAGCTA" -d "测试序列"
```

### ✂️ S2_Split.py  
**Python脚本 - FASTQ文件智能分割**

- **主要功能**：根据分隔符序列将FASTQ文件分割为配对的R1和R2文件
- **核心特性**：多方向匹配、配对保证、质量过滤
- **适用场景**：双端数据重组、条形码分离、接头去除

```bash
# 基本用法
python S2_Split.py -i input.fastq.gz -o output_dir
```

### 🚀 S3_process_sequences_count.sh
**Bash脚本 - 高性能批量序列统计**

- **主要功能**：批量处理多个压缩文件，进行序列共现统计
- **核心特性**：并行处理、批量分析、实时输出
- **适用场景**：大规模数据处理、批量质控、高性能计算

```bash
# 基本用法
./S3_process_sequences_count.sh -p "ATCGATCG,GCTAGCTA" -j 8
```

## 快速开始

### 1. 环境准备
```bash
# 确保Python 3.6+可用
python --version

# 给脚本执行权限
chmod +x S1_Process_gen.py S2_Split.py S3_process_sequences_count.sh
```

### 2. 基础工作流程

#### 场景1：序列质量评估
```bash
# 使用S1进行详细的序列分析
python S1_Process_gen.py \
    -p "ATCGATCG,GCTAGCTA" \
    -d "质量评估" \
    -N all \
    --write-matching-reads
```

#### 场景2：数据预处理
```bash
# 使用S2分割原始数据
python S2_Split.py \
    -i merged_reads.fastq.gz \
    -o processed_data \
    --min-length 20

# 然后进行质量统计
python S1_Process_gen.py \
    -i "processed_data/*_R1.fq.gz" \
    -p "PRIMER1,PRIMER2" \
    -d "预处理后评估"
```

#### 场景3：批量高性能处理
```bash
# 使用S3进行大规模批量处理
./S3_process_sequences_count.sh \
    -p "ATCGATCG,GCTAGCTA,TTAATTAA" \
    -d "批量质控分析" \
    -i "data/*.gz" \
    -N 200000 \
    -j 16
```

## 详细文档

每个脚本都有对应的详细文档：

| 脚本 | 文档文件 | 说明 |
|------|----------|------|
| S1_Process_gen.py | [README.md](README.md) | 详细的Python脚本使用指南 |
| S2_Split.py | [README_S2_Split.md](README_S2_Split.md) | 分割工具完整说明 |
| S3_process_sequences_count.sh | [README_process_sequences.md](README_process_sequences.md) | Bash脚本高级用法 |

## 工作流程建议

### 典型的数据处理流程

```
原始数据 → S2分割 → S1质控分析 → S3批量统计 → 结果报告
    ↓        ↓         ↓           ↓         ↓
  .fastq.gz  R1/R2   质量评估    批量分析   最终结果
```

### 1. 数据预处理阶段
```bash
# 步骤1：分割原始数据
for file in raw_data/*.fastq.gz; do
    python S2_Split.py -i "$file" -o "split_$(basename $file .fastq.gz)"
done
```

### 2. 质量控制阶段
```bash
# 步骤2：质量评估
python S1_Process_gen.py \
    -p "QUALITY_MOTIF1,QUALITY_MOTIF2" \
    -i "split_*/*_R1.fq.gz" \
    -d "R1质量评估" \
    --write-matching-reads
```

### 3. 批量分析阶段
```bash
# 步骤3：批量统计分析
./S3_process_sequences_count.sh \
    -p "TARGET_SEQ1,TARGET_SEQ2" \
    -i "split_*/*_R2.fq.gz" \
    -d "R2批量分析" \
    -j 8
```

## 性能对比

| 脚本 | 处理速度 | 内存使用 | 适用数据量 | 主要优势 |
|------|----------|----------|------------|----------|
| S1_Process_gen.py | 中等 | 中等 | 中型数据集 | 功能全面、输出详细 |
| S2_Split.py | 快速 | 较低 | 各种规模 | 专业分割、配对精确 |
| S3_process_sequences_count.sh | 很快 | 很低 | 大型数据集 | 高性能、批量处理 |

## 最佳实践

### 🎯 选择合适的工具

1. **小规模探索性分析** → 使用 S1_Process_gen.py
2. **数据预处理和分割** → 使用 S2_Split.py  
3. **大规模生产环境** → 使用 S3_process_sequences_count.sh

### ⚡ 性能优化

```bash
# 1. 利用SSD存储
export TMPDIR=/fast_storage/tmp

# 2. 合理设置并行任务数
# CPU核心数的80-90%是较好的选择
nproc  # 查看核心数
./S3_process_sequences_count.sh -p "SEQ" -j 12  # 如果有16核

# 3. 内存监控
# 大文件处理时限制处理行数
python S1_Process_gen.py -p "SEQ" -N 100000  # 限制行数
```

### 🔧 故障排除流程

1. **先用小数据测试**
```bash
# 用头1000行测试
head -4000 large_file.fastq | gzip > test_small.fastq.gz
python S1_Process_gen.py -p "TEST_SEQ" -i "test_small.fastq.gz"
```

2. **检查序列方向**
```bash
# 测试正向和反向互补
python S1_Process_gen.py -p "ATCG" -N 1000  # 观察统计结果
```

3. **逐步增加复杂度**
```bash
# 从单序列到多序列
python S1_Process_gen.py -p "SEQ1"        # 先测试单个
python S1_Process_gen.py -p "SEQ1,SEQ2"   # 再测试组合
```

## 常见问题 FAQ

### Q1: 三个脚本有什么区别？
**A**: S1专注功能全面性，S2专注数据分割，S3专注高性能批量处理。根据需求选择。

### Q2: 可以组合使用吗？
**A**: 完全可以！典型流程是：S2分割 → S1分析 → S3批量统计。

### Q3: 性能瓶颈在哪里？
**A**: 主要是I/O瓶颈。使用SSD、优化并行参数可显著提升性能。

### Q4: 如何处理超大文件？
**A**: 推荐使用S3脚本，配合合理的行数限制和并行设置。

### Q5: 序列匹配是否区分大小写？
**A**: 不区分。所有脚本都会自动转换为大写进行匹配。

## 更新日志

- **v20250528**: 当前版本
  - 重构文件命名规范（S1、S2、S3前缀）
  - 优化性能和内存使用
  - 增强错误处理和用户体验
  - 完善文档和示例

## 支持与反馈

- 📚 **文档**: 查看各脚本的详细README文件
- 🐛 **问题报告**: 请提供具体的错误信息和数据特征
- 💡 **功能建议**: 欢迎提出改进建议

## 许可证

本脚本套件遵循开源许可证，可自由使用和修改。

---

🌟 **提示**: 建议先阅读各脚本的详细文档，然后在小数据集上测试，确认配置正确后再进行大规模处理。 