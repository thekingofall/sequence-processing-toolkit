# 第二章：S1S2HiC系统详解

> 🧬 专为生物信息学Hi-C数据分析设计的一键式处理工具

## 2.1 系统概述

S1S2HiC系统专门为处理Hi-C数据设计，集成了完整的分析流程：
- **S1步骤**: 序列筛选和统计
- **S2步骤**: 酶切分割  
- **HiC步骤**: HiC-Pro分析
- **结果整理**: 自动生成报告

## 2.2 预设实验组详解

### Group1: MboI+GATC+SeqA
- **酶切类型**: MboI, 识别序列GATC
- **样本数**: 3个样本，6个文件
- **适用场景**: 标准MboI酶切实验，数据量较大
- **处理时间**: 约2-4小时

### Group2: MboI+GATC+SeqB  
- **酶切类型**: MboI, 识别序列GATC
- **样本数**: 1个样本，2个文件
- **适用场景**: MboI酶切对照组，快速测试
- **处理时间**: 约30-60分钟（最快）

### Group3: MseI+CviQI+TA+SeqA
- **酶切类型**: MseI+CviQI双酶切，识别序列TA
- **样本数**: 3个样本，6个文件  
- **适用场景**: 双酶切实验，提高分辨率
- **处理时间**: 约3-5小时

### Group4: MseI+CviQI+TA+SeqB
- **酶切类型**: MseI+CviQI双酶切，识别序列TA
- **样本数**: 1个样本，2个文件
- **适用场景**: 双酶切对照组
- **处理时间**: 约1-2小时

### Group5: MboI+CviQI+GATC+TA+SeqA
- **酶切类型**: MboI+CviQI多酶切，识别序列GATC+TA
- **样本数**: 1个样本，2个文件
- **适用场景**: 多酶切实验，最高分辨率
- **处理时间**: 约1-2小时

## 2.3 配置文件详解

### 基本配置参数

```bash
# 项目名称（必填）
PROJECT_NAME=my_s1s2hic_experiment_20250126

# 要处理的组（必填） 
GROUPS=1,2,3,4,5

# 数据根目录（必填）
DATA_ROOT=/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups
```

### 可选参数

```bash
# 最大并行任务数（默认自动检测CPU核心数）
MAX_PARALLEL=3

# 输出根目录（默认在各组工作目录）
OUTPUT_ROOT=/path/to/output

# 邮件通知
EMAIL_NOTIFY=your@email.com

# 清理选项（成功后是否清理中间文件）
CLEANUP_TEMP=false

# 重试次数
RETRY_COUNT=1
```

## 2.4 数据目录结构要求

```
DATA_ROOT/
├── Group1_MboI_GATC_SeqA/
│   ├── sample1_R1.fastq.gz
│   ├── sample1_R2.fastq.gz
│   ├── sample2_R1.fastq.gz
│   ├── sample2_R2.fastq.gz
│   ├── sample3_R1.fastq.gz
│   └── sample3_R2.fastq.gz
├── Group2_MboI_GATC_SeqB/
│   ├── sample1_R1.fastq.gz
│   └── sample1_R2.fastq.gz
└── ...
```

## 2.5 工作流程详解

### 阶段1: S1序列筛选
- 根据接头序列筛选有效reads
- 生成统计报告
- 输出: `CountFold/` 目录

### 阶段2: S2酶切分割
- 根据酶切位点分割序列
- 准备HiC-Pro输入
- 输出: `Group*_S2_Enzyme_Split/` 目录

### 阶段3: HiC-Pro分析
- 序列比对
- 接触矩阵生成
- 质量控制
- 输出: `Run3_hic/` 目录

### 阶段4: 结果整理
- 汇总所有结果
- 生成完整报告
- 输出: `S1S2HiC_Complete_Report_*.txt`

## 2.6 结果文件说明

### 主要输出文件

```
工作目录/
├── CountFold/                           # S1统计结果
│   ├── *.tsv                           # 统计表格
│   └── *.log                           # 统计日志
├── Group*_S1_Linker_Separated/         # S1输出
├── Group*_S2_Enzyme_Split/             # S2输出 
├── Group*_HiC_Input/                   # HiC输入文件
├── Run3_hic/                           # HiC-Pro结果
│   ├── hic_results/                    # 接触矩阵
│   ├── bowtie_results/                 # 比对结果
│   └── stats/                          # 统计信息
└── S1S2HiC_Complete_Report_*.txt       # 完整报告
```

### 日志文件

```
auto_logs/
├── auto_run_PROJECT_NAME_*.log         # 主日志
├── summary_PROJECT_NAME_*.txt          # 结果摘要
└── error_*.log                         # 错误日志
```

## 2.7 性能优化建议

### 并行任务数设置
- **保守设置**: CPU核心数的50% 
- **标准设置**: CPU核心数的70%
- **激进设置**: CPU核心数的90%

### 存储空间要求
- **临时空间**: 原始数据大小的3-5倍
- **结果空间**: 原始数据大小的1-2倍
- **建议**: SSD存储提升I/O性能

### 内存要求
- **最低要求**: 8GB
- **推荐配置**: 16GB+
- **大型数据**: 32GB+

## 2.8 常见使用场景

### 场景1: 快速验证流程
```bash
# 只测试Group2（最快）
PROJECT_NAME=test_run
GROUPS=2
./run_s1s2hic_auto.sh configs/templates/simple_config.conf
```

### 场景2: 标准分析流程
```bash
# 处理所有组
PROJECT_NAME=full_analysis_$(date +%Y%m%d)
GROUPS=1,2,3,4,5
./run_s1s2hic_auto.sh configs/templates/simple_config.conf
```

### 场景3: 特定实验类型
```bash
# 只处理MboI酶切实验
PROJECT_NAME=mboi_experiment
GROUPS=1,2
./run_s1s2hic_auto.sh configs/templates/simple_config.conf
``` 