# 第六章：文件结构详解

> 📁 深入理解项目组织结构和文件分布

## 6.1 整体架构

```
sequence-processing-toolkit/
├── 🚀 主入口脚本
├── ⚙️ 配置文件系统
├── 🔧 辅助工具脚本
├── 📚 源代码模块
├── 📊 日志和结果
└── 📖 文档系统
```

## 6.2 完整目录结构

```
sequence-processing-toolkit/
├── runsh.sh                           # 🚀 通用并行处理主脚本
├── run_s1s2hic_auto.sh               # 🧬 S1S2HiC自动化脚本
├── README.md                          # 📖 主文档入口
├── LICENSE                            # 📄 开源许可证
├── .gitignore                         # 🚫 Git忽略规则
│
├── configs/                           # ⚙️ 配置文件系统
│   ├── templates/                     # 配置模板
│   │   ├── parallel_config.yaml       # 通用系统S1S2HiC配置
│   │   ├── blank_config.yaml         # 空白配置模板
│   │   ├── example_config.yaml       # 示例配置
│   │   ├── simple_config.conf        # S1S2HiC简化配置
│   │   └── config_template.yaml      # 原始配置模板
│   ├── environments/                  # 环境配置
│   │   └── runhicpro_environment.yml # HiC-Pro环境配置
│   ├── Group1_MboI_GATC_SeqA_config.yaml      # S1S2HiC组配置
│   ├── Group2_MboI_GATC_SeqB_config.yaml
│   ├── Group3_MseI_CviQI_TA_SeqA_config.yaml
│   ├── Group4_MseI_CviQI_TA_SeqB_config.yaml
│   └── Group5_MboI_CviQI_GATC_TA_SeqA_config.yaml
│
├── scripts/                           # 🔧 辅助工具脚本
│   ├── config_parser.py              # 配置解析器
│   ├── run_group_parallel.sh         # 原始并行脚本
│   ├── check_setup.sh                # 环境检查工具
│   └── clean.sh                      # 清理工具
│
├── src/                              # 📚 源代码模块
│   ├── S1S2HiC_Pipeline.py          # S1S2HiC主流程
│   ├── S1_Process_gen.py             # S1步骤处理
│   ├── S2_Split.py                   # S2步骤处理
│   ├── S1S2_Pipeline.py              # S1S2流程
│   ├── S3_process_sequences_count.sh # S3统计脚本
│   └── __pycache__/                  # Python缓存
│
├── docs/                             # 📖 文档系统
│   ├── chapters/                     # 分章节文档
│   │   ├── 01-quick-start.md         # 第一章：快速开始
│   │   ├── 02-s1s2hic-system.md      # 第二章：S1S2HiC系统
│   │   ├── 03-parallel-system.md     # 第三章：并行系统
│   │   ├── 04-configuration.md       # 第四章：配置详解
│   │   ├── 05-commands.md            # 第五章：命令参考
│   │   ├── 06-file-structure.md      # 第六章：文件结构
│   │   └── 07-troubleshooting.md     # 第七章：故障排除
│   ├── index.md                      # 文档索引
│   ├── QUICKSTART_S1S2HiC.md        # S1S2HiC快速开始
│   ├── QUICKSTART_OSS.md            # 开源版本快速开始
│   ├── README_*.md                   # 各模块README
│   └── ...
│
├── examples/                         # 📝 使用示例
│   ├── basic_usage.sh                # 基本使用示例
│   ├── run_s1s2_example.sh          # S1S2示例
│   └── run_s1s2hic_example.sh       # S1S2HiC示例
│
├── test/                            # 🧪 测试脚本
│   ├── run_group1.sh                # 组1测试
│   ├── run_group2.sh                # 组2测试
│   ├── run_group4.sh                # 组4测试
│   ├── run_group5.sh                # 组5测试
│   └── run_simple_test.sh           # 简单测试
│
├── Scripts/                         # 🛠️ 扩展脚本（兼容性）
│   ├── clean_results.sh             # 结果清理
│   ├── oss_download.sh              # OSS下载工具
│   ├── run_all_groups_sequential.sh # 顺序执行脚本
│   ├── run_single_group.sh          # 单组执行
│   ├── run_single_group_with_hic.sh # 单组HiC执行
│   └── schic_analysis_pipeline.sh   # scHiC分析流程
│
├── data/                            # 📂 数据目录
│   └── fastq -> /data3/.../fastq/   # 数据软链接
│
├── results/                         # 📊 结果目录
│   ├── Group1_MboI_GATC_SeqA/       # 组1结果
│   ├── Group2_MboI_GATC_SeqB/       # 组2结果
│   └── processing_output/           # 处理输出
│       ├── CountFold/               # 统计结果
│       └── Group1_S1_Linker_Separated/ # S1输出
│
├── auto_logs/                       # 📝 S1S2HiC日志
├── parallel_logs/                   # 📝 并行处理日志
└── .git/                           # 🔄 Git版本控制
```

## 6.3 文件功能详解

### 6.3.1 主执行脚本

**runsh.sh**
- **作用**: 通用并行处理系统的主控脚本
- **功能**: 解析配置、管理并行任务、处理信号
- **依赖**: scripts/config_parser.py

**run_s1s2hic_auto.sh**  
- **作用**: S1S2HiC系统的自动化入口
- **功能**: 配置管理、环境检查、任务调度
- **依赖**: scripts/run_group_parallel.sh

### 6.3.2 配置文件系统

#### configs/templates/
存放各种配置文件模板：

**parallel_config.yaml**
- 包含S1S2HiC预设的5个组配置
- 适合需要S1S2HiC功能的通用系统用户

**blank_config.yaml**
- 完全空白的配置模板
- 适合完全自定义任务的用户

**example_config.yaml**
- 带示例的配置模板
- 适合通用系统新手用户

**simple_config.conf**
- S1S2HiC专用的简化配置
- bash格式，参数直观

#### configs/environments/
存放环境配置文件：

**runhicpro_environment.yml**
- HiC-Pro的conda环境配置
- 包含所有依赖包版本

#### configs/Group*_config.yaml
S1S2HiC的5个预设组配置文件，每个对应一种实验类型。

### 6.3.3 工具脚本

#### scripts/config_parser.py
- **作用**: YAML配置文件解析器
- **功能**: 格式验证、路径展开、配置转换
- **输出**: bash可用的变量定义

#### scripts/run_group_parallel.sh
- **作用**: 原始的S1S2HiC并行脚本
- **功能**: 硬编码5个组的并行处理
- **状态**: 已被新系统替代，保留作参考

#### scripts/check_setup.sh
- **作用**: 环境检查工具
- **功能**: 验证Python、软件包、路径权限
- **用法**: 安装后首次运行

#### scripts/clean.sh
- **作用**: 清理工具
- **功能**: 清理临时文件、日志文件
- **用法**: 系统维护

### 6.3.4 源代码模块

#### src/S1S2HiC_Pipeline.py
- **作用**: S1S2HiC主流程控制器
- **功能**: 协调S1、S2、HiC三个阶段
- **输入**: YAML配置文件
- **输出**: 完整的分析结果

#### src/S1_Process_gen.py
- **作用**: S1步骤处理模块
- **功能**: 序列筛选、接头识别、统计生成
- **输出**: CountFold目录

#### src/S2_Split.py
- **作用**: S2步骤处理模块
- **功能**: 酶切位点识别、序列分割
- **输出**: *_S2_Enzyme_Split目录

### 6.3.5 文档系统

#### docs/chapters/
采用书籍式章节组织：
- 01-07章覆盖从入门到高级的所有内容
- 每章独立，可单独阅读
- 交叉引用，形成完整体系

#### docs/index.md
- 文档总索引
- 章节导航
- 快速查找

### 6.3.6 日志系统

#### auto_logs/
S1S2HiC系统日志：
```
auto_logs/
├── auto_run_PROJECT_NAME_TIMESTAMP.log  # 主日志
├── summary_PROJECT_NAME_TIMESTAMP.txt   # 结果摘要
└── error_TIMESTAMP.log                  # 错误日志
```

#### parallel_logs/
通用并行系统日志：
```
parallel_logs/
├── group1_TIMESTAMP.log                # 组1日志
├── group2_TIMESTAMP.log                # 组2日志
├── ...
└── main_TIMESTAMP.log                  # 主控日志
```

## 6.4 路径规则和约定

### 6.4.1 相对路径基准

- **配置文件中的相对路径**: 相对于项目根目录
- **脚本内的相对路径**: 相对于`SCRIPT_DIR`变量
- **工作目录**: 由配置文件中的`work_dir`指定

### 6.4.2 自动路径检测

```bash
# 自动检测项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 配置文件中的自动检测
script_dir: "auto"  # 使用配置文件所在目录
```

### 6.4.3 路径优先级

1. **绝对路径**: 直接使用
2. **环境变量**: `${VAR}` 或 `${VAR:-default}`
3. **用户主目录**: `~/path`
4. **相对路径**: `./path` 或 `path`

## 6.5 文件权限和所有权

### 6.5.1 可执行文件

```bash
# 主脚本
-rwxrwxr-x runsh.sh
-rwxrwxr-x run_s1s2hic_auto.sh

# 工具脚本  
-rwxrwxr-x scripts/config_parser.py
-rwxrwxr-x scripts/run_group_parallel.sh
-rwxrwxr-x scripts/check_setup.sh
-rwxrwxr-x scripts/clean.sh

# 源代码（可选可执行）
-rw-rw-r-- src/S1S2HiC_Pipeline.py
-rw-rw-r-- src/S1_Process_gen.py
-rw-rw-r-- src/S2_Split.py
```

### 6.5.2 配置文件

```bash
# 配置文件（只读）
-rw-rw-r-- configs/templates/*.yaml
-rw-rw-r-- configs/templates/*.conf
-rw-rw-r-- configs/Group*.yaml
```

### 6.5.3 日志目录

```bash
# 日志目录（可写）
drwxrwxr-x auto_logs/
drwxrwxr-x parallel_logs/
-rw-rw-r-- auto_logs/*.log
-rw-rw-r-- parallel_logs/*.log
```

## 6.6 存储空间规划

### 6.6.1 空间需求估算

| 目录 | 大小估算 | 说明 |
|------|----------|------|
| 源代码 | < 10 MB | Python/Shell脚本 |
| 配置文件 | < 1 MB | YAML/CONF文件 |
| 文档 | < 5 MB | Markdown文档 |
| 日志文件 | 1-100 MB | 根据运行频率 |
| 临时文件 | 数据量的3-5倍 | 处理过程中 |
| 结果文件 | 数据量的1-2倍 | 最终输出 |

### 6.6.2 存储优化建议

**临时文件位置**
```bash
# 使用快速存储（SSD）
export TMPDIR=/fast/scratch/tmp

# 在配置中指定临时目录
work_dir: "${TMPDIR}/task1"
```

**结果文件管理**
```bash
# 定期归档旧结果
tar -czf results_archive_$(date +%Y%m%d).tar.gz results/
rm -rf results/old_*

# 清理日志文件
find auto_logs/ -name "*.log" -mtime +30 -delete
find parallel_logs/ -name "*.log" -mtime +30 -delete
```

## 6.7 文件组织最佳实践

### 6.7.1 项目扩展

当需要添加新功能时：

```
sequence-processing-toolkit/
├── configs/templates/
│   └── new_feature_config.yaml        # 新功能配置
├── scripts/
│   └── new_feature_tool.py           # 新功能工具
├── src/
│   └── new_feature_pipeline.py       # 新功能主模块
└── docs/chapters/
    └── 08-new-feature.md             # 新功能文档
```

### 6.7.2 版本管理

```bash
# .gitignore 已配置忽略
auto_logs/          # 运行日志
parallel_logs/      # 并行日志
results/           # 结果文件
*.tmp             # 临时文件
__pycache__/      # Python缓存
```

### 6.7.3 备份策略

**配置备份**
```bash
# 备份关键配置
tar -czf config_backup_$(date +%Y%m%d).tar.gz configs/
```

**代码备份**  
```bash
# 使用Git进行版本控制
git add .
git commit -m "功能更新"
git push origin main
```

**数据备份**
```bash
# 备份重要结果
rsync -av results/ /backup/results_$(date +%Y%m%d)/
``` 