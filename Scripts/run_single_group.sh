#!/bin/bash

# 单个组处理脚本
# 使用方法: ./run_single_group.sh Group1_MboI_GATC_SeqA

if [ $# -eq 0 ]; then
    echo "使用方法: $0 <组名>"
    echo "可用的组:"
    echo "  Group1_MboI_GATC_SeqA"
    echo "  Group2_MboI_GATC_SeqB"
    echo "  Group3_MseI_CviQI_TA_SeqA"
    echo "  Group4_MseI_CviQI_TA_SeqB"
    echo "  Group5_MboI_CviQI_GATC_TA_SeqA"
    exit 1
fi

GROUP_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "开始处理组: $GROUP_NAME"
echo "处理时间: $(date)"
echo "========================================"

# 配置文件路径 (主目录的configs文件夹)
CONFIG_FILE="${SCRIPT_DIR}/../configs/${GROUP_NAME}_config.yaml"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo "配置文件: $CONFIG_FILE"

# 读取数据目录
DATA_DIR=$(python3 -c "
import yaml
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = yaml.safe_load(f)
    print(config['advanced_config']['input_data_dir'])
except Exception as e:
    print('读取配置失败:', e)
    exit(1)
")

if [ -z "$DATA_DIR" ]; then
    echo "错误: 无法从配置文件读取数据目录"
    exit 1
fi

echo "数据目录: $DATA_DIR"

# 检查数据目录
if [ ! -d "$DATA_DIR" ]; then
    echo "错误: 数据目录不存在: $DATA_DIR"
    exit 1
fi

# 检查文件数量
FILE_COUNT=$(ls -1 "${DATA_DIR}"/*.fq.gz 2>/dev/null | wc -l)
echo "输入文件数量: $FILE_COUNT"

if [ $FILE_COUNT -eq 0 ]; then
    echo "错误: 数据目录中没有找到.fq.gz文件"
    exit 1
fi

# 显示输入文件列表
echo "输入文件列表:"
ls -1 "${DATA_DIR}"/*.fq.gz | head -10

if [ $FILE_COUNT -gt 10 ]; then
    echo "... 还有 $((FILE_COUNT - 10)) 个文件"
fi

# 创建工作目录 (主目录的results文件夹)
WORK_DIR="${SCRIPT_DIR}/../results/${GROUP_NAME}"
mkdir -p "$WORK_DIR"

# 清理旧的输出文件
echo ""
echo "=== 清理旧的输出文件 ==="
if [ -d "$WORK_DIR" ] && [ "$(ls -A "$WORK_DIR" 2>/dev/null)" ]; then
    echo "发现旧的输出文件，开始清理..."
    
    # 显示要删除的内容
    echo "将要删除的文件和目录:"
    ls -la "$WORK_DIR" | sed 's/^/  /'
    
    # 清理所有内容
    rm -rf "${WORK_DIR}"/*
    
    if [ $? -eq 0 ]; then
        echo "✓ 旧输出文件清理完成"
    else
        echo "✗ 清理失败，可能存在权限问题"
        exit 1
    fi
else
    echo "无旧输出文件需要清理"
fi

cd "$WORK_DIR"
echo "当前工作目录: $(pwd)"

# 使用S1S2HiC_Pipeline.py (支持配置文件的版本，主目录的src文件夹)
PIPELINE_SCRIPT="${SCRIPT_DIR}/../src/S1S2HiC_Pipeline.py"

if [ ! -f "$PIPELINE_SCRIPT" ]; then
    echo "错误: Pipeline脚本不存在: $PIPELINE_SCRIPT"
    exit 1
fi

echo "使用Pipeline脚本: $PIPELINE_SCRIPT"

# 从配置文件读取参数
echo ""
echo "=== 读取配置参数 ==="
python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)

s1_config = config['S1_config']
s2_config = config['S2_config']

print('S1配置:')
print(f'  模式序列: {s1_config[\"patterns\"]}')
print(f'  描述: {s1_config.get(\"description\", \"N/A\")}')
print(f'  处理行数: {s1_config.get(\"lines_to_process\", \"N/A\")}')
print(f'  并行任务: {s1_config.get(\"jobs\", \"N/A\")}')

print('S2配置:')
print(f'  分隔符1: {s2_config.get(\"separator1\", \"N/A\")}')
print(f'  分隔符2: {s2_config.get(\"separator2\", \"N/A\")}')
print(f'  最小长度: {s2_config.get(\"min_length\", \"N/A\")}')
"

echo ""
echo "=== 开始处理流程 ==="

# 执行S1S2HiC_Pipeline.py (使用配置文件)
echo "执行Pipeline命令:"
PIPELINE_CMD="python3 '$PIPELINE_SCRIPT' --config '$CONFIG_FILE'"
echo "$PIPELINE_CMD"

echo ""
cd "$DATA_DIR"  # 确保在数据目录中执行
if eval "$PIPELINE_CMD"; then
    echo ""
    echo "✓ Pipeline处理成功!"
    
    echo ""
    echo "=== 处理结果检查 ==="
    cd "$WORK_DIR"
    
    # 检查可能的输出目录
    echo "工作目录内容:"
    ls -la
    
    # 查找可能的输出目录
    S1_DIRS=($(find . -type d -name "*S1*" 2>/dev/null))
    S2_DIRS=($(find . -type d -name "*S2*" 2>/dev/null))
    
    if [ ${#S1_DIRS[@]} -gt 0 ]; then
        echo ""
        echo "找到S1输出目录:"
        for dir in "${S1_DIRS[@]}"; do
            echo "  $dir ($(ls "$dir"/*.gz 2>/dev/null | wc -l) 个文件)"
        done
    fi
    
    if [ ${#S2_DIRS[@]} -gt 0 ]; then
        echo ""
        echo "找到S2输出目录:"
        for dir in "${S2_DIRS[@]}"; do
            file_count=$(find "$dir" -name "*.gz" 2>/dev/null | wc -l)
            echo "  $dir ($file_count 个文件)"
        done
    fi
    
    # 查找统计文件
    STATS_FILES=($(find . -name "*.tsv" -o -name "*.stats" -o -name "*统计*" 2>/dev/null))
    if [ ${#STATS_FILES[@]} -gt 0 ]; then
        echo ""
        echo "找到统计文件:"
        for stats_file in "${STATS_FILES[@]}"; do
            echo "  $stats_file"
        done
    fi
    
else
    echo ""
    echo "✗ Pipeline处理失败!"
    
    echo ""
    echo "可能的原因:"
    echo "1. 配置文件格式错误"
    echo "2. 输入文件路径问题"
    echo "3. Python脚本错误"
    echo "4. 权限或磁盘空间问题"
    
    # 检查是否有部分输出
    cd "$WORK_DIR"
    if [ "$(ls -A 2>/dev/null)" ]; then
        echo ""
        echo "工作目录中的部分输出:"
        ls -la
    fi
    
    exit 1
fi

echo ""
echo "========================================"
echo "组 $GROUP_NAME 处理完成!"
echo "完成时间: $(date)"
echo "========================================"
echo "结果目录: $WORK_DIR" 