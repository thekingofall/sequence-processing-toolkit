# 第三章：通用并行系统详解

> ⚙️ 配置驱动的任意脚本并行执行框架

## 3.1 系统概述

通用并行系统是一个完全解耦的配置驱动框架，可以并行执行任意类型的脚本和任务：
- **零代码修改** - 永远不需要改脚本，只改配置
- **完全解耦** - 支持任意处理脚本和参数
- **极简使用** - 一个命令 + 一个配置文件
- **智能管理** - 自动并行、日志、错误处理、信号处理

## 3.2 核心架构

```
用户配置文件 (YAML)
        ↓
配置解析器 (Python)
        ↓
主控脚本 (Bash)
        ↓
并行任务执行器
```

### 组件说明
- **runsh.sh**: 主控脚本，负责任务调度和并行管理
- **config_parser.py**: 配置解析器，将YAML转换为Bash可用格式
- **配置文件**: YAML格式，定义全局设置和任务组

## 3.3 配置文件结构详解

### 完整配置示例

```yaml
# 全局设置
global_settings:
  script_dir: "auto"                       # 脚本目录
  pipeline_script: "src/main_script.py"   # 主处理脚本
  config_dir: "configs"                    # 配置目录
  log_dir: "parallel_logs"                 # 日志目录
  python_cmd: "python3"                    # Python命令
  pipeline_args: "--verbose --mode fast"   # 脚本参数
  startup_delay: 2                         # 启动间隔（秒）

# 处理组配置
processing_groups:
  task1:                                   # 任务组名
    description: "数据清洗任务"             # 描述
    config_file: "task1.yaml"              # 配置文件
    work_dir: "./data/task1"                # 工作目录
    enabled: true                           # 是否启用
    cleanup_patterns:                       # 清理模式（可选）
      - "temp_*"
      - "*.tmp"
  
  task2:
    description: "特征提取任务"
    config_file: "task2.yaml"
    work_dir: "${DATA_ROOT}/task2"          # 环境变量
    enabled: true
    
  task3:
    description: "模型训练任务" 
    config_file: "task3.yaml"
    work_dir: "~/projects/ml/task3"         # 用户主目录
    enabled: false  # 可以禁用某些任务
```

### 路径配置详解

| 路径类型 | 格式示例 | 说明 |
|----------|----------|------|
| **自动检测** | `script_dir: "auto"` | 自动使用配置文件所在目录 |
| **相对路径** | `work_dir: "./data/task1"` | 相对于当前目录 |
| **用户主目录** | `work_dir: "~/projects/data"` | 用户主目录下的路径 |
| **环境变量** | `work_dir: "${DATA_ROOT}/task"` | 使用环境变量 |
| **环境变量默认值** | `work_dir: "${TMPDIR:-/tmp}/task"` | 环境变量带默认值 |
| **绝对路径** | `work_dir: "/opt/data/task"` | 传统绝对路径 |

## 3.4 支持的脚本类型

### Python脚本
```yaml
global_settings:
  pipeline_script: "process.py"
  python_cmd: "python3"
  pipeline_args: "-c"
```

### Bash脚本
```yaml
global_settings:
  pipeline_script: "process.sh"
  python_cmd: "bash"
  pipeline_args: ""
```

### R脚本
```yaml
global_settings:
  pipeline_script: "analysis.R"
  python_cmd: "Rscript"
  pipeline_args: "--vanilla"
```

### 任意命令
```yaml
global_settings:
  pipeline_script: "custom_command"
  python_cmd: ""
  pipeline_args: "--input"
```

## 3.5 使用场景示例

### 场景1: 数据处理流水线

```yaml
global_settings:
  pipeline_script: "data_processor.py"
  python_cmd: "python3"
  startup_delay: 5

processing_groups:
  clean_data_a:
    description: "清洗数据集A"
    config_file: "clean_config_a.yaml"
    work_dir: "/data/raw/dataset_a"
    enabled: true
    
  clean_data_b:
    description: "清洗数据集B"
    config_file: "clean_config_b.yaml" 
    work_dir: "/data/raw/dataset_b"
    enabled: true
    
  clean_data_c:
    description: "清洗数据集C"
    config_file: "clean_config_c.yaml"
    work_dir: "/data/raw/dataset_c"
    enabled: false  # 暂时跳过
```

### 场景2: 机器学习批处理

```yaml
global_settings:
  pipeline_script: "train_model.py" 
  python_cmd: "python3"
  pipeline_args: "--gpu"

processing_groups:
  model_cnn:
    description: "训练CNN模型"
    config_file: "cnn_config.json"
    work_dir: "${ML_ROOT}/cnn"
    enabled: true
    cleanup_patterns:
      - "checkpoints/temp_*"
      - "logs/*.tmp"
      
  model_lstm:
    description: "训练LSTM模型"
    config_file: "lstm_config.json"
    work_dir: "${ML_ROOT}/lstm"
    enabled: true
    
  model_transformer:
    description: "训练Transformer模型"
    config_file: "transformer_config.json"
    work_dir: "${ML_ROOT}/transformer"
    enabled: true
```

### 场景3: 生物信息学分析

```yaml
global_settings:
  pipeline_script: "bio_analysis.sh"
  python_cmd: "bash"
  startup_delay: 3

processing_groups:
  sample_01:
    description: "样本01基因组分析"
    config_file: "sample01.conf"
    work_dir: "/biodata/samples/sample01"
    enabled: true
    
  sample_02:
    description: "样本02基因组分析"
    config_file: "sample02.conf"
    work_dir: "/biodata/samples/sample02"
    enabled: true
    
  sample_03:
    description: "样本03基因组分析"
    config_file: "sample03.conf"
    work_dir: "/biodata/samples/sample03"
    enabled: true
```

## 3.6 高级功能

### 信号处理
系统支持优雅的中断处理：
- **Ctrl+C**: 优雅终止所有任务
- **自动清理**: 终止所有子进程和进程组
- **状态报告**: 显示任务完成情况

### 日志管理
```
parallel_logs/
├── task1_20250126_143022.log    # 任务独立日志
├── task2_20250126_143024.log
├── task3_20250126_143026.log
└── main_20250126_143020.log     # 主控日志
```

### 错误处理
- **任务隔离**: 单个任务失败不影响其他任务
- **重试机制**: 支持失败任务重试（可配置）
- **详细报告**: 成功/失败统计和详细信息

## 3.7 性能调优

### 并行度控制
```yaml
global_settings:
  startup_delay: 2     # 启动间隔，避免资源竞争
  max_parallel: 4      # 最大并行任务数（计划功能）
```

### 资源监控
```bash
# 查看系统负载
htop

# 查看并行任务状态
ps aux | grep python

# 查看日志
tail -f parallel_logs/task1_*.log
```

### 性能建议
- **I/O密集型**: 可以设置更多并行任务
- **CPU密集型**: 并行数不超过CPU核心数
- **内存密集型**: 根据内存大小限制并行数
- **网络任务**: 考虑带宽限制

## 3.8 与S1S2HiC系统的关系

S1S2HiC系统底层使用通用并行系统架构：
- **S1S2HiC**: 预定义的5个生物信息学组
- **通用系统**: 完全自定义的任意任务组
- **配置转换**: `parallel_config.yaml` 包含S1S2HiC的预设组
- **共存使用**: 两套命令行工具可以同时使用

## 3.9 最佳实践

### 配置文件组织
```
my_project/
├── main_config.yaml           # 主配置文件
├── configs/                   # 任务配置目录
│   ├── task1_config.yaml
│   ├── task2_config.yaml
│   └── task3_config.yaml
├── scripts/                   # 处理脚本
│   └── data_processor.py
└── logs/                     # 日志目录
```

### 开发建议
1. **测试先行**: 先用单个任务测试脚本
2. **渐进并行**: 从2个任务开始，逐步增加
3. **监控资源**: 观察CPU、内存、I/O使用情况
4. **备份重要**: 处理重要数据前先备份
5. **文档记录**: 记录配置文件和参数含义 