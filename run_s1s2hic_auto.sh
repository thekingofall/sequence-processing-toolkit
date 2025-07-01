#!/bin/bash

# =============================================================================
# S1S2HiC 自动化处理脚本 - 傻瓜式运行版本
# 使用方法: ./run_s1s2hic_auto.sh [配置文件]
# 例如: ./run_s1s2hic_auto.sh my_experiment.conf
# =============================================================================

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/auto_logs"

# 默认配置
DEFAULT_CONFIG_FILE="${SCRIPT_DIR}/configs/templates/simple_config.conf"
PARALLEL_SCRIPT="${SCRIPT_DIR}/scripts/run_group_parallel.sh"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 颜色输出函数
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
blue() { echo -e "\033[34m$1\033[0m"; }
bold() { echo -e "\033[1m$1\033[0m"; }

# 显示横幅
show_banner() {
    echo "════════════════════════════════════════════════════════════════"
    echo "$(bold "🧬 S1S2HiC 自动化处理脚本 v${VERSION}")"
    echo "$(bold "🚀 傻瓜式一键运行版本")"
    echo "════════════════════════════════════════════════════════════════"
}

# 显示帮助信息
show_help() {
    show_banner
    echo ""
    echo "$(bold "📖 使用方法:")"
    echo "  $0 [配置文件]"
    echo ""
    echo "$(bold "📋 示例:")"
    echo "  $0                           # 使用默认配置文件"
    echo "  $0 my_experiment.conf        # 使用自定义配置文件"
    echo "  $0 --create-template         # 创建配置文件模板"
    echo "  $0 --help                    # 显示此帮助信息"
    echo ""
    echo "$(bold "📁 配置文件格式 (simple_config.conf):")"
    echo "  # 项目名称"
    echo "  PROJECT_NAME=my_experiment"
    echo ""
    echo "  # 要处理的组（1-5，用逗号分隔）"
    echo "  GROUPS=1,2,3,4,5"
    echo ""
    echo "  # 数据根目录"
    echo "  DATA_ROOT=/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups"
    echo ""
    echo "  # 并行任务数（可选，默认自动检测）"
    echo "  # MAX_PARALLEL=3"
    echo ""
    echo "$(bold "🔧 可用的组类型:")"
    echo "  Group1: MboI+GATC+SeqA (3个样本)"
    echo "  Group2: MboI+GATC+SeqB (1个样本)" 
    echo "  Group3: MseI+CviQI+TA+SeqA (3个样本)"
    echo "  Group4: MseI+CviQI+TA+SeqB (1个样本)"
    echo "  Group5: MboI+CviQI+GATC+TA+SeqA (1个样本)"
    echo ""
    echo "$(bold "📋 完整工作流程:")"
    echo "  1. S1步骤: 序列筛选和统计"
    echo "  2. S2步骤: 酶切分割"
    echo "  3. HiC步骤: HiC-Pro分析"
    echo "  4. 结果整理和报告生成"
}

# 创建配置文件模板
create_template() {
    local template_file="configs/templates/simple_config.conf"
    echo "$(green "📝 创建配置文件模板: $template_file")"
    
    cat > "$template_file" << 'EOF'
# =============================================================================
# S1S2HiC 自动化处理配置文件
# =============================================================================

# 项目名称（必填）
# 用于标识此次分析，建议包含日期和描述
PROJECT_NAME=my_s1s2hic_experiment_$(date +%Y%m%d)

# 要处理的组（必填）
# 可选值: 1,2,3,4,5 或它们的任意组合
# 例如: GROUPS=1,3,5 表示只处理组1、3、5
GROUPS=1,2,3,4,5

# 数据根目录（必填）
# 包含各组数据子目录的父目录
DATA_ROOT=/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups

# 最大并行任务数（可选）
# 留空自动检测CPU核心数，建议不超过可用核心数的80%
# MAX_PARALLEL=3

# 输出根目录（可选）
# 留空则在每个组的工作目录中生成结果
# OUTPUT_ROOT=/path/to/output

# 邮件通知（可选）
# 完成后发送通知邮件
# EMAIL_NOTIFY=your@email.com

# 清理选项（可选）
# 是否在成功完成后清理中间文件（true/false）
CLEANUP_TEMP=false

# 重试选项（可选）
# 失败时的重试次数
RETRY_COUNT=1
EOF

    echo "$(green "✅ 配置文件模板已创建: $template_file")"
    echo ""
    echo "$(yellow "📝 请编辑配置文件并根据您的需求修改参数：")"
    echo "  nano $template_file"
    echo ""
    echo "$(yellow "🚀 然后运行分析：")"
    echo "  $0 $template_file"
}

# 读取配置文件
read_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        red "❌ 错误: 配置文件不存在: $config_file"
        echo ""
        echo "$(yellow "💡 提示: 创建配置文件模板：")"
        echo "  $0 --create-template"
        exit 1
    fi
    
    echo "$(blue "📖 读取配置文件: $config_file")"
    
    # 读取配置文件，忽略注释和空行
    while IFS='=' read -r key value; do
        # 跳过注释和空行
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # 移除前后空格
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # 设置变量
        case "$key" in
            PROJECT_NAME) PROJECT_NAME="$value" ;;
            GROUPS) GROUPS="$value" ;;
            DATA_ROOT) DATA_ROOT="$value" ;;
            MAX_PARALLEL) MAX_PARALLEL="$value" ;;
            OUTPUT_ROOT) OUTPUT_ROOT="$value" ;;
            EMAIL_NOTIFY) EMAIL_NOTIFY="$value" ;;
            CLEANUP_TEMP) CLEANUP_TEMP="$value" ;;
            RETRY_COUNT) RETRY_COUNT="$value" ;;
        esac
    done < "$config_file"
}

# 验证配置
validate_config() {
    local errors=0
    
    echo "$(blue "🔍 验证配置参数...")"
    
    # 检查必填参数
    if [[ -z "$PROJECT_NAME" ]]; then
        red "❌ 错误: PROJECT_NAME 未设置"
        ((errors++))
    fi
    
    if [[ -z "$GROUPS" ]]; then
        red "❌ 错误: GROUPS 未设置"
        ((errors++))
    fi
    
    if [[ -z "$DATA_ROOT" ]]; then
        red "❌ 错误: DATA_ROOT 未设置"
        ((errors++))
    fi
    
    # 检查数据目录
    if [[ ! -d "$DATA_ROOT" ]]; then
        red "❌ 错误: 数据根目录不存在: $DATA_ROOT"
        ((errors++))
    fi
    
    # 验证组号
    IFS=',' read -ra GROUP_ARRAY <<< "$GROUPS"
    for group in "${GROUP_ARRAY[@]}"; do
        group=$(echo "$group" | xargs)  # 移除空格
        if [[ ! "$group" =~ ^[1-5]$ ]]; then
            red "❌ 错误: 无效的组号: $group (必须是1-5)"
            ((errors++))
        fi
    done
    
    # 检查并行脚本
    if [[ ! -f "$PARALLEL_SCRIPT" ]]; then
        red "❌ 错误: 并行处理脚本不存在: $PARALLEL_SCRIPT"
        ((errors++))
    fi
    
    if [[ $errors -gt 0 ]]; then
        red "❌ 配置验证失败，发现 $errors 个错误"
        exit 1
    fi
    
    echo "$(green "✅ 配置验证通过")"
}

# 显示配置摘要
show_config_summary() {
    echo ""
    echo "$(bold "📋 配置摘要：")"
    echo "══════════════════════════════════════════════════════════════"
    echo "项目名称: $(green "$PROJECT_NAME")"
    echo "处理组: $(green "$GROUPS")"
    echo "数据目录: $(green "$DATA_ROOT")"
    echo "并行任务数: $(green "${MAX_PARALLEL:-自动检测}")"
    echo "输出目录: $(green "${OUTPUT_ROOT:-各组工作目录}")"
    echo "日志目录: $(green "$LOG_DIR")"
    echo "重试次数: $(green "${RETRY_COUNT:-1}")"
    echo "══════════════════════════════════════════════════════════════"
}

# 发送邮件通知
send_notification() {
    local status="$1"
    local message="$2"
    
    if [[ -n "$EMAIL_NOTIFY" ]]; then
        echo "$(blue "📧 发送邮件通知到: $EMAIL_NOTIFY")"
        {
            echo "Subject: S1S2HiC 分析 $status - $PROJECT_NAME"
            echo ""
            echo "项目: $PROJECT_NAME"
            echo "状态: $status"
            echo "时间: $(date)"
            echo "组: $GROUPS"
            echo ""
            echo "$message"
        } | sendmail "$EMAIL_NOTIFY" 2>/dev/null || echo "$(yellow "⚠️  邮件发送失败")"
    fi
}

# 主运行函数
run_analysis() {
    local start_time=$(date +%s)
    local main_log="${LOG_DIR}/auto_run_${PROJECT_NAME}_$(date +%Y%m%d_%H%M%S).log"
    
    echo "$(green "🚀 开始 S1S2HiC 自动分析")"
    echo "开始时间: $(date)"
    echo "主日志文件: $main_log"
    echo "" | tee -a "$main_log"
    
    # 记录配置到日志
    {
        echo "=== S1S2HiC 自动分析日志 ==="
        echo "开始时间: $(date)"
        echo "项目名称: $PROJECT_NAME"
        echo "处理组: $GROUPS"
        echo "数据目录: $DATA_ROOT"
        echo "脚本版本: $VERSION"
        echo "═══════════════════════════════════════"
        echo ""
    } >> "$main_log"
    
    # 转换组号为数组
    IFS=',' read -ra GROUP_ARRAY <<< "$GROUPS"
    
    # 执行并行处理
    echo "$(blue "▶️  执行并行处理...")" | tee -a "$main_log"
    
    # 构建并行脚本命令
    local groups_args=""
    for group in "${GROUP_ARRAY[@]}"; do
        group=$(echo "$group" | xargs)
        groups_args="$groups_args $group"
    done
    
    # 运行并行处理脚本
    echo "执行命令: $PARALLEL_SCRIPT $groups_args" | tee -a "$main_log"
    
    if "$PARALLEL_SCRIPT" $groups_args 2>&1 | tee -a "$main_log"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local hours=$((duration / 3600))
        local minutes=$(((duration % 3600) / 60))
        local seconds=$((duration % 60))
        
        echo "" | tee -a "$main_log"
        echo "$(green "🎉 S1S2HiC 分析成功完成!")" | tee -a "$main_log"
        echo "总耗时: ${hours}h ${minutes}m ${seconds}s" | tee -a "$main_log"
        echo "完成时间: $(date)" | tee -a "$main_log"
        
        # 生成结果摘要
        generate_summary_report "$main_log"
        
        # 发送成功通知
        send_notification "成功完成" "所有组处理成功完成，总耗时: ${hours}h ${minutes}m ${seconds}s"
        
        return 0
    else
        echo "" | tee -a "$main_log"
        echo "$(red "❌ S1S2HiC 分析失败")" | tee -a "$main_log"
        echo "失败时间: $(date)" | tee -a "$main_log"
        
        # 发送失败通知
        send_notification "失败" "分析过程中出现错误，请检查日志文件: $main_log"
        
        return 1
    fi
}

# 生成结果摘要报告
generate_summary_report() {
    local main_log="$1"
    local summary_file="${LOG_DIR}/summary_${PROJECT_NAME}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "$(blue "📊 生成结果摘要报告...")"
    
    {
        echo "═══════════════════════════════════════════════════════════════"
        echo "S1S2HiC 分析结果摘要报告"
        echo "═══════════════════════════════════════════════════════════════"
        echo "项目名称: $PROJECT_NAME"
        echo "分析时间: $(date)"
        echo "处理组: $GROUPS"
        echo ""
        
        echo "═══ 各组处理状态 ═══"
        IFS=',' read -ra GROUP_ARRAY <<< "$GROUPS"
        for group in "${GROUP_ARRAY[@]}"; do
            group=$(echo "$group" | xargs)
            if grep -q "Group${group}.*处理成功完成" "$main_log" 2>/dev/null; then
                echo "✅ Group${group}: 成功完成"
            else
                echo "❌ Group${group}: 处理失败"
            fi
        done
        
        echo ""
        echo "═══ 输出文件位置 ═══"
        for group in "${GROUP_ARRAY[@]}"; do
            group=$(echo "$group" | xargs)
            local group_dir="${DATA_ROOT}/Group${group}_*"
            if ls $group_dir 2>/dev/null | head -1 >/dev/null; then
                local actual_dir=$(ls -d $group_dir 2>/dev/null | head -1)
                echo "Group${group} 结果目录: $actual_dir"
                
                # 列出关键输出文件
                if [[ -d "$actual_dir/CountFold" ]]; then
                    echo "  - S1统计文件: $actual_dir/CountFold/"
                fi
                if [[ -d "$actual_dir/Group${group}_S2_Enzyme_Split" ]]; then
                    echo "  - S2分割文件: $actual_dir/Group${group}_S2_Enzyme_Split/"
                fi
                if [[ -d "$actual_dir/Run3_hic" ]]; then
                    echo "  - HiC分析结果: $actual_dir/Run3_hic/"
                fi
                if ls "$actual_dir"/S1S2HiC_Complete_Report_*.txt 2>/dev/null >/dev/null; then
                    echo "  - 完整报告: $(ls "$actual_dir"/S1S2HiC_Complete_Report_*.txt 2>/dev/null)"
                fi
            fi
        done
        
        echo ""
        echo "═══ 日志文件 ═══"
        echo "主日志: $main_log"
        echo "详细日志: $LOG_DIR/"
        
    } > "$summary_file"
    
    echo "$(green "📋 结果摘要已保存: $summary_file")"
    
    # 显示简要摘要
    echo ""
    echo "$(bold "📊 快速结果概览:")"
    cat "$summary_file" | grep -E "(✅|❌|Group.*结果目录)"
}

# 主程序入口
main() {
    # 设置默认值
    PROJECT_NAME=""
    GROUPS=""
    DATA_ROOT=""
    MAX_PARALLEL=""
    OUTPUT_ROOT=""
    EMAIL_NOTIFY=""
    CLEANUP_TEMP="false"
    RETRY_COUNT="1"
    
    # 处理命令行参数
    case "${1:-}" in
        ""|"-h"|"--help")
            show_help
            exit 0
            ;;
        "--create-template")
            create_template
            exit 0
            ;;
        *)
            CONFIG_FILE="$1"
            ;;
    esac
    
    # 如果没有指定配置文件，使用默认配置文件
    if [[ -z "$CONFIG_FILE" ]]; then
        CONFIG_FILE="$DEFAULT_CONFIG_FILE"
        
        # 如果默认配置文件不存在，创建模板并退出
        if [[ ! -f "$CONFIG_FILE" ]]; then
            echo "$(yellow "📝 默认配置文件不存在，创建模板...")"
            create_template
            exit 0
        fi
    fi
    
    # 显示横幅
    show_banner
    echo ""
    
    # 读取和验证配置
    read_config "$CONFIG_FILE"
    validate_config
    show_config_summary
    
    # 确认执行
    echo ""
    echo "$(yellow "⚠️  即将开始分析，这可能需要很长时间...")"
    read -p "$(bold "继续执行? [y/N]: ")" -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "$(yellow "🚫 用户取消操作")"
        exit 0
    fi
    
    # 运行分析
    if run_analysis; then
        echo ""
        echo "$(green "🎊 所有分析已成功完成！")"
        echo "$(blue "📁 查看结果摘要: ${LOG_DIR}/summary_${PROJECT_NAME}_*.txt")"
        exit 0
    else
        echo ""
        echo "$(red "💥 分析过程中出现错误")"
        echo "$(yellow "📋 请检查日志文件获取详细信息")"
        exit 1
    fi
}

# 执行主程序
main "$@" 