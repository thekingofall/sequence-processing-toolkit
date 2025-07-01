# 第五章：命令参考

> 📋 完整的命令行参考手册和使用示例

## 5.1 命令概览

| 命令 | 系统 | 用途 |
|------|------|------|
| `runsh.sh` | 通用并行系统 | 主控脚本，执行并行任务 |
| `run_s1s2hic_auto.sh` | S1S2HiC系统 | S1S2HiC自动化脚本 |
| `config_parser.py` | 配置工具 | 配置文件解析和验证 |
| `check_setup.sh` | 环境工具 | 环境检查脚本 |

## 5.2 runsh.sh - 通用并行处理主脚本

### 基本语法

```bash
./runsh.sh -c <config_file> [options]
```

### 参数说明

| 参数 | 长格式 | 说明 | 必需 |
|------|--------|------|------|
| `-c` | `--config` | 指定配置文件路径 | ✅ |
| `-l` | `--list` | 列出配置中的所有组 | ❌ |
| `-h` | `--help` | 显示帮助信息 | ❌ |

### 使用示例

#### 基本运行
```bash
# 运行配置文件中所有启用的组
./runsh.sh -c configs/templates/parallel_config.yaml

# 使用自定义配置
./runsh.sh -c my_project.yaml

# 使用绝对路径
./runsh.sh -c /path/to/config.yaml
```

#### 查看信息
```bash
# 显示帮助
./runsh.sh -h
./runsh.sh --help

# 列出配置中的组
./runsh.sh -l -c configs/templates/parallel_config.yaml
./runsh.sh --list --config my_config.yaml
```

#### 高级用法
```bash
# 后台运行
nohup ./runsh.sh -c config.yaml > run.log 2>&1 &

# 使用screen保持会话
screen -S parallel_run
./runsh.sh -c config.yaml

# 监控运行状态
tail -f parallel_logs/group*_*.log
```

### 输出说明

#### 启动信息
```
=== 通用并行处理开始 ===
配置文件: /path/to/config.yaml
处理时间: 2025-01-26 14:30:22
============================================================
已启动 3 个并行任务
组号: task1 task2 task3
进程ID: 12345 12346 12347
============================================================
```

#### 完成信息
```
============================================================
=== 所有任务完成 ===
总任务数: 3
成功: 2
失败: 1
完成时间: 2025-01-26 16:45:33
============================================================
```

### 退出代码

| 代码 | 含义 |
|------|------|
| 0 | 所有任务成功完成 |
| 1 | 部分或全部任务失败 |
| 2 | 配置文件错误 |
| 3 | 参数错误 |

## 5.3 run_s1s2hic_auto.sh - S1S2HiC自动化脚本

### 基本语法

```bash
./run_s1s2hic_auto.sh [config_file|options]
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `config_file` | S1S2HiC配置文件路径 |
| `--create-template` | 创建配置文件模板 |
| `--help` | 显示帮助信息 |

### 使用示例

#### 基本使用
```bash
# 使用默认配置
./run_s1s2hic_auto.sh

# 使用自定义配置
./run_s1s2hic_auto.sh my_experiment.conf

# 使用模板配置
./run_s1s2hic_auto.sh configs/templates/simple_config.conf
```

#### 配置管理
```bash
# 创建配置模板
./run_s1s2hic_auto.sh --create-template

# 显示帮助
./run_s1s2hic_auto.sh --help
```

#### 典型工作流程
```bash
# 步骤1: 创建配置
./run_s1s2hic_auto.sh --create-template

# 步骤2: 编辑配置
nano configs/templates/simple_config.conf

# 步骤3: 运行分析
./run_s1s2hic_auto.sh configs/templates/simple_config.conf

# 步骤4: 查看结果
ls auto_logs/
tail -f auto_logs/auto_run_*.log
```

### 输出说明

#### 配置摘要
```
📋 配置摘要：
══════════════════════════════════════════════════════════════
项目名称: my_experiment_20250126
处理组: 1,2,3,4,5
数据目录: /data3/maolp/All_ZengXi_data5/...
并行任务数: 自动检测
输出目录: 各组工作目录
日志目录: ./auto_logs
重试次数: 1
══════════════════════════════════════════════════════════════
```

#### 进度信息
```
🚀 开始 S1S2HiC 自动分析
开始时间: 2025-01-26 14:30:22
主日志文件: auto_logs/auto_run_my_experiment_20250126_143022.log

启动 Group1 后台处理...
Group1 进程ID: 12345

启动 Group2 后台处理...
Group2 进程ID: 12346
```

## 5.4 config_parser.py - 配置解析工具

### 基本语法

```bash
python3 scripts/config_parser.py <config_file> [options]
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `--validate` | 验证配置文件格式 |
| `--list` | 列出所有组信息 |
| `--global` | 输出全局配置（内部使用） |
| `--groups` | 输出组配置（内部使用） |

### 使用示例

#### 配置验证
```bash
# 验证YAML语法
python3 scripts/config_parser.py configs/templates/parallel_config.yaml --validate

# 验证自定义配置
python3 scripts/config_parser.py my_config.yaml --validate
```

#### 信息查看
```bash
# 列出所有组
python3 scripts/config_parser.py configs/templates/parallel_config.yaml --list

# 查看组详情
python3 scripts/config_parser.py my_config.yaml --list
```

### 输出示例

#### 验证成功
```
配置文件验证通过
```

#### 验证失败
```
错误: 配置文件格式错误
YAML解析错误: 第15行缩进不正确
```

#### 组列表
```
组ID: group1
  状态: ✅ 启用
  描述: MboI+GATC+SeqA (3个样本, 6个文件)
  配置: Group1_MboI_GATC_SeqA_config.yaml
  目录: /data3/maolp/.../Group1_MboI_GATC_SeqA
------------------------------------------------------------
组ID: group2
  状态: ✅ 启用
  描述: MboI+GATC+SeqB (1个样本, 2个文件)
  配置: Group2_MboI_GATC_SeqB_config.yaml
  目录: /data3/maolp/.../Group2_MboI_GATC_SeqB
```

## 5.5 check_setup.sh - 环境检查工具

### 基本语法

```bash
bash scripts/check_setup.sh [options]
```

### 功能说明

- 检查Python环境
- 验证必需软件包
- 检查HiC-Pro安装
- 验证数据目录权限
- 测试配置文件

### 使用示例

```bash
# 完整环境检查
bash scripts/check_setup.sh

# 快速检查
bash scripts/check_setup.sh --quick

# 详细检查
bash scripts/check_setup.sh --verbose
```

## 5.6 日志和监控命令

### 实时监控

```bash
# 监控主日志
tail -f auto_logs/auto_run_*.log

# 监控并行日志
tail -f parallel_logs/group*_*.log

# 监控所有日志
tail -f auto_logs/*.log parallel_logs/*.log

# 使用multitail监控多个日志
multitail auto_logs/*.log parallel_logs/*.log
```

### 进程监控

```bash
# 查看运行中的任务
ps aux | grep python | grep -v grep

# 查看系统负载
htop
top

# 查看磁盘使用
df -h
du -sh /data/*/

# 查看网络连接
netstat -an | grep LISTEN
```

### 日志分析

```bash
# 搜索错误信息
grep -i error auto_logs/*.log parallel_logs/*.log

# 统计完成任务
grep "处理成功完成" auto_logs/*.log | wc -l

# 查看最近的日志
ls -lt auto_logs/ | head -10
ls -lt parallel_logs/ | head -10

# 清理旧日志
find auto_logs/ -name "*.log" -mtime +7 -delete
find parallel_logs/ -name "*.log" -mtime +7 -delete
```

## 5.7 系统管理命令

### 启动和停止

```bash
# 优雅停止 (Ctrl+C)
# 系统会自动清理所有子进程

# 强制停止所有相关进程
pkill -f "S1S2HiC"
pkill -f "runsh.sh"

# 清理残留进程
ps aux | grep python | grep -v grep | awk '{print $2}' | xargs kill
```

### 资源清理

```bash
# 清理临时文件
bash scripts/clean.sh

# 清理日志文件
rm -f auto_logs/*.log
rm -f parallel_logs/*.log

# 清理结果文件
rm -rf results/processing_output/*
```

### 备份和恢复

```bash
# 备份配置
tar -czf configs_backup_$(date +%Y%m%d).tar.gz configs/

# 备份日志
tar -czf logs_backup_$(date +%Y%m%d).tar.gz auto_logs/ parallel_logs/

# 备份结果
tar -czf results_backup_$(date +%Y%m%d).tar.gz results/
```

## 5.8 常用命令组合

### 开发调试

```bash
# 验证配置并列出组
python3 scripts/config_parser.py my_config.yaml --validate && \
python3 scripts/config_parser.py my_config.yaml --list

# 测试运行（后台）
nohup ./runsh.sh -c my_config.yaml > test_run.log 2>&1 &

# 监控测试
tail -f test_run.log & tail -f parallel_logs/task*_*.log
```

### 生产运行

```bash
# 完整流程
./run_s1s2hic_auto.sh --create-template && \
nano configs/templates/simple_config.conf && \
./run_s1s2hic_auto.sh configs/templates/simple_config.conf

# 批量处理
for config in configs/experiments/*.conf; do
  echo "处理配置: $config"
  ./run_s1s2hic_auto.sh "$config"
done
```

### 系统维护

```bash
# 完整系统检查
bash scripts/check_setup.sh && \
python3 scripts/config_parser.py configs/templates/parallel_config.yaml --validate && \
echo "系统检查完成"

# 日志轮转
mv auto_logs auto_logs_$(date +%Y%m%d) && \
mv parallel_logs parallel_logs_$(date +%Y%m%d) && \
mkdir -p auto_logs parallel_logs
``` 