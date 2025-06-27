#!/bin/bash

# S1S2 串联处理流程示例脚本
# 作者: 序列处理工具包
# 日期: $(date +%Y-%m-%d)

echo "================================================"
echo "S1S2 串联处理流程示例"
echo "================================================"

# 设置基本参数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
S1S2_SCRIPT="${SCRIPT_DIR}/S1S2_Pipeline.py"

# 检查脚本是否存在
if [ ! -f "$S1S2_SCRIPT" ]; then
    echo "错误: 找不到S1S2串联脚本: $S1S2_SCRIPT"
    exit 1
fi

# 示例1: 基本用法
echo "示例1: 基本S1S2串联处理"
echo "----------------------------------------"
echo "命令:"
echo "python3 $S1S2_SCRIPT \\"
echo "    -p \"ATCG,GCTA\" \\"
echo "    -d \"测试序列组合\" \\"
echo "    -i \"*.fq.gz\" \\"
echo "    -N 50000 \\"
echo "    --s1-output-dir \"S1_Results\" \\"
echo "    --s2-output-dir \"S2_Results\""
echo ""

# 示例2: 自定义分隔符
echo "示例2: 使用自定义分隔符"
echo "----------------------------------------"
echo "命令:"
echo "python3 $S1S2_SCRIPT \\"
echo "    -p \"ATCGATCG,GCTAGCTA\" \\"
echo "    -d \"自定义序列\" \\"
echo "    --sep1 \"GATCATGTCGGAACTGTTGCTTGTCCGACTGATC\" \\"
echo "    --sep2 \"AGATCGGAAGA\" \\"
echo "    --min-length 15"
echo ""

# 示例3: 只运行S2步骤（跳过S1）
echo "示例3: 跳过S1，只运行S2"
echo "----------------------------------------"
echo "命令:"
echo "python3 $S1S2_SCRIPT \\"
echo "    -p \"placeholder\" \\"
echo "    --skip-s1 \\"
echo "    --s1-output-dir \"existing_S1_results\" \\"
echo "    --s2-output-dir \"new_S2_results\""
echo ""

# 示例4: 高性能处理
echo "示例4: 高性能并行处理"
echo "----------------------------------------"
echo "命令:"
echo "python3 $S1S2_SCRIPT \\"
echo "    -p \"ATCG,GCTA,TGCA\" \\"
echo "    -d \"三序列组合\" \\"
echo "    -N all \\"
echo "    -j 8 \\"
echo "    --s1-output-dir \"S1_Full\" \\"
echo "    --s2-output-dir \"S2_Full\""
echo ""

# 实际运行示例（如果有测试数据）
echo "================================================"
echo "实际运行测试（如果当前目录有.gz文件）"
echo "================================================"

# 检查当前目录是否有.gz测试文件
if ls *.gz 1> /dev/null 2>&1; then
    echo "发现.gz文件，运行测试示例..."
    
    # 创建一个小规模的测试
    echo "运行命令:"
    echo "python3 $S1S2_SCRIPT -p \"ATCG,GCTA\" -d \"测试\" -N 10000 --s1-output-dir \"test_S1\" --s2-output-dir \"test_S2\""
    
    # 询问用户是否运行
    read -p "是否运行此测试？(y/N): " run_test
    if [[ $run_test =~ ^[Yy]$ ]]; then
        python3 "$S1S2_SCRIPT" \
            -p "ATCG,GCTA" \
            -d "测试运行" \
            -N 10000 \
            --s1-output-dir "test_S1" \
            --s2-output-dir "test_S2"
        
        echo ""
        echo "测试完成！检查输出目录："
        echo "- S1结果: test_S1/"
        echo "- S2结果: test_S2/"
    else
        echo "跳过测试运行"
    fi
else
    echo "未发现.gz文件，跳过实际测试"
    echo "要运行实际测试，请："
    echo "1. 将.fq.gz或.fastq.gz文件放在当前目录"
    echo "2. 重新运行此示例脚本"
fi

echo ""
echo "================================================"
echo "使用说明"
echo "================================================"
echo "1. S1步骤: 筛选包含指定序列模式的reads"
echo "2. S2步骤: 将筛选的reads按分隔符分割为R1/R2配对"
echo "3. 输出: 每个输入文件生成对应的R1和R2配对文件"
echo ""
echo "重要参数:"
echo "  -p: 搜索的序列模式（逗号分隔）"
echo "  -N: 处理行数（'all'表示全部）"
echo "  -j: 并行任务数"
echo "  --sep1/--sep2: S2分割的分隔符序列"
echo "  --skip-s1: 跳过S1直接运行S2"
echo ""
echo "输出文件结构:"
echo "S2_Results/"
echo "├── 文件1_base/"
echo "│   ├── 文件1_base_R1.fq.gz"
echo "│   ├── 文件1_base_R2.fq.gz"
echo "│   └── 文件1_base_discarded.fq.gz"
echo "├── 文件2_base/"
echo "│   ├── ..."
echo "└── S1S2_Pipeline_Report_YYYYMMDD_HHMMSS.txt"
echo ""
echo "================================================" 