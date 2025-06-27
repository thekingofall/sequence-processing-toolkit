#!/bin/bash

# 单个组完整处理脚本（包含HiC-Pro流程）
# 使用方法: ./run_single_group_with_hic.sh Group1_MboI_GATC_SeqA

if [ $# -eq 0 ]; then
    echo "使用方法: $0 <组名>"
    echo "可用的组:"
    echo "  Group1_MboI_GATC_SeqA"
    echo "  Group2_MboI_GATC_SeqB"
    echo "  Group3_MseI_CviQI_TA_SeqA"
    echo "  Group4_MseI_CviQI_TA_SeqB"
    echo "  Group5_MboI_CviQI_GATC_TA_SeqA"
    echo ""
    echo "⚠️  注意：此脚本将运行完整的S1→S2→HiC-Pro流程"
    echo "   确保HiC-Pro环境已正确配置"
    exit 1
fi

GROUP_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "开始完整处理组: $GROUP_NAME"
echo "包含: S1序列匹配 → S2分割 → HiC-Pro分析"
echo "处理时间: $(date)"
echo "========================================"

# 配置文件路径
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

# 检查HiC-Pro环境
echo ""
echo "=== 检查HiC-Pro环境 ==="
if command -v HiC-Pro >/dev/null 2>&1; then
    echo "✓ 找到HiC-Pro: $(which HiC-Pro)"
    HiC-Pro --version 2>/dev/null || echo "HiC-Pro版本信息获取失败"
else
    echo "⚠️  警告: 未找到HiC-Pro命令"
    echo "请确保HiC-Pro已安装并在PATH中"
    echo ""
    read -p "是否继续? (y/N): " continue_choice
    if [ "$continue_choice" != "y" ] && [ "$continue_choice" != "Y" ]; then
        echo "退出处理"
        exit 1
    fi
fi

# 创建工作目录
WORK_DIR="${SCRIPT_DIR}/../results/${GROUP_NAME}"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo ""
echo "当前工作目录: $(pwd)"

# 使用完整的S1S2HiC_Pipeline.py
PIPELINE_SCRIPT="${SCRIPT_DIR}/../src/S1S2HiC_Pipeline.py"

if [ ! -f "$PIPELINE_SCRIPT" ]; then
    echo "错误: Pipeline脚本不存在: $PIPELINE_SCRIPT"
    exit 1
fi

echo "使用Pipeline脚本: $PIPELINE_SCRIPT"

# 从配置文件读取HiC配置
echo ""
echo "=== 读取HiC配置参数 ==="
python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)

s1_config = config['S1_config']
s2_config = config['S2_config']
hic_config = config['HiC_config']

print('S1配置:')
print(f'  模式序列: {s1_config[\"patterns\"]}')
print(f'  处理行数: {s1_config.get(\"lines_to_process\", \"N/A\")}')

print('S2配置:')
print(f'  分隔符1: {s2_config.get(\"separator1\", \"N/A\")}')
print(f'  分隔符2: {s2_config.get(\"separator2\", \"N/A\")}')

print('HiC配置:')
print(f'  项目名称: {hic_config.get(\"project_name\", \"N/A\")}')
print(f'  配置类型: {hic_config.get(\"config_type\", \"N/A\")}')
print(f'  CPU核心数: {hic_config.get(\"cpu_count\", \"N/A\")}')
print(f'  Conda环境: {hic_config.get(\"conda_env\", \"N/A\")}')
"

echo ""
echo "=== 开始完整处理流程 ==="

# 执行完整的S1S2HiC_Pipeline.py
echo "执行完整Pipeline命令:"
PIPELINE_CMD="python3 '$PIPELINE_SCRIPT' --config '$CONFIG_FILE'"
echo "$PIPELINE_CMD"

echo ""
cd "$DATA_DIR"  # 确保在数据目录中执行
if eval "$PIPELINE_CMD"; then
    echo ""
    echo "🎉 完整Pipeline处理成功!"
    
    echo ""
    echo "=== 最终结果检查 ==="
    cd "$WORK_DIR"
    
    # 检查所有输出目录
    echo "工作目录内容:"
    ls -la
    
    # 查找HiC-Pro输出
    HIC_DIRS=($(find . -type d -name "*hic*" -o -name "*HiC*" 2>/dev/null))
    if [ ${#HIC_DIRS[@]} -gt 0 ]; then
        echo ""
        echo "🧬 找到HiC-Pro输出目录:"
        for dir in "${HIC_DIRS[@]}"; do
            echo "  $dir"
        done
    fi
    
    echo ""
    echo "📊 处理结果摘要:"
    echo "  ✓ S1: 序列模式匹配完成"
    echo "  ✓ S2: FASTQ文件分割完成"
    echo "  ✓ HiC: Hi-C数据分析完成"
    
else
    echo ""
    echo "❌ 完整Pipeline处理失败!"
    echo ""
    echo "可能的原因:"
    echo "1. HiC-Pro环境配置问题"
    echo "2. 内存或CPU资源不足"
    echo "3. 配置文件中HiC参数错误"
    echo "4. 输入数据格式问题"
    
    exit 1
fi

echo ""
echo "========================================"
echo "🎉 组 $GROUP_NAME 完整处理成功!"
echo "完成时间: $(date)"
echo "========================================"
echo "结果目录: $WORK_DIR"
echo ""
echo "📁 主要输出:"
echo "  📊 S1结果: $DATA_DIR/Group1_S1_Linker_Separated/"
echo "  ✂️ S2结果: $DATA_DIR/Group1_S2_Enzyme_Split/"  
echo "  🧬 HiC结果: 请查看工作目录中的HiC-Pro输出" 