# OSS数据下载脚本使用指南

## 📋 概述

这是一个用于批量下载阿里云OSS数据的Shell脚本工具。支持通过配置文件指定下载路径，自动安装依赖，提供详细的下载进度和统计报告。

## 🚀 主要特性

- ✅ **批量下载**：支持从配置文件读取多个OSS路径进行批量下载
- ✅ **用户级安装**：无需sudo权限，所有工具安装在用户目录
- ✅ **断点续传**：支持下载中断后从断点继续
- ✅ **并发下载**：使用多线程提高下载速度
- ✅ **进度显示**：实时显示下载进度和状态
- ✅ **智能检测**：自动检测并安装ossutil工具
- ✅ **错误处理**：完善的错误检查和用户友好的提示
- ✅ **统计报告**：生成详细的下载报告和统计信息

## 📁 文件说明

```
sequence-processing-toolkit/
├── Scripts/
│   ├── oss_download.sh           # 主下载脚本
│   └── oss_paths_example.txt     # 示例路径配置文件
└── docs/
    ├── README_OSS.md            # 本说明文档
    └── QUICKSTART_OSS.md        # 快速开始指南
```

## 🛠️ 安装要求

### 系统要求
- **操作系统**：Linux (CentOS/Ubuntu/Debian等)
- **Shell**：Bash 4.0+
- **网络**：能够访问互联网和阿里云OSS服务

### 依赖工具
脚本会自动检测和安装以下工具：
- **ossutil**：阿里云OSS命令行工具（自动下载安装）
- **wget**：用于下载ossutil（通常系统自带）

## 🔧 配置步骤

### 1. 准备OSS访问凭证

在使用前，你需要获取以下信息：
- **AccessKey ID**：OSS访问密钥ID
- **AccessKey Secret**：OSS访问密钥
- **Endpoint**：OSS服务地域节点（如：oss-cn-beijing.aliyuncs.com）

### 2. 设置脚本权限

```bash
cd sequence-processing-toolkit/Scripts/
chmod +x oss_download.sh
```

### 3. 创建路径配置文件

创建一个文本文件，每行包含一个OSS路径：

```bash
# 示例：创建my_paths.txt
cat > my_paths.txt << EOF
# OSS路径配置文件
oss://your-bucket/path1/data1
oss://your-bucket/path2/data2
oss://your-bucket/path3/data3
EOF
```

## 📝 使用方法

### 基本语法

```bash
./oss_download.sh -i <输入文件> -o <输出目录>
./oss_download.sh --input <输入文件> --output <输出目录>
```

### 参数说明

| 参数 | 长格式 | 说明 | 必需 |
|------|--------|------|------|
| `-i` | `--input` | 输入文件路径，包含OSS路径列表 | ✅ |
| `-o` | `--output` | 输出目录路径，下载数据保存位置 | ✅ |
| `-h` | `--help` | 显示帮助信息 | ❌ |

### 使用示例

#### 示例1：基本使用
```bash
cd Scripts/
./oss_download.sh -i oss_paths_example.txt -o ./downloads
```

#### 示例2：使用完整路径
```bash
./oss_download.sh --input /path/to/paths.txt --output /data/oss_downloads
```

#### 示例3：查看帮助
```bash
./oss_download.sh --help
```

## 📄 配置文件格式

### 路径配置文件格式

```
# OSS路径配置文件
# 以#开头的行是注释，会被忽略
# 空行也会被忽略

# 示例OSS路径
oss://bucket-name/project1/data
oss://bucket-name/project2/results  
oss://bucket-name/project3/output

# 支持中文路径
oss://中文桶名/项目数据/结果文件

# 可以添加更多路径...
```

### 格式要求

- ✅ 每行一个OSS路径
- ✅ 路径必须以 `oss://` 开头
- ✅ 支持 `#` 开头的注释行
- ✅ 自动忽略空行
- ✅ 支持中文和特殊字符

## 🔄 完整使用流程

### 第一次使用

```bash
# 1. 进入脚本目录
cd sequence-processing-toolkit/Scripts/

# 2. 设置执行权限
chmod +x oss_download.sh

# 3. 创建路径配置文件
nano my_oss_paths.txt

# 4. 运行脚本
./oss_download.sh -i my_oss_paths.txt -o ./my_downloads

# 5. 首次运行时配置OSS凭证
# 按提示输入AccessKey ID、AccessKey Secret、Endpoint

# 6. 等待下载完成，查看结果
ls -la my_downloads/
cat my_downloads/download_report.txt
```

### 后续使用

```bash
# 配置完成后，直接使用即可
./oss_download.sh -i new_paths.txt -o ./new_downloads
```

## 📊 输出说明

### 目录结构

```
output_directory/
├── dataset1/                    # 下载的数据集1
├── dataset2/                    # 下载的数据集2
├── dataset3/                    # 下载的数据集3
├── download_report.txt          # 详细下载报告
└── .checkpoint/                 # 断点续传临时文件
```

### 下载报告

脚本会自动生成 `download_report.txt`，包含：

```
OSS数据下载报告
===============

下载时间: 2024-01-01 14:30:22
输入文件: my_paths.txt  
输出目录: /home/user/downloads

下载统计:
- 总计: 3 个数据集
- 成功: 2 个
- 失败: 1 个

成功下载的数据集:
1. dataset1 (大小: 1.2G)
2. dataset2 (大小: 856M)

失败的路径:
- oss://bucket/invalid/path

总下载大小: 2.1G
```

## 🔍 故障排除

### 常见问题

#### 1. 权限错误
```bash
# 问题：Permission denied
# 解决：设置执行权限
chmod +x oss_download.sh
```

#### 2. OSS配置错误
```bash
# 问题：OSS连接失败
# 解决：重新配置OSS凭证
rm ~/.ossutilconfig
./oss_download.sh -i paths.txt -o output
```

#### 3. 网络连接问题
```bash
# 问题：下载失败，网络超时
# 解决：检查网络连接，重新运行脚本（支持断点续传）
```

#### 4. 磁盘空间不足
```bash
# 问题：No space left on device
# 解决：清理磁盘空间或更换输出目录
df -h  # 检查磁盘空间
```

#### 5. 路径不存在
```bash
# 问题：远程路径不存在或无权限访问
# 解决：检查OSS路径是否正确，确认访问权限
```

### 调试模式

如需调试，可以手动运行ossutil命令：

```bash
# 测试连接
~/bin/ossutil ls oss://your-bucket/ --limited-num 5

# 测试下载单个文件
~/bin/ossutil cp oss://your-bucket/test-file ./test-download/
```

## 🔧 高级配置

### 环境变量配置

```bash
# 可选：将ossutil添加到PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 自定义下载参数

如需修改下载参数，可以编辑脚本中的ossutil参数：

```bash
# 脚本中的下载命令（第109行左右）
"$OSSUTIL_PATH" cp -r "$path" "$local_dir" \
    --update \              # 增量更新
    --jobs 3 \              # 并发任务数（可调整为1-10）
    --part-size 104857600 \ # 分片大小（100MB）
    --bigfile-threshold 104857600 \
    --checkpoint-dir "$CHECKPOINT_DIR"
```

## 📞 技术支持

### 获取帮助

1. **查看内置帮助**：
   ```bash
   ./oss_download.sh --help
   ```

2. **检查日志**：下载过程中的详细信息会显示在终端

3. **查看报告**：下载完成后查看 `download_report.txt`

### 版本信息

- **脚本版本**：v1.0
- **ossutil版本**：1.7.18
- **兼容系统**：Linux (CentOS 7+, Ubuntu 18+, Debian 9+)

## 📄 许可证

本脚本仅供内部使用，请遵守相关数据使用协议。

---

*最后更新：2025年7月* 