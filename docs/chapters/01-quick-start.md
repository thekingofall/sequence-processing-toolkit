# 第一章：快速开始指南 ⚡

> 📖 **本章目标**：让您在5分钟内上手任何系统，零基础快速体验

## 🎯 我该选择哪个系统？

### 30秒决策树

```
您的需求是什么？
├─ 🧬 生物信息学 - HiC数据分析 
│  └─ → 选择【S1S2HiC系统】，跳转到 1.1 节
├─ 🚀 通用脚本 - 任意并行任务
│  └─ → 选择【通用并行系统】，跳转到 1.2 节  
├─ 📥 阿里云OSS数据下载
│  └─ → 选择【OSS下载工具】，跳转到 1.3 节
└─ 🛠️ 单个工具使用
   └─ → 选择【单个工具】，跳转到 1.4 节
```

---

## 1.1 S1S2HiC系统 - 30秒上手 🧬

> **适用场景**：HiC数据分析，包含S1筛选→S2分割→HiC分析的完整流程

### ⚡ 极简模式（推荐新手）

```bash
# 1. 生成配置模板
./run_s1s2hic_auto.sh --create-template

# 2. 编辑配置（只需改3个参数）
nano configs/templates/simple_config.conf

# 3. 运行（一键完成全流程）
./run_s1s2hic_auto.sh configs/templates/simple_config.conf
```

### 🎯 配置文件模式（推荐生产环境）

```bash
# 1. 进入src目录
cd src/

# 2. 生成YAML配置模板
python S1S2HiC_Pipeline.py --generate-config my_hic.yaml

# 3. 编辑配置文件
nano my_hic.yaml
# 修改: patterns: "你的序列1,你的序列2"

# 4. 运行完整流程
python S1S2HiC_Pipeline.py -c my_hic.yaml
```

📖 **详细文档**：[第二章 - S1S2HiC系统详解](02-s1s2hic-system.md)

---

## 1.2 通用并行系统 - 30秒上手 🚀

> **适用场景**：任意脚本的并行执行，支持Python/Bash/R等多种语言

### ⚡ 使用预设配置

```bash
# 1. 使用示例配置（直接可运行）
./runsh.sh -c configs/templates/example_config.yaml

# 2. 查看运行结果
./runsh.sh -l  # 列出所有任务组
```

### 🎯 自定义配置

```bash
# 1. 复制空白模板
cp configs/templates/blank_config.yaml my_tasks.yaml

# 2. 编辑配置文件
nano my_tasks.yaml
# 添加你的脚本和参数

# 3. 运行自定义任务
./runsh.sh -c my_tasks.yaml
```

📖 **详细文档**：[第三章 - 通用并行系统详解](03-parallel-system.md)

---

## 1.3 OSS下载工具 - 30秒上手 📥

> **适用场景**：批量下载阿里云OSS数据，支持断点续传和并发下载

### ⚡ 快速下载

```bash
# 1. 创建下载路径配置
cat > my_oss_paths.txt << EOF
oss://your-bucket/path1/data1
oss://your-bucket/path2/data2
EOF

# 2. 运行下载
cd Scripts/
./oss_download.sh -i my_oss_paths.txt -o ./downloads

# 3. 首次使用需配置OSS凭证
# 按提示输入AccessKey ID、AccessKey Secret、Endpoint
```

### 🎯 批量下载示例

```bash
# 使用示例配置文件
./oss_download.sh -i oss_paths_example.txt -o ./my_downloads

# 查看下载报告
cat my_downloads/download_report.txt
```

📖 **详细文档**：[第九章 - 数据下载工具](09-download-tools.md)

---

## 1.4 单个工具使用 - 30秒上手 🛠️

> **适用场景**：使用单个专业工具处理特定任务

### ⚡ S2分割工具

```bash
# 将FASTQ文件分割为R1和R2配对文件
cd src/
python S2_Split.py -i sample.fastq.gz -o output_dir
```

### ⚡ S3序列统计工具

```bash
# 批量统计序列模式出现频率
cd src/
./S3_process_sequences_count.sh -p "ATCGATCG,GCTAGCTA" -d "我的分析"
```

### ⚡ S1序列筛选工具

```bash
# 从FASTQ中筛选包含特定序列的reads
cd src/
python S1_Process_gen.py -p "ATCGATCG,GCTAGCTA" -d "序列筛选"
```

📖 **详细文档**：[第八章 - 单个工具详解](08-individual-tools.md)

---

## 🆘 遇到问题？

### 1分钟问题诊断

```bash
# 检查系统状态
./runsh.sh --validate configs/templates/example_config.yaml

# 查看帮助信息
./runsh.sh -h                    # 通用并行系统
./run_s1s2hic_auto.sh -h        # S1S2HiC系统  
cd Scripts/ && ./oss_download.sh -h  # OSS下载工具
```

### 常见问题快速解决

| 问题 | 快速解决方案 | 详细说明 |
|------|-------------|----------|
| 🔧 配置文件语法错误 | `./runsh.sh --validate 配置文件` | [第七章 7.1](07-troubleshooting.md#71-配置文件问题) |
| 📂 找不到文件 | 检查相对路径，使用 `./script` 格式 | [第七章 7.2](07-troubleshooting.md#72-路径问题) |
| ⚡ 脚本无执行权限 | `chmod +x 脚本名` | [第七章 7.3](07-troubleshooting.md#73-权限问题) |
| 🧬 S1S2HiC流程中断 | 使用 `skip_*` 参数跳过已完成步骤 | [第二章 2.3](02-s1s2hic-system.md#23-流程控制) |

📖 **完整故障排除**：[第七章 - 故障排除](07-troubleshooting.md)

---

## 🎓 学习路径建议

### 🔰 初学者路径
1. **第一步**：尝试 1.1 或 1.2 的30秒上手
2. **第二步**：阅读对应的详细章节（第2章或第3章）
3. **第三步**：查看 [第四章 - 配置文件详解](04-configuration.md)

### 🎯 问题导向路径
1. **配置相关**：[第四章 - 配置文件详解](04-configuration.md)
2. **命令使用**：[第五章 - 命令参考](05-commands.md)  
3. **故障排除**：[第七章 - 故障排除](07-troubleshooting.md)

### 👨‍💻 开发者路径
1. **系统架构**：[第六章 - 文件结构详解](06-file-structure.md)
2. **高级配置**：[第四章 4.3 - 高级配置技巧](04-configuration.md#43-高级配置技巧)
3. **自定义扩展**：[第三章 3.4 - 自定义脚本](03-parallel-system.md#34-自定义脚本支持)

---

## 🎉 恭喜！

您已经完成了快速开始！接下来可以：

- 🎯 **继续深入**：根据您选择的系统，阅读对应的详细章节
- 📚 **浏览全书**：查看 [完整文档索引](../index.md)
- 💡 **解决问题**：遇到问题时查看 [第七章 - 故障排除](07-troubleshooting.md)

**下一步推荐**：
- 选择了S1S2HiC？→ [第二章 - S1S2HiC系统详解](02-s1s2hic-system.md)
- 选择了通用并行？→ [第三章 - 通用并行系统详解](03-parallel-system.md)
- 想了解配置文件？→ [第四章 - 配置文件详解](04-configuration.md)

---

> 💡 **提示**：每个章节都设计为可以独立阅读，您可以根据需要跳跃阅读。 