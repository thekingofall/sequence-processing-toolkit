#!/bin/bash

# 按顺序运行所有5个组的S1S2处理
# 每个组完成后再进行下一个
# 使用方法: ./run_all_groups_sequential.sh [--clean-all]

# 检查是否需要清理所有旧输出
CLEAN_ALL=false
if [ "$1" = "--clean-all" ]; then
    CLEAN_ALL=true
    echo "========================================"
    echo "⚠️  将清理所有组的旧输出文件! ⚠️"
    echo "========================================"
fi

echo "========================================"
echo "S1S2 所有组顺序处理开始"
echo "开始时间: $(date)"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 定义所有组
declare -a ALL_GROUPS=(
    "Group1_MboI_GATC_SeqA"
    "Group2_MboI_GATC_SeqB"
    "Group3_MseI_CviQI_TA_SeqA"
    "Group4_MseI_CviQI_TA_SeqB"
    "Group5_MboI_CviQI_GATC_TA_SeqA"
)

# 记录处理结果
SUCCESS_COUNT=0
declare -a FAILED_GROUPS
declare -a SUCCESS_GROUPS

# 如果需要清理所有旧输出
if [ "$CLEAN_ALL" = true ]; then
    echo ""
    echo "=== 清理所有组的旧输出文件 ==="
    
    for group in "${ALL_GROUPS[@]}"; do
        RESULT_DIR="../results/$group"
        if [ -d "$RESULT_DIR" ] && [ "$(ls -A "$RESULT_DIR" 2>/dev/null)" ]; then
            echo "清理组: $group"
            echo "  目录: $RESULT_DIR"
            
            # 显示要删除的内容大小
            if command -v du >/dev/null 2>&1; then
                SIZE=$(du -sh "$RESULT_DIR" 2>/dev/null | cut -f1)
                echo "  大小: $SIZE"
            fi
            
            # 清理
            rm -rf "${RESULT_DIR}"/*
            
            if [ $? -eq 0 ]; then
                echo "  ✓ 清理完成"
            else
                echo "  ✗ 清理失败"
            fi
        else
            echo "跳过组: $group (无旧输出)"
        fi
    done
    
    echo "✓ 所有旧输出文件清理完成"
    echo ""
fi

echo "将要处理的组:"
for i in "${!ALL_GROUPS[@]}"; do
    echo "  [$((i+1))] ${ALL_GROUPS[$i]}"
done
echo ""

# 逐个处理每个组
for i in "${!ALL_GROUPS[@]}"; do
    GROUP_NAME="${ALL_GROUPS[$i]}"
    GROUP_NUM=$((i+1))
    
    echo ""
    echo "========================================"
    echo "开始处理组 $GROUP_NUM/5: $GROUP_NAME"
    echo "当前时间: $(date)"
    echo "========================================"
    
    # 运行单个组处理脚本 (同目录下的脚本)
    if ./run_single_group.sh "$GROUP_NAME"; then
        echo ""
        echo "✓ 组 $GROUP_NUM ($GROUP_NAME) 处理成功!"
        SUCCESS_GROUPS+=("$GROUP_NAME")
        ((SUCCESS_COUNT++))
        
        # 显示当前结果目录大小
        RESULT_DIR="../results/$GROUP_NAME"
        if [ -d "$RESULT_DIR" ]; then
            echo "结果目录: $RESULT_DIR"
            if command -v du >/dev/null 2>&1; then
                SIZE=$(du -sh "$RESULT_DIR" 2>/dev/null | cut -f1)
                echo "目录大小: $SIZE"
            fi
        fi
    else
        echo ""
        echo "✗ 组 $GROUP_NUM ($GROUP_NAME) 处理失败!"
        FAILED_GROUPS+=("$GROUP_NAME")
        
        # 询问是否继续
        echo ""
        echo "组 $GROUP_NAME 处理失败，是否继续处理下一个组?"
        echo "按Enter继续，按Ctrl+C退出"
        read -r
    fi
    
    echo "========================================"
    echo "组 $GROUP_NUM ($GROUP_NAME) 处理完成"
    echo "当前进度: $((SUCCESS_COUNT + ${#FAILED_GROUPS[@]}))/${#ALL_GROUPS[@]}"
    echo "========================================"
    
    # 如果不是最后一个组，稍作暂停
    if [ $GROUP_NUM -lt ${#ALL_GROUPS[@]} ]; then
        echo ""
        echo "准备处理下一个组 (3秒后开始)..."
        sleep 3
    fi
done

# 生成最终报告
echo ""
echo "========================================"
echo "所有组处理完成报告"
echo "========================================"
echo "完成时间: $(date)"
echo "总组数: ${#ALL_GROUPS[@]}"
echo "成功处理: $SUCCESS_COUNT"
echo "失败处理: ${#FAILED_GROUPS[@]}"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "成功处理的组:"
    for success_group in "${SUCCESS_GROUPS[@]}"; do
        echo "  ✓ $success_group"
    done
    echo ""
fi

if [ ${#FAILED_GROUPS[@]} -gt 0 ]; then
    echo "失败处理的组:"
    for failed_group in "${FAILED_GROUPS[@]}"; do
        echo "  ✗ $failed_group"
    done
    echo ""
fi

# 统计所有结果目录
echo "所有结果目录:"
for group in "${ALL_GROUPS[@]}"; do
    RESULT_DIR="../results/$group"
    if [ -d "$RESULT_DIR" ]; then
        echo "  $group: $RESULT_DIR"
        if command -v du >/dev/null 2>&1; then
            SIZE=$(du -sh "$RESULT_DIR" 2>/dev/null | cut -f1)
            echo "    大小: $SIZE"
        fi
        
        # 统计输出文件
        S1_DIR="$RESULT_DIR/${group}_S1_Output"
        S2_DIR="$RESULT_DIR/${group}_S2_Output"
        
        if [ -d "$S1_DIR" ]; then
            S1_COUNT=$(ls -1 "$S1_DIR"/*.gz 2>/dev/null | wc -l)
            echo "    S1文件: $S1_COUNT 个"
        fi
        
        if [ -d "$S2_DIR" ]; then
            S2_COUNT=$(find "$S2_DIR" -type d -mindepth 1 | wc -l)
            echo "    S2目录: $S2_COUNT 个"
        fi
    else
        echo "  $group: 未处理或失败"
    fi
done

echo ""
echo "========================================"
echo "批量处理完成!"
echo ""

# 返回结果
if [ $SUCCESS_COUNT -eq ${#ALL_GROUPS[@]} ]; then
    echo "🎉 所有组都处理成功!"
    exit 0
elif [ $SUCCESS_COUNT -gt 0 ]; then
    echo "⚠️  部分组处理成功 ($SUCCESS_COUNT/${#ALL_GROUPS[@]})"
    exit 1
else
    echo "❌ 所有组都处理失败"
    exit 2
fi 