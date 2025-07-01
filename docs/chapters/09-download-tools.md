# 第九章：数据下载工具 📥

> 🎯 **本章目标**：掌握批量下载阿里云OSS数据的完整方法，实现高效数据获取

## 9.1 工具概述

OSS数据下载脚本是专门为批量下载阿里云OSS数据设计的Shell工具，支持断点续传、并发下载和智能错误处理。

### ✨ 核心特性

| 特性 | 说明 | 优势 |
|------|------|------|
| 📁 **批量下载** | 从配置文件读取多个OSS路径 | 一次配置，批量处理 |
| 🔧 **用户级安装** | 无需sudo权限，用户目录安装 | 部署简单，权限友好 |
| 🔄 **断点续传** | 支持下载中断后继续 | 网络问题不怕 |
| ⚡ **并发下载** | 多线程提高下载速度 | 充分利用带宽 |
| 📊 **进度显示** | 实时显示下载进度和状态 | 过程透明可控 |
| 🤖 **智能检测** | 自动检测并安装ossutil工具 | 零配置开始 |
| 🛡️ **错误处理** | 完善的错误检查和友好提示 | 问题定位准确 |
| 📈 **统计报告** | 生成详细的下载报告 | 结果一目了然 |

---

## 9.2 系统要求

### 🖥️ 操作系统支持

- **Linux** (CentOS/Ubuntu/Debian等) - 推荐
- **macOS** - 兼容
- **Windows WSL** - 支持

### 📦 依赖工具

```bash
# 必需的系统工具（通常已预装）
- bash (版本 4.0+)
- wget (用于下载ossutil)
- curl (备用下载工具)
- tar (解压工具)

# 自动安装的工具
- ossutil (阿里云OSS命令行工具，脚本自动下载安装)
```

### 🔑 准备OSS访问凭证

在使用前，您需要从阿里云控制台获取以下信息：

| 凭证信息 | 说明 | 获取方式 |
|----------|------|----------|
| **AccessKey ID** | OSS访问密钥ID | 阿里云控制台 → 访问控制 → 用户管理 |
| **AccessKey Secret** | OSS访问密钥 | 同上，创建AccessKey时获得 |
| **Endpoint** | OSS服务地域节点 | 如：`oss-cn-beijing.aliyuncs.com` |

---

## 9.3 安装和配置

### 🚀 快速安装

```bash
# 1. 进入脚本目录
cd sequence-processing-toolkit/Scripts/

# 2. 设置执行权限
chmod +x oss_download.sh

# 3. 查看帮助信息
./oss_download.sh --help
```

### 📝 创建路径配置文件

#### 方法1：使用示例配置
```bash
# 复制示例文件
cp oss_paths_example.txt my_paths.txt

# 编辑配置文件
nano my_paths.txt
```

#### 方法2：从零创建
```bash
# 创建新的配置文件
cat > my_download_paths.txt << EOF
# OSS路径配置文件
# 以#开头的行是注释，会被忽略
# 空行也会被忽略

# 示例OSS路径
oss://your-bucket-name/project1/data
oss://your-bucket-name/project2/results  
oss://your-bucket-name/project3/output

# 支持中文路径
oss://中文桶名/项目数据/结果文件

# 可以添加更多路径...
EOF
```

### 📄 配置文件格式详解

#### ✅ 支持的格式
- ✅ 每行一个OSS路径
- ✅ 路径必须以 `oss://` 开头
- ✅ 支持 `#` 开头的注释行
- ✅ 自动忽略空行
- ✅ 支持中文和特殊字符
- ✅ 支持目录和单个文件路径

#### 📋 配置文件示例
```
# 项目A的数据下载配置
# ==============================

# 原始测序数据
oss://my-genomics-bucket/project-a/raw-data/
oss://my-genomics-bucket/project-a/fastq-files/

# 分析结果
oss://my-genomics-bucket/project-a/results/alignment/
oss://my-genomics-bucket/project-a/results/variants/

# 特定文件
oss://my-genomics-bucket/project-a/summary_report.pdf
oss://my-genomics-bucket/project-a/final_results.xlsx

# 项目B的数据（可选）
# oss://my-genomics-bucket/project-b/data/
```

---

## 9.4 使用方法

### 🔧 基本语法

```bash
cd Scripts/
./oss_download.sh -i <输入文件> -o <输出目录>
./oss_download.sh --input <输入文件> --output <输出目录>
```

### 📋 参数详解

| 参数 | 长格式 | 说明 | 示例 | 必需 |
|------|--------|------|------|------|
| `-i` | `--input` | 输入文件路径，包含OSS路径列表 | `my_paths.txt` | ✅ |
| `-o` | `--output` | 输出目录路径，下载数据保存位置 | `./downloads` | ✅ |
| `-h` | `--help` | 显示帮助信息 | - | ❌ |

### 📖 使用示例

#### 示例1：基础使用
```bash
# 使用示例配置文件
cd Scripts/
./oss_download.sh -i oss_paths_example.txt -o ./downloads
```

#### 示例2：自定义配置
```bash
# 使用自定义配置文件和输出路径
./oss_download.sh --input /path/to/my_paths.txt --output /data/oss_downloads
```

#### 示例3：项目特定下载
```bash
# 为特定项目创建下载目录
mkdir -p ~/projects/project_alpha/data
./oss_download.sh -i project_alpha_paths.txt -o ~/projects/project_alpha/data
```

---

## 9.5 完整使用流程

### 🏁 首次使用流程

```bash
# 步骤1：进入脚本目录
cd sequence-processing-toolkit/Scripts/

# 步骤2：设置执行权限
chmod +x oss_download.sh

# 步骤3：创建路径配置文件
nano my_oss_paths.txt
# 添加您的OSS路径，每行一个

# 步骤4：运行脚本
./oss_download.sh -i my_oss_paths.txt -o ./my_downloads

# 步骤5：首次运行配置OSS凭证
# 脚本会自动提示输入：
# - AccessKey ID
# - AccessKey Secret  
# - Endpoint

# 步骤6：等待下载完成
# 脚本会显示实时进度和状态

# 步骤7：查看下载结果
ls -la my_downloads/
cat my_downloads/download_report.txt
```

### 🔄 后续使用流程

```bash
# 配置完成后，直接使用即可
./oss_download.sh -i new_paths.txt -o ./new_downloads
```

### 🛠️ 高级配置

#### 环境变量配置（可选）
```bash
# 预设OSS配置（避免每次输入）
export OSS_ACCESS_KEY_ID="your_access_key_id"
export OSS_ACCESS_KEY_SECRET="your_access_key_secret"  
export OSS_ENDPOINT="oss-cn-beijing.aliyuncs.com"

# 然后运行下载
./oss_download.sh -i paths.txt -o downloads
```

---

## 9.6 输出结果详解

### 📁 目录结构

下载完成后的目录结构：

```
output_directory/
├── dataset1/                    # 下载的数据集1
│   ├── file1.fastq.gz
│   ├── file2.fastq.gz
│   └── subfolder/
├── dataset2/                    # 下载的数据集2
│   ├── results.txt
│   └── analysis/
├── dataset3/                    # 下载的数据集3
├── download_report.txt          # 详细下载报告
└── .checkpoint/                 # 断点续传临时文件（可删除）
```

### 📊 下载报告

脚本会自动生成 `download_report.txt`，包含完整的下载统计：

```
OSS数据下载报告
===============

下载时间: 2024-07-01 14:30:22
输入文件: my_oss_paths.txt  
输出目录: /home/user/downloads
OSS配置: oss-cn-beijing.aliyuncs.com

下载统计:
- 总计: 5 个OSS路径
- 成功: 4 个
- 失败: 1 个
- 总大小: 2.8 GB
- 总耗时: 15分32秒

成功下载的数据集:
1. project-a/raw-data/ (大小: 1.2G, 耗时: 8分15秒)
2. project-a/results/ (大小: 856M, 耗时: 5分20秒)
3. project-b/analysis/ (大小: 645M, 耗时: 1分45秒)
4. summary_report.pdf (大小: 2.3M, 耗时: 12秒)

失败的下载:
1. project-c/missing-data/ (错误: 路径不存在)

下载速度统计:
- 平均速度: 3.2 MB/s
- 最快速度: 8.7 MB/s (project-a/raw-data/)
- 最慢速度: 1.1 MB/s (project-b/analysis/)

建议:
- 失败的路径请检查是否存在或权限是否正确
- 下载速度受网络环境影响，建议在网络良好时下载大文件
```

---

## 9.7 高级功能

### 🔄 断点续传

脚本自动支持断点续传功能：

```bash
# 如果下载过程中中断（网络问题、停电等）
# 重新运行相同命令即可从断点继续
./oss_download.sh -i my_paths.txt -o ./downloads

# 脚本会自动检测已下载的文件，跳过完整文件，继续未完成的下载
```

### ⚡ 并发下载配置

```bash
# 脚本内置并发下载优化
# 可以通过修改脚本中的参数调整并发数：

# 编辑脚本文件
nano oss_download.sh

# 找到并修改以下参数：
# CONCURRENT_DOWNLOADS=3  # 同时下载的文件数
# THREAD_COUNT=4          # 每个文件的线程数
```

### 📋 批量项目管理

#### 项目分组下载
```bash
# 创建项目特定的配置文件
cat > project_A_paths.txt << EOF
oss://bucket/project-A/raw-data/
oss://bucket/project-A/results/
EOF

cat > project_B_paths.txt << EOF  
oss://bucket/project-B/analysis/
oss://bucket/project-B/reports/
EOF

# 分别下载不同项目
./oss_download.sh -i project_A_paths.txt -o ./projects/project_A/
./oss_download.sh -i project_B_paths.txt -o ./projects/project_B/
```

#### 自动化批量下载脚本
```bash
#!/bin/bash
# 批量项目下载脚本

projects=("project_A" "project_B" "project_C")

for project in "${projects[@]}"; do
    echo "开始下载项目: $project"
    
    # 创建项目目录
    mkdir -p "./downloads/$project"
    
    # 下载项目数据
    ./oss_download.sh \
        -i "${project}_paths.txt" \
        -o "./downloads/$project"
    
    if [ $? -eq 0 ]; then
        echo "项目 $project 下载成功"
    else
        echo "项目 $project 下载失败"
    fi
    
    echo "------------------------"
done

echo "所有项目下载完成！"
```

---

## 9.8 性能优化

### 🚀 下载速度优化

#### 网络环境优化
```bash
# 1. 选择最近的OSS地域节点
# 华北地区推荐: oss-cn-beijing.aliyuncs.com
# 华东地区推荐: oss-cn-shanghai.aliyuncs.com
# 华南地区推荐: oss-cn-shenzhen.aliyuncs.com

# 2. 在网络高峰期之外下载
# 推荐时间: 夜间或凌晨

# 3. 使用有线网络代替WiFi
```

#### 硬件环境优化
```bash
# 1. 使用SSD存储作为下载目标
./oss_download.sh -i paths.txt -o /ssd_path/downloads

# 2. 确保足够的磁盘空间
df -h /path/to/download/directory

# 3. 监控内存使用
free -h
```

### 📊 监控和调试

#### 实时监控下载进度
```bash
# 在另一个终端监控下载进度
watch -n 2 'du -sh downloads/ && ls -la downloads/'

# 监控网络使用情况
iftop  # 或者 nethogs
```

#### 下载日志分析
```bash
# 查看详细的ossutil日志
tail -f ~/.ossutilconfig

# 分析下载报告
grep "失败" downloads/download_report.txt
grep "成功" downloads/download_report.txt
```

---

## 9.9 故障排除

### 🚨 常见问题

#### 问题1：AccessKey配置错误
```bash
# 错误信息: "AccessKey ID或Secret错误"
# 解决方案:
# 1. 检查AccessKey是否正确
# 2. 重新配置ossutil
rm -rf ~/.ossutilconfig
./oss_download.sh -i test_paths.txt -o test_downloads

# 3. 验证权限
# 确保AccessKey有对应bucket的读取权限
```

#### 问题2：网络连接问题
```bash
# 错误信息: "连接超时" 或 "网络不可达"
# 解决方案:
# 1. 检查网络连接
ping oss-cn-beijing.aliyuncs.com

# 2. 检查防火墙设置
# 确保443端口（HTTPS）可访问

# 3. 尝试不同的endpoint
# 在配置时选择不同的地域节点
```

#### 问题3：路径不存在
```bash
# 错误信息: "NoSuchKey" 或 "NoSuchBucket"  
# 解决方案:
# 1. 验证OSS路径是否正确
# 2. 检查bucket名称和路径拼写
# 3. 确认路径确实存在：
#    在阿里云控制台查看OSS bucket内容
```

#### 问题4：磁盘空间不足
```bash
# 错误信息: "磁盘空间不足"
# 解决方案:
# 1. 检查磁盘空间
df -h

# 2. 清理临时文件
rm -rf downloads/.checkpoint/

# 3. 选择其他下载目录
./oss_download.sh -i paths.txt -o /larger_disk/downloads
```

#### 问题5：权限问题
```bash
# 错误信息: "权限被拒绝"
# 解决方案:
# 1. 检查脚本执行权限
chmod +x oss_download.sh

# 2. 检查输出目录权限
chmod 755 downloads/

# 3. 避免使用需要sudo的路径
# 使用用户目录: ~/downloads/
```

### 🔧 调试技巧

#### 逐步调试流程
```bash
# 1. 小文件测试
echo "oss://bucket/small-file.txt" > test_paths.txt
./oss_download.sh -i test_paths.txt -o test_downloads

# 2. 检查ossutil配置
ossutil config

# 3. 手动测试ossutil
ossutil ls oss://your-bucket/

# 4. 查看详细错误信息
./oss_download.sh -i paths.txt -o downloads 2>&1 | tee download.log
```

#### 脚本调试模式
```bash
# 开启bash调试模式
bash -x oss_download.sh -i paths.txt -o downloads

# 这会显示每个命令的执行过程，帮助定位问题
```

---

## 9.10 最佳实践

### 📋 项目管理建议

#### 1. 配置文件组织
```bash
# 推荐的目录结构
oss_configs/
├── production/
│   ├── project_A_v1.txt
│   ├── project_A_v2.txt
│   └── project_B_v1.txt
├── testing/
│   └── small_test_files.txt
└── archives/
    └── completed_projects/
```

#### 2. 下载目录规划
```bash
# 按项目和日期组织下载目录
downloads/
├── 2024-07-01/
│   ├── project_A/
│   └── project_B/
├── 2024-07-02/
│   └── project_C/
└── archives/
    └── old_downloads/
```

### 🔄 自动化工作流

#### 定时下载脚本
```bash
#!/bin/bash
# 定时下载脚本 (cron_download.sh)

DATE=$(date +%Y%m%d)
DOWNLOAD_DIR="./downloads/$DATE"

# 创建日期目录
mkdir -p "$DOWNLOAD_DIR"

# 下载当日数据
./oss_download.sh \
    -i "daily_paths.txt" \
    -o "$DOWNLOAD_DIR"

# 记录日志
echo "$(date): 下载完成" >> download_cron.log

# 清理老数据（保留7天）
find ./downloads/ -type d -mtime +7 -exec rm -rf {} \;
```

#### Crontab配置
```bash
# 编辑crontab
crontab -e

# 添加定时任务（每天凌晨2点执行）
0 2 * * * cd /path/to/Scripts && ./cron_download.sh

# 查看定时任务
crontab -l
```

### 🎯 性能调优指南

#### 根据网络环境调优
```bash
# 高速网络环境（>100Mbps）
# 可以增加并发数，修改脚本中的：
CONCURRENT_DOWNLOADS=5
THREAD_COUNT=8

# 低速网络环境（<10Mbps）  
# 减少并发数，避免超时：
CONCURRENT_DOWNLOADS=2
THREAD_COUNT=2

# 不稳定网络环境
# 增加重试次数，修改脚本中的：
MAX_RETRY=5
RETRY_DELAY=10
```

---

## 9.11 下一步建议

🎯 **完成本章学习后，您应该能够**：
- ✅ 熟练配置和使用OSS下载工具
- ✅ 处理各种下载场景和问题
- ✅ 优化下载性能和管理下载流程
- ✅ 集成下载工具到数据处理工作流

📚 **推荐后续阅读**：
- [第八章 - 单个工具详解](08-individual-tools.md) - 学习如何处理下载的数据
- [第二章 - S1S2HiC系统详解](02-s1s2hic-system.md) - 将下载的数据用于HiC分析
- [第三章 - 通用并行系统详解](03-parallel-system.md) - 集成下载到并行处理流程
- [第七章 - 故障排除](07-troubleshooting.md) - 解决复杂技术问题

### 🔗 完整数据处理工作流示例

```bash
# 完整的从下载到分析的工作流
# 1. 下载原始数据
./oss_download.sh -i genomics_data_paths.txt -o ./raw_data

# 2. 质量检查  
cd ../src/
./S3_process_sequences_count.sh -p "QUALITY_MOTIFS" -i "../Scripts/raw_data/*.gz"

# 3. S1S2HiC分析
python S1S2HiC_Pipeline.py -c hic_config.yaml

# 4. 结果上传（可选）
# ossutil cp -r results/ oss://result-bucket/project/
```

---

> 💡 **提示**：OSS下载工具的设计理念是"一次配置，多次使用"。建议为不同项目创建标准化的路径配置文件，建立规范的数据管理流程。 