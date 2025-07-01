# 第七章：故障排除

> 🔧 常见问题诊断和解决方案

## 7.1 问题分类

### 按严重程度分类

| 级别 | 描述 | 影响 | 解决优先级 |
|------|------|------|------------|
| 🔴 **严重** | 系统无法启动 | 完全阻塞 | 立即解决 |
| 🟡 **警告** | 部分功能异常 | 影响效率 | 尽快解决 |
| 🔵 **信息** | 配置建议 | 优化建议 | 可选解决 |

### 按问题类型分类

- **环境问题** - Python、依赖包、权限
- **配置问题** - YAML语法、路径错误、参数错误
- **运行时问题** - 内存不足、磁盘满、网络问题
- **结果问题** - 输出异常、数据丢失、格式错误

## 7.2 环境问题

### 7.2.1 Python环境问题

#### 问题：找不到Python3

**症状**
```bash
./runsh.sh: line 15: python3: command not found
```

**解决方案**
```bash
# 检查Python安装
which python3
which python

# 如果没有python3，创建软链接
sudo ln -s /usr/bin/python /usr/bin/python3

# 或修改配置文件
python_cmd: "python"  # 而不是 "python3"
```

#### 问题：Python版本不兼容

**症状**
```bash
SyntaxError: invalid syntax (f-strings require Python 3.6+)
```

**解决方案**
```bash
# 检查Python版本
python3 --version

# 如果版本过低，安装新版本
# CentOS/RHEL
sudo yum install python36

# Ubuntu/Debian  
sudo apt update && sudo apt install python3.8

# 使用conda安装
conda install python=3.8
```

### 7.2.2 依赖包问题

#### 问题：缺少YAML解析包

**症状**
```bash
ModuleNotFoundError: No module named 'yaml'
```

**解决方案**
```bash
# 安装PyYAML
pip3 install PyYAML

# 或使用conda
conda install pyyaml

# 或使用系统包管理器
sudo yum install python3-yaml
sudo apt install python3-yaml
```

#### 问题：包版本冲突

**症状**
```bash
ImportError: cannot import name 'safe_load' from 'yaml'
```

**解决方案**
```bash
# 检查包版本
pip3 list | grep -i yaml

# 升级到最新版本
pip3 install --upgrade PyYAML

# 或指定特定版本
pip3 install PyYAML==5.4.1
```

### 7.2.3 权限问题

#### 问题：脚本无执行权限

**症状**
```bash
bash: ./runsh.sh: Permission denied
```

**解决方案**
```bash
# 添加执行权限
chmod +x runsh.sh
chmod +x run_s1s2hic_auto.sh
chmod +x scripts/*.py
chmod +x scripts/*.sh

# 或使用bash直接运行
bash runsh.sh -c config.yaml
```

#### 问题：日志目录无写权限

**症状**
```bash
mkdir: cannot create directory 'parallel_logs': Permission denied
```

**解决方案**
```bash
# 检查目录权限
ls -ld parallel_logs auto_logs

# 修改权限
chmod 755 parallel_logs auto_logs

# 或重新创建
sudo rm -rf parallel_logs auto_logs
mkdir -p parallel_logs auto_logs
```

## 7.3 配置问题

### 7.3.1 YAML格式错误

#### 问题：缩进不正确

**症状**
```bash
yaml.scanner.ScannerError: while scanning for the next token
found character '\t' that cannot start any token
```

**解决方案**
```yaml
# ❌ 错误：使用Tab缩进
global_settings:
	script_dir: "auto"

# ✅ 正确：使用空格缩进
global_settings:
  script_dir: "auto"
```

**检查方法**
```bash
# 显示隐藏字符
cat -A config.yaml | head -20

# 使用yamllint检查
pip3 install yamllint
yamllint config.yaml
```

#### 问题：引号使用错误

**症状**
```bash
yaml.scanner.ScannerError: while scanning a quoted scalar
found unexpected end of stream
```

**解决方案**
```yaml
# ❌ 错误：引号不匹配
description: "任务描述

# ✅ 正确：引号匹配
description: "任务描述"

# ❌ 错误：路径包含特殊字符未引用
work_dir: /path/with spaces/task1

# ✅ 正确：使用引号
work_dir: "/path/with spaces/task1"
```

### 7.3.2 路径配置错误

#### 问题：配置文件不存在

**症状**
```bash
错误: 配置文件不存在: config.yaml
```

**解决方案**
```bash
# 检查文件是否存在
ls -la config.yaml

# 检查当前目录
pwd

# 使用绝对路径
./runsh.sh -c /absolute/path/to/config.yaml

# 复制模板
cp configs/templates/blank_config.yaml my_config.yaml
```

#### 问题：工作目录不存在

**症状**
```bash
错误: 工作目录不存在: /nonexistent/path
```

**解决方案**
```bash
# 创建目录
mkdir -p /path/to/workdir

# 检查权限
ls -ld /path/to/workdir

# 使用环境变量
export DATA_ROOT=/existing/path
# 配置文件中使用：
work_dir: "${DATA_ROOT}/task1"
```

### 7.3.3 参数配置错误

#### 问题：布尔值格式错误

**症状**
```bash
错误: enabled参数必须是true或false
```

**解决方案**
```yaml
# ❌ 错误：使用字符串
enabled: "true"
enabled: "false"

# ✅ 正确：使用布尔值
enabled: true
enabled: false
```

#### 问题：必需参数缺失

**症状**
```bash
错误: 缺少必需参数 PROJECT_NAME
```

**解决方案**
```bash
# S1S2HiC配置文件检查必需参数
PROJECT_NAME=my_experiment_20250126  # 必填
GROUPS=1,2,3                        # 必填
DATA_ROOT=/path/to/data             # 必填
```

## 7.4 运行时问题

### 7.4.1 内存问题

#### 问题：内存不足

**症状**
```bash
MemoryError: Unable to allocate array
python: error while loading shared libraries: cannot allocate memory
```

**解决方案**
```bash
# 检查内存使用
free -h
htop

# 减少并行任务数
MAX_PARALLEL=2  # S1S2HiC配置
startup_delay: 10  # 通用系统配置

# 清理内存
sync && echo 3 > /proc/sys/vm/drop_caches

# 增加交换空间
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 7.4.2 磁盘空间问题

#### 问题：磁盘空间不足

**症状**
```bash
OSError: [Errno 28] No space left on device
```

**解决方案**
```bash
# 检查磁盘使用
df -h
du -sh /data/*

# 清理临时文件
bash scripts/clean.sh
rm -rf /tmp/tmp*

# 清理日志文件
find auto_logs/ -name "*.log" -mtime +7 -delete
find parallel_logs/ -name "*.log" -mtime +7 -delete

# 移动数据到其他磁盘
mv /data/large_files /other_disk/
ln -s /other_disk/large_files /data/
```

### 7.4.3 进程问题

#### 问题：进程卡死

**症状**
```bash
# 进程长时间无输出，无响应
```

**解决方案**
```bash
# 查看进程状态
ps aux | grep python
ps aux | grep runsh

# 检查系统负载
top
htop

# 强制终止
killall python3
pkill -f "S1S2HiC"
pkill -f "runsh.sh"

# 清理僵尸进程
ps aux | awk '$8 ~ /^Z/ { print $2 }' | xargs kill -9
```

#### 问题：端口占用

**症状**
```bash
Address already in use: bind
```

**解决方案**
```bash
# 查看端口占用
netstat -tulpn | grep :8080
lsof -i :8080

# 释放端口
kill $(lsof -t -i:8080)

# 更换端口
# 在配置文件中修改端口号
```

## 7.5 结果问题

### 7.5.1 输出文件问题

#### 问题：结果文件为空

**症状**
```bash
# 输出文件存在但大小为0
ls -la results/*.txt
-rw-rw-r-- 1 user user 0 Jan 26 14:30 result.txt
```

**解决方案**
```bash
# 检查日志中的错误信息
grep -i error auto_logs/*.log parallel_logs/*.log

# 检查磁盘空间
df -h

# 检查权限
ls -ld results/

# 重新运行任务
./runsh.sh -c config.yaml
```

#### 问题：输出格式异常

**症状**
```bash
# 输出文件格式不正确，无法解析
```

**解决方案**
```bash
# 检查输入数据格式
head -10 input_file.txt

# 检查脚本参数
grep pipeline_args config.yaml

# 查看详细日志
tail -100 parallel_logs/task1_*.log

# 使用调试模式
pipeline_args: "--verbose --debug"
```

### 7.5.2 数据完整性问题

#### 问题：部分数据丢失

**症状**
```bash
# 预期100个文件，实际只有95个
```

**解决方案**
```bash
# 统计输入文件
find input_dir -name "*.fastq" | wc -l

# 统计输出文件
find output_dir -name "*.result" | wc -l

# 检查失败的任务
grep -i "失败\|failed\|error" auto_logs/*.log

# 重新处理失败的任务
# 根据日志识别失败的组，重新运行
```

## 7.6 性能问题

### 7.6.1 运行速度慢

#### 问题：任务执行缓慢

**诊断步骤**
```bash
# 检查CPU使用率
htop | grep python

# 检查I/O等待
iostat -x 1

# 检查网络I/O
iftop

# 检查进程状态
ps aux | grep python | awk '{print $8}'
```

**优化方案**
```bash
# 调整并行数
MAX_PARALLEL=4  # 根据CPU核心数调整

# 使用SSD存储
export TMPDIR=/fast/ssd/tmp

# 优化启动间隔
startup_delay: 1  # 减少等待时间

# 使用更快的网络
# 检查网络延迟
ping data_server
```

### 7.6.2 内存使用过高

#### 问题：内存持续增长

**诊断步骤**
```bash
# 持续监控内存
watch -n 5 'free -h && ps aux --sort=-%mem | head -10'

# 检查内存泄漏
valgrind --tool=memcheck python3 script.py
```

**解决方案**
```bash
# 分批处理数据
# 将大文件分割成小文件

# 限制并行数
MAX_PARALLEL=2

# 定期重启
# 在配置中添加重启逻辑

# 使用内存映射
# 修改脚本使用mmap
```

## 7.7 调试技巧

### 7.7.1 日志分析

**快速定位错误**
```bash
# 搜索错误关键词
grep -rn -i "error\|failed\|exception" auto_logs/ parallel_logs/

# 按时间排序查看最新日志
ls -lt auto_logs/*.log | head -5

# 实时监控日志
tail -f auto_logs/auto_run_*.log

# 过滤有用信息
grep -v "DEBUG\|INFO" parallel_logs/task1_*.log
```

**日志分析脚本**
```bash
#!/bin/bash
# log_analyzer.sh
echo "=== 错误统计 ==="
grep -c -i error auto_logs/*.log parallel_logs/*.log

echo "=== 完成任务统计 ==="
grep -c "处理成功完成" auto_logs/*.log

echo "=== 最近错误 ==="
grep -i error auto_logs/*.log parallel_logs/*.log | tail -10
```

### 7.7.2 调试模式

**启用详细输出**
```yaml
# 配置文件中启用调试
global_settings:
  pipeline_args: "--verbose --debug"
```

**逐步调试**
```bash
# 单独运行一个任务
python3 src/S1S2HiC_Pipeline.py -c configs/Group1_config.yaml --debug

# 使用Python调试器
python3 -m pdb src/S1S2HiC_Pipeline.py -c config.yaml

# bash脚本调试
bash -x runsh.sh -c config.yaml
```

### 7.7.3 性能分析

**时间分析**
```bash
# 测量执行时间
time ./runsh.sh -c config.yaml

# 分析各步骤耗时
python3 -m cProfile -o profile.stats src/script.py
```

**资源监控**
```bash
# 持续监控资源使用
nohup sh -c 'while true; do 
  echo "$(date): $(free -h | grep Mem) $(df -h | grep /data)" 
  sleep 60
done' > resource_monitor.log &
```

## 7.8 常见问题FAQ

### Q1: 配置文件验证失败怎么办？

**A:** 
```bash
# 1. 检查YAML语法
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"

# 2. 使用在线YAML验证器
# 访问 https://yaml-online-parser.appspot.com/

# 3. 对比工作的配置文件
diff -u working_config.yaml broken_config.yaml
```

### Q2: 任务启动后立即失败？

**A:**
```bash
# 1. 检查日志开头的错误信息
head -50 parallel_logs/task1_*.log

# 2. 验证工作目录和配置文件
ls -la /path/to/workdir
ls -la configs/task1_config.yaml

# 3. 手动运行命令测试
cd /path/to/workdir
python3 /path/to/script.py -c /path/to/config.yaml
```

### Q3: 如何恢复被中断的任务？

**A:**
```bash
# 1. 检查哪些任务已完成
grep "处理成功完成" auto_logs/*.log

# 2. 清理失败任务的临时文件
bash scripts/clean.sh

# 3. 重新运行未完成的任务
# 修改配置文件，只启用未完成的任务
enabled: false  # 已完成的任务
enabled: true   # 未完成的任务
```

### Q4: 系统资源不足怎么优化？

**A:**
```bash
# 1. 减少并行任务数
MAX_PARALLEL=1

# 2. 增加启动间隔
startup_delay: 10

# 3. 分批处理
# 将大的配置文件拆分成多个小配置文件

# 4. 使用更快的存储
ln -s /fast/ssd/workspace /slow/disk/workspace
```

### Q5: 结果不符合预期？

**A:**
```bash
# 1. 对比输入和输出文件数量
find input_dir -name "*.fastq" | wc -l
find output_dir -name "*.result" | wc -l

# 2. 检查中间结果
ls -la intermediate_output/

# 3. 验证配置参数
grep -E "(enzyme|threshold|filter)" config.yaml

# 4. 使用样本数据测试
# 先用小样本数据验证流程正确性
``` 