# 🚀 S1S2HiC流程 - 快速开始

## 30秒快速开始 - 配置文件模式（推荐）

```bash
# 1. 进入src目录
cd sequence-processing-toolkit/src/

# 2. 生成配置文件模板
python S1S2HiC_Pipeline.py --generate-config my_config.yaml

# 3. 编辑配置文件（修改patterns为你的序列）
nano my_config.yaml

# 4. 运行完整Hi-C处理流程
python S1S2HiC_Pipeline.py -c my_config.yaml
```

## ⚡ 流程说明

这个脚本会自动完成：
1. **S1筛选** → 从原始文件中筛选包含指定序列的reads
2. **S2分割** → 将reads按分隔符分割为R1/R2配对文件  
3. **数据整理** → 整理为HiC-Pro输入格式
4. **HiC分析** → 执行完整的Hi-C数据分析

## 📝 配置文件快速设置

### 基本配置示例
```yaml
# my_config.yaml
S1_config:
  patterns: "ATCGATCG,GCTAGCTA"    # 修改为你的序列
  description: "我的HiC项目"
  jobs: 8
  output_dir: "S1_Matched"

S2_config:
  output_dir: "S2_Split"

HiC_config:
  input_dir: "HiC_Input"
  project_name: "MyProject_20240701"
  cpu_count: 16

workflow_control:
  skip_s1: false
  skip_s2: false  
  skip_hic: false
```

## 🔧 常用场景

### 完整流程
```bash
python S1S2HiC_Pipeline.py -c my_config.yaml
```

### 只做数据预处理
```yaml
# config_preprocess.yaml
workflow_control:
  skip_hic: true  # 跳过HiC分析
```

### 大数据处理
```yaml
# config_bigdata.yaml  
S1_config:
  lines_to_process: "all"  # 处理所有数据
  jobs: 16                 # 更多并行任务

HiC_config:
  cpu_count: 32           # 更多CPU
```

### 分步执行
```bash
# 第1步：只运行S1
# 修改配置文件: skip_s2: true, skip_hic: true
python S1S2HiC_Pipeline.py -c step1_config.yaml

# 第2步：从S2开始
# 修改配置文件: skip_s1: true, skip_hic: true  
python S1S2HiC_Pipeline.py -c step2_config.yaml

# 第3步：只运行HiC
# 修改配置文件: skip_s1: true, skip_s2: true
python S1S2HiC_Pipeline.py -c step3_config.yaml
```

## 📊 输出结果

```
当前目录/
├── S1_Matched/          # S1筛选结果
├── S2_Split/            # S2分割结果  
├── HiC_Input/           # HiC输入数据
├── Run3_hic/            # HiC分析结果
└── S1S2HiC_Complete_Report_*.txt  # 处理报告
```

## 🆘 遇到问题？

### 配置文件问题
```bash
# 重新生成配置文件模板
python S1S2HiC_Pipeline.py --generate-config new_config.yaml

# 检查YAML语法
python -c "import yaml; yaml.safe_load(open('my_config.yaml'))"
```

### 常见错误
```bash
# 查看帮助
python S1S2HiC_Pipeline.py --help

# 检查依赖脚本
ls S1_Process_gen.py S2_Split.py
ls ../Scripts/schic_analysis_pipeline.sh

# 安装PyYAML（如果缺少）
pip install pyyaml
```

### 分步调试
```bash
# 只运行S1步骤测试
# 在配置文件中设置: skip_s2: true, skip_hic: true
python S1S2HiC_Pipeline.py -c debug_config.yaml
```

## 🎯 快速上手技巧

1. **首次使用**：直接使用模板，只修改`patterns`
2. **大数据**：设置`lines_to_process: "all"`和更多`jobs`
3. **测试运行**：先设置`lines_to_process: 10000`快速测试
4. **出错重试**：使用`skip_*`参数跳过已完成的步骤
5. **参数覆盖**：可用命令行参数覆盖配置文件设置

## 🔄 命令行模式（兼容）

如果不想用配置文件，仍可使用命令行：

```bash
# 最简单的命令行模式
python S1S2HiC_Pipeline.py -p "ATCGATCG,GCTAGCTA" -d "我的项目"
```

## 📖 详细文档

查看完整文档：[README_S1S2HiC_Pipeline.md](./README_S1S2HiC_Pipeline.md)

---
*配置文件让Hi-C数据处理更简单！* 🎉 