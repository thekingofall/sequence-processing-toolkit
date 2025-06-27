# 🚀 快速使用指南

## 📋 .bashrc 快捷命令列表

现在您可以在任何目录下使用以下快捷命令：

### 🔧 基本命令

| 命令 | 功能 | 示例 |
|------|------|------|
| `hicpro-help` | 显示完整帮助信息 | `hicpro-help` |
| `hicpro-run` | 显示使用指南和配置选项 | `hicpro-run` |

### 🧬 酶切特异性命令

| 命令 | 酶切类型 | 配置文件 | 示例用法 |
|------|----------|----------|----------|
| `hicpro-mboi` | MboI (GATC) | scCARE_MboI.txt | `hicpro-mboi -p "project1" -i "fastq_dir"` |
| `hicpro-nlaiii` | NlaIII (CATG) | hicpro_NlaIII.txt | `hicpro-nlaiii -p "project2" -i "fastq_dir"` |
| `hicpro-std` | 标准MboI | hicpro_MboI.txt | `hicpro-std -p "project3" -i "fastq_dir"` |

### 🛠️ 通用命令

| 命令 | 功能 | 示例 |
|------|------|------|
| `hicpro` | 直接调用主脚本 | `hicpro -n 2 -p "myproject" -i "input_dir"` |
| `s1s2` | S1→S2流程 | `s1s2 -p "ATCG,GCTA" -d "test"` |
| `s1s2hic` | 完整S1→S2→HiC流程 | `s1s2hic -p "ATCG,GCTA" --project-name "test"` |

## 📖 使用示例

### 1. 快速开始 - scCARE-seq分析
```bash
# 切换到包含FASTQ文件的目录
cd /path/to/your/data

# 运行scCARE-seq分析（MboI酶）
hicpro-mboi -p "scCARE_experiment_20241224" -i "Run1_fastq"
```

### 2. NlaIII酶切实验
```bash
# NlaIII酶切分析
hicpro-nlaiii -p "NlaIII_experiment" -i "input_fastq" -u 20
```

### 3. 自定义模块运行
```bash
# 只运行HiC-Pro分析和转换步骤（跳过trim）
hicpro -n 1 -p "custom_run" -i "trimmed_data" -m "2,3"
```

### 4. 完整端到端分析
```bash
# 从序列筛选到Hi-C分析的完整流程
s1s2hic -p "ATCG,GCTA" -d "my_analysis" --project-name "full_pipeline"
```

## ⚙️ 配置选项说明

### 配置文件选择 (-n 参数)
- **-n 1**: `scCARE_MboI.txt` - scCARE-seq专用 (MboI/GATC)
- **-n 2**: `hicpro_NlaIII.txt` - NlaIII酶切 (NlaIII/CATG)
- **-n 3**: `hicpro_MboI.txt` - 标准MboI (MboI/GATC)

### 常用参数
- **-p**: 项目名称
- **-i**: 输入FASTQ目录
- **-o**: 输出目录（默认: Run3_hic）
- **-u**: CPU核心数（默认: 10）
- **-m**: 模块选择（默认: "1,2,3"）
  - 1: trim_galore质控
  - 2: HiC-Pro核心分析
  - 3: Juicebox转换

## 🔍 故障排除

### 查看帮助
```bash
# 显示详细使用说明
hicpro-run

# 查看完整参数列表
hicpro-help
```

### 常见问题

1. **"command not found"错误**
   ```bash
   # 重新加载.bashrc
   source ~/.bashrc
   ```

2. **权限错误**
   ```bash
   # 检查脚本权限
   ls -la $(which schic_analysis_pipeline.sh)
   ```

3. **路径错误**
   ```bash
   # 检查PATH设置
   echo $PATH | grep sequence-processing-toolkit
   ```

## 📁 重要路径

- **工具包位置**: `/data1/maolp/Biosoft/Myscript/sequence-processing-toolkit/`
- **配置文件**: `/data1/Ref/hicpro/configs/`
- **基因组文件**: `/data1/Ref/hicpro/genome/`
- **HiC-Pro安装**: `/data1/Ref/hicpro/HiC-Pro-3.1.0/`

## 🎯 最佳实践

1. **数据组织**: 将FASTQ文件放在专门的输入目录中
2. **项目命名**: 使用描述性的项目名称，包含日期
3. **资源配置**: 根据数据大小调整CPU数量(-u参数)
4. **模块化运行**: 大数据集可分步骤运行以节省时间

现在您可以在任何位置快速启动Hi-C分析了！🎉 