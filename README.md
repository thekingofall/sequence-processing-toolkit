# 🧬 S1S2HiC 序列处理工具包

## 功能

1. **S1S2HiC数据分析** - 生物信息学Hi-C数据处理
2. **通用并行处理** - 任意脚本并行执行

## 使用方法

### S1S2HiC数据分析

```bash
# 1. 创建配置
./run_s1s2hic_auto.sh --create-template

# 2. 编辑配置
nano simple_config.conf
# 修改: PROJECT_NAME, GROUPS, DATA_ROOT

# 3. 运行
./run_s1s2hic_auto.sh simple_config.conf
```

### 通用并行处理

```bash
# 使用预设S1S2HiC组
./runsh.sh -c parallel_config.yaml

# 完全自定义
cp blank_config.yaml my_config.yaml
vim my_config.yaml
./runsh.sh -c my_config.yaml
```

## S1S2HiC组类型

| 组号 | 酶切类型 | 样本数 | 说明 |
|------|----------|--------|------|
| Group1 | MboI+GATC+SeqA | 3 | 标准实验 |
| Group2 | MboI+GATC+SeqB | 1 | 对照组(最快) |
| Group3 | MseI+CviQI+TA+SeqA | 3 | 双酶切 |
| Group4 | MseI+CviQI+TA+SeqB | 1 | 双酶切对照 |
| Group5 | MboI+CviQI+GATC+TA+SeqA | 1 | 多酶切 |

## 配置文件格式

```yaml
global_settings:
  script_dir: "auto"
  pipeline_script: "your_script.py"
  python_cmd: "python3"

processing_groups:
  task1:
    description: "任务描述"
    config_file: "task1.conf"
    work_dir: "./data/task1"
    enabled: true
```

## 主要命令

```bash
# 帮助
./runsh.sh -h
./run_s1s2hic_auto.sh --help

# 列出组
./runsh.sh -l -c configs/templates/parallel_config.yaml

# 验证配置
python3 scripts/config_parser.py configs/templates/parallel_config.yaml --validate

# 创建S1S2HiC配置模板
./run_s1s2hic_auto.sh --create-template
```

## 文件结构

```
sequence-processing-toolkit/
├── runsh.sh                    # 通用并行处理主脚本
├── run_s1s2hic_auto.sh        # S1S2HiC自动化脚本
├── configs/                   # 配置文件目录
│   ├── templates/            # 配置模板
│   │   ├── parallel_config.yaml
│   │   ├── blank_config.yaml
│   │   ├── example_config.yaml
│   │   └── simple_config.conf
│   ├── environments/         # 环境配置
│   └── Group*_config.yaml   # S1S2HiC组配置
├── scripts/                  # 辅助脚本
│   ├── config_parser.py     # 配置解析器
│   ├── run_group_parallel.sh # 原始并行脚本
│   └── check_setup.sh       # 环境检查
├── src/                     # 源代码
├── auto_logs/              # S1S2HiC日志
└── parallel_logs/          # 并行处理日志
```

## 输出

- **S1S2HiC**: `auto_logs/`, 数据目录下的结果文件
- **通用系统**: `parallel_logs/`, 各工作目录下的输出 