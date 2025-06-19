## shell 脚本
```
bash process_sequences_countv20250528.sh -p   "GATCAGTCGGACAAGCAACAGTTCCGACATGATC,AGATCGGAAGA"  -N 1000000000
```
## 分离计数和生成脚本
```
python3 Process_gen.py -p 序列 -N 1000000000 --write-matching-reads
这个文件夹下面的gz文件
```

```
python Split.py  --sep1  序列  -i fastq.R1.gz
```

# S1_Process_gen.py 使用说明

## 简介

`S1_Process_gen.py` 是一个用于处理FASTQ序列文件的Python脚本，专门用于搜索和统计指定序列模式（及其反向互补序列）在测序数据中的出现情况。该脚本支持并行处理，可以高效处理大量的gzip压缩FASTQ文件。

## 主要功能

- 🔍 **序列模式搜索**：支持搜索多个序列模式的共现情况
- 🧬 **反向互补匹配**：自动计算并搜索反向互补序列
- ⚡ **并行处理**：支持多核并行处理，提高处理效率
- 📊 **统计分析**：输出详细的匹配统计信息（TSV格式）
- 💾 **FASTQ输出**：可选择输出匹配和未匹配的FASTQ记录
- 🗜️ **压缩文件支持**：直接处理gzip压缩的FASTQ文件

## 系统要求

### Python版本
- Python 3.6 或更高版本

### 依赖库
```bash
# 所有依赖库都是Python标准库，无需额外安装
- argparse
- gzip
- glob
- os
- sys
- datetime
- concurrent.futures
- pathlib
- shutil
```

## 安装

```bash
# 克隆或下载脚本文件
# 确保脚本具有执行权限
chmod +x S1_Process_gen.py
```

## 使用方法

### 基本语法
```bash
python ../src/S1_Process_gen.py -p "序列1,序列2,..." [其他选项]
```

### 参数说明

#### 必需参数
- `-p, --patterns`：**必需**，逗号分隔的搜索序列列表

#### 可选参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `-d, --description` | "未说明序列名字" | 序列组合的描述性名称 |
| `-i, --input-pattern` | "*gz" | 输入文件的匹配模式 |
| `-o, --output-file` | 自动生成 | TSV结果文件的路径 |
| `-N, --lines` | 100000 | 每个文件处理的行数（"all"表示全部） |
| `-j, --jobs` | CPU核心数 | 并行处理的任务数 |
| `--write-matching-reads` | False | 是否输出匹配的FASTQ记录 |
| `--fastq-output-dir` | "Outfastq" | 匹配FASTQ记录的输出目录 |
| `--write-unmatched-reads` | False | 是否输出未匹配的FASTQ记录 |

## 使用示例

### 基础使用
```bash
# 搜索两个序列模式的共现
python S1_Process_gen.py -p "ATCGATCG,GCTAGCTA" -d "测试序列组合"
```

### 高级使用
```bash
# 处理所有行，使用8个并行任务，输出匹配的FASTQ记录
python S1_Process_gen.py \
    -p "ATCGATCG,GCTAGCTA,TTAATTAA" \
    -d "三序列组合分析" \
    -N all \
    -j 8 \
    --write-matching-reads \
    --fastq-output-dir "matched_sequences" \
    --write-unmatched-reads
```

### 指定输入文件模式
```bash
# 只处理特定模式的文件
python S1_Process_gen.py \
    -p "ATCGATCG,GCTAGCTA" \
    -i "sample_*.fastq.gz" \
    -o "custom_results.tsv"
```

## 输出说明

### TSV统计文件
脚本会生成包含以下列的TSV文件：

| 列名 | 说明 |
|------|------|
| 样本 | 输入文件名（去除扩展名） |
| 序列描述 | 用户提供的序列描述 |
| 查询序列组合 | 搜索的序列模式 |
| 全正向匹配Reads数 | 包含所有正向序列的reads数量 |
| 全反向互补匹配Reads数 | 包含所有反向互补序列的reads数量 |
| 总处理Reads数 | 处理的总reads数量 |
| 全正向匹配比例(%) | 正向匹配的百分比 |
| 全反向互补匹配比例(%) | 反向互补匹配的百分比 |

### 目录结构
```
工作目录/
├── CountFold/                    # TSV统计文件目录
│   └── YYYYMMDD_HHMMSS_序列摘要_m行数.tsv
├── Outfastq/                     # 匹配的FASTQ文件目录（可选）
│   ├── sample1.fastq.gz
│   ├── sample2.fastq.gz
│   └── Unmap/                    # 未匹配的FASTQ文件子目录
│       ├── sample1.fastq.gz
│       └── sample2.fastq.gz
└── 输入的FASTQ文件
```

## 工作原理

1. **序列预处理**：将输入序列转换为大写，计算反向互补序列
2. **文件扫描**：读取指定数量的行或全部内容
3. **模式匹配**：检查每个read的序列是否包含所有指定的正向模式或反向互补模式
4. **统计计算**：计算匹配的reads数量和比例
5. **结果输出**：生成TSV统计文件和可选的FASTQ文件

## 性能优化建议

- 使用 `-j` 参数设置合适的并行任务数（通常设为CPU核心数）
- 对于大文件，考虑使用 `-N` 参数限制处理的行数进行快速测试
- 将输入文件放在SSD硬盘上以提高I/O性能

## 注意事项

⚠️ **重要提醒**：
- 序列匹配是**大小写不敏感**的（脚本内部会转换为大写）
- 只有当reads包含**所有**指定的序列模式时才算匹配
- 一个read可能同时匹配正向和反向互补模式（会分别计数）
- 使用 `--write-unmatched-reads` 时必须同时设置 `--write-matching-reads`

## 故障排除

### 常见问题

1. **内存不足**：
   - 减少并行任务数 (`-j`)
   - 限制处理行数 (`-N`)

2. **文件权限错误**：
   - 确保对输入文件有读权限
   - 确保对输出目录有写权限

3. **没有找到匹配文件**：
   - 检查 `-i` 参数的文件模式
   - 确认文件路径正确

## 版本信息

- 脚本版本：v20250528
- 编码：UTF-8
- 兼容性：Linux/macOS/Windows

## 联系方式

如有问题或建议，请联系开发团队。
