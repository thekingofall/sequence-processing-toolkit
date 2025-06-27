#!/bin/bash

# 简化测试脚本 - 只处理第一个组
set -e

echo "========================================"
echo "S1S2HiC 简化测试开始"
echo "处理时间: $(date)"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/configs/Group1_MboI_GATC_SeqA_config.yaml"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo "配置文件: $CONFIG_FILE"

# 读取数据目录
DATA_DIR=$(python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
print(config['advanced_config']['input_data_dir'])
")

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

# 创建工作目录
WORK_DIR="${SCRIPT_DIR}/results/Group1_Test"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "当前工作目录: $(pwd)"

# 直接测试S1脚本
echo ""
echo "=== 测试S1脚本 ==="
S1_SCRIPT="${SCRIPT_DIR}/src/S1_Process_gen.py"
if [ ! -f "$S1_SCRIPT" ]; then
    echo "错误: S1脚本不存在: $S1_SCRIPT"
    exit 1
fi

echo "S1脚本: $S1_SCRIPT"

# 测试S1脚本语法
echo "测试S1脚本语法..."
python3 -m py_compile "$S1_SCRIPT"
echo "S1脚本语法检查通过"

# 简单运行S1帮助信息
echo "测试S1脚本运行..."
python3 "$S1_SCRIPT" --help | head -5

echo ""
echo "=== 基本测试完成 ==="
echo "如果看到这里，说明基本环境配置正确" 