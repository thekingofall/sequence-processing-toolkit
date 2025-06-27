#!/bin/bash

# 清理S1S2HiC处理结果脚本
# 使用方法: 
#   ./clean_results.sh                    # 交互式清理
#   ./clean_results.sh --all              # 清理所有组
#   ./clean_results.sh Group1_MboI_GATC_SeqA  # 清理指定组

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

# 清理单个组的函数
clean_group() {
    local group_name="$1"
    local result_dir="../results/$group_name"
    
    if [ ! -d "$result_dir" ]; then
        echo "  跳过 $group_name: 目录不存在"
        return 0
    fi
    
    if [ ! "$(ls -A "$result_dir" 2>/dev/null)" ]; then
        echo "  跳过 $group_name: 目录为空"
        return 0
    fi
    
    echo "  清理 $group_name:"
    echo "    目录: $result_dir"
    
    # 显示目录大小
    if command -v du >/dev/null 2>&1; then
        local size=$(du -sh "$result_dir" 2>/dev/null | cut -f1)
        echo "    大小: $size"
    fi
    
    # 显示内容概览
    local files_count=$(find "$result_dir" -type f 2>/dev/null | wc -l)
    local dirs_count=$(find "$result_dir" -type d -mindepth 1 2>/dev/null | wc -l)
    echo "    内容: $files_count 个文件, $dirs_count 个子目录"
    
    # 执行清理
    rm -rf "${result_dir}"/*
    
    if [ $? -eq 0 ]; then
        echo "    ✓ 清理完成"
        return 0
    else
        echo "    ✗ 清理失败"
        return 1
    fi
}

# 显示当前结果状态
show_current_status() {
    echo "========================================"
    echo "当前结果目录状态"
    echo "========================================"
    
    local total_size=0
    local has_results=false
    
    for group in "${ALL_GROUPS[@]}"; do
        local result_dir="../results/$group"
        if [ -d "$result_dir" ] && [ "$(ls -A "$result_dir" 2>/dev/null)" ]; then
            has_results=true
            echo "📁 $group:"
            
            if command -v du >/dev/null 2>&1; then
                local size=$(du -sh "$result_dir" 2>/dev/null | cut -f1)
                local size_bytes=$(du -sb "$result_dir" 2>/dev/null | cut -f1)
                echo "   大小: $size"
                total_size=$((total_size + size_bytes))
            fi
            
            # 统计文件和目录
            local files_count=$(find "$result_dir" -type f 2>/dev/null | wc -l)
            local dirs_count=$(find "$result_dir" -type d -mindepth 1 2>/dev/null | wc -l)
            echo "   内容: $files_count 个文件, $dirs_count 个子目录"
            
            # 检查主要输出目录
            local s1_dir="$result_dir"/*S1*
            local s2_dir="$result_dir"/*S2*
            if [ -d $s1_dir ] 2>/dev/null; then
                local s1_files=$(ls -1 $s1_dir/*.gz 2>/dev/null | wc -l)
                echo "   S1输出: $s1_files 个文件"
            fi
            if [ -d $s2_dir ] 2>/dev/null; then
                local s2_subdirs=$(find $s2_dir -type d -mindepth 1 2>/dev/null | wc -l)
                echo "   S2输出: $s2_subdirs 个子目录"
            fi
        else
            echo "📂 $group: 无输出或目录为空"
        fi
    done
    
    if [ "$has_results" = true ]; then
        echo ""
        if command -v numfmt >/dev/null 2>&1; then
            local total_human=$(echo $total_size | numfmt --to=iec-i --suffix=B)
            echo "总占用空间: $total_human"
        else
            echo "总占用空间: $total_size 字节"
        fi
    else
        echo ""
        echo "没有找到任何输出文件"
    fi
    echo ""
}

# 主程序
main() {
    echo "========================================"
    echo "S1S2HiC 结果清理工具"
    echo "========================================"
    
    # 显示当前状态
    show_current_status
    
    # 处理命令行参数
    case "$1" in
        "--all")
            echo "开始清理所有组的输出文件..."
            echo ""
            
            local success_count=0
            local failed_count=0
            
            for group in "${ALL_GROUPS[@]}"; do
                if clean_group "$group"; then
                    ((success_count++))
                else
                    ((failed_count++))
                fi
            done
            
            echo ""
            echo "清理完成: $success_count 成功, $failed_count 失败"
            ;;
            
        "")
            # 交互式模式
            echo "请选择清理模式:"
            echo "1) 清理所有组"
            echo "2) 选择特定组清理"
            echo "3) 退出"
            echo ""
            read -p "请输入选择 (1-3): " choice
            
            case "$choice" in
                1)
                    echo ""
                    echo "⚠️  确认要清理所有组的输出文件吗? (y/N)"
                    read -p "输入 y 确认: " confirm
                    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                        echo ""
                        echo "开始清理所有组..."
                        for group in "${ALL_GROUPS[@]}"; do
                            clean_group "$group"
                        done
                    else
                        echo "取消清理"
                    fi
                    ;;
                2)
                    echo ""
                    echo "可用的组:"
                    for i in "${!ALL_GROUPS[@]}"; do
                        echo "  [$((i+1))] ${ALL_GROUPS[$i]}"
                    done
                    echo ""
                    read -p "请输入组编号 (1-${#ALL_GROUPS[@]}): " group_num
                    
                    if [[ "$group_num" =~ ^[1-5]$ ]]; then
                        local group_name="${ALL_GROUPS[$((group_num-1))]}"
                        echo ""
                        echo "确认要清理组 $group_name 吗? (y/N)"
                        read -p "输入 y 确认: " confirm
                        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                            clean_group "$group_name"
                        else
                            echo "取消清理"
                        fi
                    else
                        echo "无效的组编号"
                    fi
                    ;;
                3|*)
                    echo "退出"
                    exit 0
                    ;;
            esac
            ;;
            
        *)
            # 指定组名
            local group_name="$1"
            local valid_group=false
            
            for group in "${ALL_GROUPS[@]}"; do
                if [ "$group" = "$group_name" ]; then
                    valid_group=true
                    break
                fi
            done
            
            if [ "$valid_group" = true ]; then
                echo "清理指定组: $group_name"
                clean_group "$group_name"
            else
                echo "错误: 无效的组名 '$group_name'"
                echo ""
                echo "可用的组:"
                for group in "${ALL_GROUPS[@]}"; do
                    echo "  $group"
                done
                exit 1
            fi
            ;;
    esac
    
    echo ""
    echo "========================================"
    echo "清理操作完成"
    echo "========================================"
}

# 运行主程序
main "$@" 