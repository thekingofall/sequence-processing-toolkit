#!/bin/bash

# =============================================================================
# S1S2HiC 环境检查脚本
# 使用方法: ./check_setup.sh
# =============================================================================

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色输出函数
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
blue() { echo -e "\033[34m$1\033[0m"; }
bold() { echo -e "\033[1m$1\033[0m"; }

# 显示横幅
show_banner() {
    echo "════════════════════════════════════════════════════════════════"
    echo "$(bold "🔧 S1S2HiC 环境检查工具 v${VERSION}")"
    echo "$(bold "🕵️ 验证您的系统配置是否就绪")"
    echo "════════════════════════════════════════════════════════════════"
}

# 检查单项
check_item() {
    local name="$1"
    local command="$2"
    local expected="$3"
    
    printf "%-40s" "检查 $name..."
    
    if eval "$command" >/dev/null 2>&1; then
        echo "$(green "✅ 通过")"
        return 0
    else
        echo "$(red "❌ 失败")"
        if [[ -n "$expected" ]]; then
            echo "    $(yellow "期望: $expected")"
        fi
        return 1
    fi
}

# 检查路径
check_path() {
    local name="$1"
    local path="$2"
    
    printf "%-40s" "检查 $name..."
    
    if [[ -e "$path" ]]; then
        echo "$(green "✅ 存在")"
        echo "    $(blue "路径: $path")"
        return 0
    else
        echo "$(red "❌ 不存在")"
        echo "    $(yellow "路径: $path")"
        return 1
    fi
}

# 主检查函数
main_check() {
    show_banner
    echo ""
    
    local total_checks=0
    local passed_checks=0
    
    # 检查基本命令
    echo "$(bold "🔍 基本系统命令检查")"
    echo "────────────────────────────────────────────────────────────────"
    
    for cmd in python3 bash gzip grep awk wc head sort tee; do
        if check_item "$cmd" "which $cmd"; then
            ((passed_checks++))
        fi
        ((total_checks++))
    done
    
    echo ""
    
    # 检查Python版本
    echo "$(bold "🐍 Python环境检查")"
    echo "────────────────────────────────────────────────────────────────"
    
    if check_item "Python 3.6+" "python3 -c 'import sys; exit(0 if sys.version_info >= (3, 6) else 1)'"; then
        python_version=$(python3 --version 2>&1)
        echo "    $(blue "版本: $python_version")"
        ((passed_checks++))
    fi
    ((total_checks++))
    
    echo ""
    
    # 检查关键脚本文件
    echo "$(bold "📁 关键文件检查")"
    echo "────────────────────────────────────────────────────────────────"
    
    key_files=(
        "主要并行脚本:${SCRIPT_DIR}/run_group_parallel.sh"
        "自动化脚本:${SCRIPT_DIR}/run_s1s2hic_auto.sh"
        "S1S2HiC流程:${SCRIPT_DIR}/src/S1S2HiC_Pipeline.py"
        "配置目录:${SCRIPT_DIR}/configs"
    )
    
    for item in "${key_files[@]}"; do
        name="${item%%:*}"
        path="${item##*:}"
        if check_path "$name" "$path"; then
            ((passed_checks++))
        fi
        ((total_checks++))
    done
    
    echo ""
    
    # 检查配置文件
    echo "$(bold "⚙️ 配置文件检查")"
    echo "────────────────────────────────────────────────────────────────"
    
    config_files=(
        "Group1配置:${SCRIPT_DIR}/configs/Group1_MboI_GATC_SeqA_config.yaml"
        "Group2配置:${SCRIPT_DIR}/configs/Group2_MboI_GATC_SeqB_config.yaml"
        "Group3配置:${SCRIPT_DIR}/configs/Group3_MseI_CviQI_TA_SeqA_config.yaml"
        "Group4配置:${SCRIPT_DIR}/configs/Group4_MseI_CviQI_TA_SeqB_config.yaml"
        "Group5配置:${SCRIPT_DIR}/configs/Group5_MboI_CviQI_GATC_TA_SeqA_config.yaml"
    )
    
    for item in "${config_files[@]}"; do
        name="${item%%:*}"
        path="${item##*:}"
        if check_path "$name" "$path"; then
            ((passed_checks++))
        fi
        ((total_checks++))
    done
    
    echo ""
    
    # 检查数据目录
    echo "$(bold "📂 数据目录检查")"
    echo "────────────────────────────────────────────────────────────────"
    
    data_root="/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups"
    if check_path "数据根目录" "$data_root"; then
        ((passed_checks++))
        
        # 检查各组数据目录
        for group in {1..5}; do
            group_pattern="${data_root}/Group${group}_*"
            if ls -d $group_pattern 2>/dev/null | head -1 >/dev/null; then
                actual_dir=$(ls -d $group_pattern 2>/dev/null | head -1)
                check_path "Group${group}数据目录" "$actual_dir"
                ((passed_checks++))
            else
                check_path "Group${group}数据目录" "$group_pattern"
            fi
            ((total_checks++))
        done
    fi
    ((total_checks++))
    
    echo ""
    
    # 检查写入权限
    echo "$(bold "✏️ 权限检查")"
    echo "────────────────────────────────────────────────────────────────"
    
    if check_item "脚本目录写入权限" "touch '${SCRIPT_DIR}/test_write' && rm '${SCRIPT_DIR}/test_write'"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    echo ""
    
    # 显示总结
    echo "$(bold "📊 检查总结")"
    echo "════════════════════════════════════════════════════════════════"
    
    local pass_rate=$((passed_checks * 100 / total_checks))
    
    echo "总检查项: $total_checks"
    echo "通过检查: $(green "$passed_checks")"
    echo "失败检查: $(red "$((total_checks - passed_checks))")"
    echo "通过率: $(if [[ $pass_rate -ge 90 ]]; then green "$pass_rate%"; elif [[ $pass_rate -ge 70 ]]; then yellow "$pass_rate%"; else red "$pass_rate%"; fi)"
    
    echo ""
    
    if [[ $pass_rate -ge 90 ]]; then
        echo "$(green "🎉 恭喜！您的环境配置良好，可以开始分析了！")"
        echo ""
        echo "$(blue "📖 下一步：")"
        echo "  1. 创建配置文件: $(bold "./run_s1s2hic_auto.sh --create-template")"
        echo "  2. 编辑配置: $(bold "nano simple_config.conf")"
        echo "  3. 运行分析: $(bold "./run_s1s2hic_auto.sh simple_config.conf")"
        echo ""
        echo "$(blue "📋 详细使用说明: $(bold "SIMPLE_README.md")")"
    elif [[ $pass_rate -ge 70 ]]; then
        echo "$(yellow "⚠️  环境基本可用，但有一些问题需要注意")"
        echo ""
        echo "$(blue "🛠️ 建议：")"
        echo "  - 解决上述失败的检查项"
        echo "  - 如果数据目录不存在，请确认路径是否正确"
        echo "  - 运行前请再次检查"
    else
        echo "$(red "❌ 环境配置存在较多问题，请解决后再运行")"
        echo ""
        echo "$(blue "🆘 需要帮助？")"
        echo "  - 检查Python 3.6+是否正确安装"
        echo "  - 确认所有必需的文件是否存在"
        echo "  - 验证数据目录路径是否正确"
        echo "  - 检查文件权限设置"
    fi
    
    echo ""
    echo "$(blue "📞 技术支持: 如有问题请提供此检查报告")"
    
    return $((total_checks - passed_checks))
}

# 运行检查
main_check "$@" 