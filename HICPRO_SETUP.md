# HiC-Pro 环境设置说明

## 🔧 路径变量化设计

为了提高脚本的可维护性和可移植性，所有脚本使用统一的基础路径变量：

```bash
# 标准化基础路径 - 可根据需要修改
HICPRO_BASE_DIR="/data1/Ref/hicpro"
```

**变量化优势**:
- 🔄 **易于修改**: 只需修改一个变量即可更改所有相关路径
- 🚀 **提高可移植性**: 轻松适配不同环境的目录结构
- 🛠️ **简化维护**: 统一管理所有路径配置
- 📁 **灵活部署**: 支持自定义安装位置

## 📂 标准化目录结构

所有HiC-Pro相关依赖已标准化到 `${HICPRO_BASE_DIR}` (默认: `/data1/Ref/hicpro/`)：

```
${HICPRO_BASE_DIR}/                 # 可通过变量修改的基础路径
├── HiC-Pro-3.1.0/               # 完整的HiC-Pro安装目录
│   ├── bin/                     # 可执行文件
│   │   ├── HiC-Pro              # 主程序
│   │   └── utils/               # 工具脚本
│   │       ├── digest_genome.py
│   │       ├── extract_snps.py
│   │       ├── hicpro2fithic.py
│   │       ├── hicpro2higlass.sh
│   │       ├── hicpro2juicebox.sh
│   │       ├── make_viewpoints.py
│   │       ├── sparseToDense.py
│   │       ├── split_reads.py
│   │       └── split_sparse.py
│   ├── scripts/                 # HiC-Pro内部脚本
│   ├── config-hicpro.txt        # 示例配置文件
│   ├── config-install.txt       # 安装配置
│   ├── config-system.txt        # 系统配置
│   └── ...                      # 其他安装文件
├── configs/                     # 自定义配置文件（按酶切位点命名）
│   ├── scCARE_MboI.txt          # 配置1: scCARE (MboI/GATC)
│   ├── hicpro_NlaIII.txt        # 配置2: NlaIII酶 (CATG)
│   └── hicpro_MboI.txt          # 配置3: MboI酶 (GATC)
├── genome/                      # 基因组参考文件
│   ├── hg19.sizes               # 基因组大小文件
│   └── HG19mboi.bed             # 限制性酶切位点
├── scripts/                     # 辅助脚本
│   ├── SentEmail.py             # 邮件发送脚本
│   └── hicpro_summary_trans.pl  # 结果摘要脚本
└── tools/                       # 第三方工具
    └── juicer_tools_1.22.01.jar # Juicer Tools
```

## 🔧 脚本更新

### 重命名的脚本
- **原名**: `run_hicpro_pipeline.sh`
- **新名**: `schic_analysis_pipeline.sh`
- **位置**: `sequence-processing-toolkit/Scripts/schic_analysis_pipeline.sh`

### 路径标准化
所有原本依赖 `/home/maolp/` 的路径已更新为基于变量的标准化路径：

| 组件 | 原路径 | 新路径 |
|------|-------|--------|
| HiC-Pro 主程序 | `/home/maolp/mao/Biosoft/HiC-Pro-3.1.0/bin/HiC-Pro` | `${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/HiC-Pro` |
| 邮件脚本 | `/home/maolp/mao/Codeman/All_Archived_Project/SentEmail.py` | `${HICPRO_BASE_DIR}/scripts/SentEmail.py` |
| 摘要脚本 | `/home/maolp/mao/Codeman/Project/DIPC/scCARE-seq/Processing_Hi-C/hicpro_summary_trans.pl` | `${HICPRO_BASE_DIR}/scripts/hicpro_summary_trans.pl` |
| Juicebox转换 | `/home/maolp/mao/Biosoft/HiC-Pro-3.1.0/bin/utils/hicpro2juicebox.sh` | `${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/utils/hicpro2juicebox.sh` |
| Juicer Tools | `/home/maolp/mao/Biosoft/juicer_tools_1.22.01.jar` | `${HICPRO_BASE_DIR}/tools/juicer_tools_1.22.01.jar` |
| 基因组大小 | `/home/maolp/mao/Ref/AllnewstarRef/Homo/HG19/hg19.sizes` | `${HICPRO_BASE_DIR}/genome/hg19.sizes` |
| 酶切位点 | `/home/maolp/mao/Ref/AllnewstarRef/Homo/HG19/HG19mboi.bed` | `${HICPRO_BASE_DIR}/genome/HG19mboi.bed` |
| 配置文件1 | `/home/maolp/mao/Codeman/Project/DIPC/scCARE.txt` | `${HICPRO_BASE_DIR}/configs/scCARE.txt` |
| 配置文件2 | `/home/maolp/mao/Codeman/Project/DIPC/SCCARE_INlaIIl.txt` | `${HICPRO_BASE_DIR}/configs/SCCARE_INlaIIl.txt` |
| 配置文件3 | `/home/maolp/data3/All_ZengXi_data5/T7-HiC/hicpro_config_no.txt` | `${HICPRO_BASE_DIR}/configs/hicpro_config.txt` |

## 🚀 使用方法

### 1. 基本HiC分析
```bash
# 使用默认配置（scCARE.txt）
./Scripts/schic_analysis_pipeline.sh -p "my_project" -i "input_fastq_dir"

# 使用指定配置
./Scripts/schic_analysis_pipeline.sh -n 2 -p "my_project" -i "input_fastq_dir"
```

### 2. 完整S1S2HiC流程
```bash
# 端到端分析
python3 src/S1S2HiC_Pipeline.py \
    -p "ATCG,GCTA" \
    -d "scHi-C分析" \
    --project-name "my_schic_project" \
    --hic-config 1
```

### 3. 自定义基础路径
如果需要将HiC-Pro安装在其他位置，只需修改脚本开头的变量：

```bash
# 编辑 Scripts/schic_analysis_pipeline.sh
# 将基础路径变量修改为新位置
HICPRO_BASE_DIR="/your/custom/path"
```

## ✅ 优势

1. **路径独立**: 不再依赖特定用户的主目录路径
2. **结构清晰**: 按功能分类组织文件
3. **易于维护**: 统一的文件位置便于管理
4. **可移植性**: 可以轻松在不同环境中部署
5. **版本控制**: 标准化路径便于脚本版本管理
6. **完整安装**: 保持HiC-Pro的完整安装结构，确保所有功能正常工作
7. **🆕 变量化管理**: 通过单一变量控制所有路径，极大简化配置管理

## 🔄 配置文件路径更新

### 📁 新增Bowtie2索引目录
为了完整支持HiC-Pro分析流程，已复制Bowtie2索引文件到标准化位置：

```
${HICPRO_BASE_DIR}/genome/bowtie2_index/
├── hg19.1.bt2
├── hg19.2.bt2
├── hg19.3.bt2
├── hg19.4.bt2
├── hg19.rev.1.bt2
└── hg19.rev.2.bt2
```

### 📝 配置文件路径更新完成
所有HiC-Pro配置文件中的基因组相关路径已更新：

| 配置文件 | 酶切位点 | 更新内容 | 状态 |
|----------|----------|----------|------|
| `scCARE_MboI.txt` | GATC (MboI) | ✅ BOWTIE2_IDX_PATH<br/>✅ GENOME_SIZE<br/>✅ GENOME_FRAGMENT | 已更新 |
| `hicpro_NlaIII.txt` | CATG (NlaIII) | ✅ BOWTIE2_IDX_PATH<br/>✅ GENOME_SIZE<br/>✅ GENOME_FRAGMENT | 已更新 |
| `hicpro_MboI.txt` | GATC (MboI) | ✅ BOWTIE2_IDX_PATH<br/>✅ GENOME_SIZE<br/>✅ GENOME_FRAGMENT<br/>✅ LIGATION_SITE | 已更新和补充 |

### 🔗 路径映射详情
| 参数 | 原路径 | 新路径 |
|------|-------|--------|
| BOWTIE2_IDX_PATH | `/home/maolp/mao/Ref/AllnewstarRef/Homo/HG19/HG19BT/` | `${HICPRO_BASE_DIR}/genome/bowtie2_index/` |
| GENOME_SIZE | `/home/maolp/mao/Ref/AllnewstarRef/Homo/HG19/hg19.sizes` | `${HICPRO_BASE_DIR}/genome/hg19.sizes` |
| GENOME_FRAGMENT | `/home/maolp/mao/Ref/AllnewstarRef/Homo/HG19/HG19mboi.bed` | `${HICPRO_BASE_DIR}/genome/HG19mboi.bed` |

现在所有配置文件都指向标准化的路径，不再依赖用户特定的目录结构！

## 🧬 酶切位点命名系统

### 🔬 配置文件按酶切位点重新命名
为了更清晰地标识不同的Hi-C实验条件，配置文件已按照酶切位点重新命名：

| 新文件名 | 酶切位点 | 连接位点 | 适用实验 |
|----------|----------|----------|----------|
| `scCARE_MboI.txt` | MboI | GATC | scCARE-seq实验 |
| `hicpro_NlaIII.txt` | NlaIII | CATG | NlaIII酶切实验 |
| `hicpro_MboI.txt` | MboI | GATC | 标准MboI实验 |

### 📊 选择指南
```bash
# 1. scCARE-seq实验（MboI酶）
./Scripts/schic_analysis_pipeline.sh -n 1

# 2. NlaIII酶切实验  
./Scripts/schic_analysis_pipeline.sh -n 2

# 3. 标准MboI酶切实验
./Scripts/schic_analysis_pipeline.sh -n 3
```

### ✨ 命名优势
- **清晰标识**: 文件名直接反映酶切条件
- **避免混淆**: 不同酶切条件配置一目了然
- **易于选择**: 根据实验类型快速选择正确配置
- **标准化**: 统一的命名规范便于管理

## 🔍 验证安装

检查所有文件是否正确安装：

```bash
# 检查目录结构
tree /data1/Ref/hicpro -L 3

# 验证HiC-Pro可以正常运行
export PATH="/data1/Ref/hicpro/HiC-Pro-3.1.0/bin:$PATH"
HiC-Pro --help

# 检查关键文件存在
ls -la /data1/Ref/hicpro/HiC-Pro-3.1.0/bin/HiC-Pro
ls -la /data1/Ref/hicpro/configs/
ls -la /data1/Ref/hicpro/genome/

# 测试分析脚本
./Scripts/schic_analysis_pipeline.sh -h
```

## 📝 注意事项

1. **完整安装**: HiC-Pro需要完整的安装目录结构才能正常工作，包括配置系统文件
2. **PATH设置**: 使用时需要将HiC-Pro的bin目录添加到PATH环境变量中
3. **权限设置**: 确保 `${HICPRO_BASE_DIR}` 目录有适当的读写权限
4. **配置文件**: 配置文件可根据具体需求进行定制
5. **环境依赖**: 确保系统已安装HiC-Pro所需的依赖包（Python2.7, R, samtools等）
6. **🆕 路径变量**: 如需更改安装位置，只需修改 `HICPRO_BASE_DIR` 变量

## 🛠️ 故障排除

如果遇到"config system not detected"错误：
1. 确认已复制完整的HiC-Pro-3.1.0目录
2. 检查config-system.txt文件是否存在
3. 验证目录权限设置正确

如果需要重新安装或更新HiC-Pro：
1. 更新 `${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/` 目录
2. 如需更改安装位置，修改脚本中的 `HICPRO_BASE_DIR` 变量

## 🔄 路径迁移指南

如果需要将安装迁移到新位置：

```bash
# 1. 复制整个目录到新位置
sudo cp -r /data1/Ref/hicpro /new/location/

# 2. 修改脚本中的基础路径变量
sed -i 's|HICPRO_BASE_DIR="/data1/Ref/hicpro"|HICPRO_BASE_DIR="/new/location/hicpro"|' Scripts/schic_analysis_pipeline.sh

# 3. 验证新路径是否正常工作
./Scripts/schic_analysis_pipeline.sh -h
``` 