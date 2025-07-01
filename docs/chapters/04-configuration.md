# 第四章：配置文件详解

> 🛠️ 深入理解配置文件格式和高级配置技巧

## 4.1 配置模板总览

系统提供4种配置模板：

| 模板文件 | 用途 | 适用用户 |
|----------|------|----------|
| `parallel_config.yaml` | S1S2HiC预设组 | 生物信息学+通用系统用户 |
| `example_config.yaml` | 通用示例 | 通用系统新手用户 |
| `blank_config.yaml` | 空白模板 | 完全自定义用户 |
| `simple_config.conf` | S1S2HiC专用 | 纯生物信息学用户 |

## 4.2 S1S2HiC配置文件 (simple_config.conf)

### 基本格式

```bash
# =============================================================================
# S1S2HiC 自动化处理配置文件
# =============================================================================

# 项目名称（必填）
PROJECT_NAME=my_s1s2hic_experiment_20250126

# 要处理的组（必填）
GROUPS=1,2,3,4,5

# 数据根目录（必填）
DATA_ROOT=/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups

# 最大并行任务数（可选）
MAX_PARALLEL=3

# 输出根目录（可选）
OUTPUT_ROOT=/path/to/output

# 邮件通知（可选）
EMAIL_NOTIFY=your@email.com

# 清理选项（可选）
CLEANUP_TEMP=false

# 重试选项（可选）
RETRY_COUNT=1
```

### 参数详解

#### 必填参数

**PROJECT_NAME**
- **作用**: 项目标识符，用于日志文件命名
- **格式**: 字符串，建议包含日期
- **示例**: `my_hic_analysis_20250126`

**GROUPS**
- **作用**: 指定要处理的实验组
- **格式**: 数字1-5，用逗号分隔
- **示例**: 
  - `GROUPS=1,2,3,4,5` (全部组)
  - `GROUPS=2` (仅Group2)
  - `GROUPS=1,3,5` (指定组)

**DATA_ROOT**
- **作用**: 包含各组数据目录的根目录
- **格式**: 绝对路径
- **要求**: 目录下必须包含 `Group*_*/` 子目录

#### 可选参数

**MAX_PARALLEL**
- **作用**: 最大并行任务数
- **默认**: 自动检测CPU核心数
- **建议**: CPU核心数的70%

**OUTPUT_ROOT**
- **作用**: 统一输出目录
- **默认**: 各组工作目录
- **用途**: 集中管理输出结果

**EMAIL_NOTIFY**
- **作用**: 完成后邮件通知
- **格式**: 邮箱地址
- **要求**: 系统需配置sendmail

**CLEANUP_TEMP**
- **作用**: 成功后清理临时文件
- **值**: true/false
- **默认**: false

**RETRY_COUNT**
- **作用**: 失败重试次数
- **默认**: 1
- **范围**: 0-5

## 4.3 通用系统配置文件 (YAML格式)

### 完整配置结构

```yaml
# 全局配置段
global_settings:
  script_dir: "auto"
  pipeline_script: "src/S1S2HiC_Pipeline.py"
  config_dir: "configs"
  log_dir: "parallel_logs"
  python_cmd: "python3"
  pipeline_args: "--skip-trim"
  startup_delay: 2

# 任务组配置段
processing_groups:
  group1:
    description: "任务描述"
    config_file: "task_config.yaml"
    work_dir: "/path/to/workdir"
    enabled: true
    cleanup_patterns:
      - "temp_*"
      - "*.tmp"
```

### global_settings详解

**script_dir**
- **作用**: 脚本目录路径
- **选项**:
  - `"auto"` - 自动检测（推荐）
  - `"/absolute/path"` - 绝对路径
  - `"./relative/path"` - 相对路径

**pipeline_script**
- **作用**: 主处理脚本路径
- **相对于**: script_dir
- **支持**: Python/Bash/R/任意可执行文件

**config_dir**
- **作用**: 配置文件目录
- **相对于**: script_dir
- **用于**: 查找任务组配置文件

**log_dir**
- **作用**: 日志输出目录
- **默认**: "parallel_logs"
- **自动创建**: 如果不存在

**python_cmd**
- **作用**: Python解释器命令
- **常用值**:
  - `"python3"` - 系统Python3
  - `"python"` - 系统Python
  - `"/usr/bin/python3"` - 特定路径
  - `"conda run -n myenv python"` - Conda环境

**pipeline_args**
- **作用**: 传递给脚本的参数
- **格式**: 字符串
- **示例**: `"--verbose --mode fast --gpu"`

**startup_delay**
- **作用**: 任务启动间隔（秒）
- **目的**: 避免资源竞争
- **建议**: 1-5秒

### processing_groups详解

**组名 (如group1)**
- **作用**: 任务组标识符
- **要求**: 唯一，不含空格
- **用于**: 日志文件命名

**description**
- **作用**: 任务描述
- **用于**: 日志显示和帮助信息

**config_file**
- **作用**: 任务专用配置文件
- **查找路径**: config_dir/config_file
- **格式**: 任意格式（YAML/JSON/CONF等）

**work_dir**
- **作用**: 任务工作目录
- **要求**: 必须存在
- **支持**: 环境变量、~扩展

**enabled**
- **作用**: 是否启用此任务
- **值**: true/false
- **用途**: 临时禁用某些任务

**cleanup_patterns** (可选)
- **作用**: 任务开始前清理的文件模式
- **格式**: 字符串列表
- **支持**: shell通配符

## 4.4 路径配置高级技巧

### 环境变量使用

```yaml
processing_groups:
  task1:
    work_dir: "${DATA_ROOT}/experiment1"
    # 使用环境变量DATA_ROOT
    
  task2:
    work_dir: "${TMPDIR:-/tmp}/task2"
    # 使用TMPDIR，如果未设置则使用/tmp
    
  task3:
    work_dir: "${HOME}/projects/${PROJECT_NAME}"
    # 组合多个环境变量
```

### 路径最佳实践

```yaml
# ✅ 推荐做法
global_settings:
  script_dir: "auto"                    # 自动检测
  
processing_groups:
  task1:
    work_dir: "./data/task1"            # 相对路径
  task2:
    work_dir: "~/experiments/task2"     # 用户主目录
  task3:
    work_dir: "${WORK_ROOT}/task3"      # 环境变量

# ❌ 不推荐做法  
global_settings:
  script_dir: "/home/user/project"      # 硬编码绝对路径
  
processing_groups:
  task1:
    work_dir: "/home/user/data/task1"   # 不便移植
```

## 4.5 高级配置技巧

### 条件启用任务

```yaml
# 开发阶段：只启用测试任务
processing_groups:
  quick_test:
    description: "快速测试"
    enabled: true
    
  full_analysis:
    description: "完整分析"
    enabled: false    # 开发时禁用

# 生产阶段：启用所有任务
processing_groups:
  quick_test:
    enabled: false    # 生产时禁用测试
    
  full_analysis:
    enabled: true
```

### 分环境配置

**开发环境 (dev_config.yaml)**
```yaml
global_settings:
  log_dir: "dev_logs"
  startup_delay: 1
  
processing_groups:
  test_small:
    description: "小数据集测试"
    work_dir: "./test_data"
    enabled: true
```

**生产环境 (prod_config.yaml)**
```yaml
global_settings:
  log_dir: "production_logs"
  startup_delay: 5
  
processing_groups:
  full_dataset:
    description: "完整数据集处理"
    work_dir: "/data/production"
    enabled: true
```

### 脚本参数传递

```yaml
global_settings:
  pipeline_args: "--config ${CONFIG_FILE} --threads 4 --memory 8G"

# 运行时CONFIG_FILE会被替换为实际的配置文件路径
```

## 4.6 配置验证

### 使用配置验证器

```bash
# 验证YAML语法
python3 scripts/config_parser.py my_config.yaml --validate

# 检查文件路径
python3 scripts/config_parser.py my_config.yaml --check-paths

# 列出所有组
python3 scripts/config_parser.py my_config.yaml --list
```

### 常见配置错误

**YAML语法错误**
```yaml
# ❌ 错误：缩进不一致
global_settings:
  script_dir: "auto"
   pipeline_script: "script.py"  # 错误缩进

# ✅ 正确：使用一致的缩进
global_settings:
  script_dir: "auto"
  pipeline_script: "script.py"
```

**路径错误**
```yaml
# ❌ 错误：路径不存在
processing_groups:
  task1:
    work_dir: "/nonexistent/path"

# ✅ 正确：确保路径存在
processing_groups:
  task1:
    work_dir: "${DATA_ROOT}/existing_path"
```

**参数类型错误**
```yaml
# ❌ 错误：布尔值用引号
processing_groups:
  task1:
    enabled: "true"  # 错误：应该是布尔值

# ✅ 正确：直接使用布尔值
processing_groups:
  task1:
    enabled: true
```

## 4.7 配置文件模板选择指南

### 选择决策树

```
你是什么用户？
├── 纯生物信息学用户
│   └── 使用 simple_config.conf
├── 需要S1S2HiC + 自定义任务
│   └── 使用 parallel_config.yaml
├── 通用脚本用户（新手）
│   └── 使用 example_config.yaml
└── 完全自定义用户
    └── 使用 blank_config.yaml
```

### 快速上手建议

1. **第一次使用**: 选择 `example_config.yaml`
2. **熟悉后**: 复制 `blank_config.yaml` 自定义
3. **生物信息学**: 直接用 `simple_config.conf`
4. **混合需求**: 基于 `parallel_config.yaml` 修改 