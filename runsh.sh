#!/bin/bash

# =============================================================================
# 通用并行处理脚本
# 使用方法: ./runsh.sh -c config.yaml
# =============================================================================

set -euo pipefail

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认配置文件
DEFAULT_CONFIG="${SCRIPT_DIR}/configs/templates/parallel_config.yaml"

# 配置解析器脚本
CONFIG_PARSER="${SCRIPT_DIR}/scripts/config_parser.py"

# 全局变量
CONFIG_FILE=""
pids=()

# 显示帮助信息
show_help() {
    echo "通用并行处理脚本"
    echo "使用方法: $0 -c <config_file> [options]"
    echo ""
    echo "参数:"
    echo "  -c <file>   指定配置文件 (必需)"
    echo "  -h, --help  显示此帮助信息"
    echo "  -l, --list  列出配置文件中的所有组"
    echo ""
    echo "示例:"
    echo "  $0 -c configs/templates/parallel_config.yaml        # 运行配置文件中所有启用的组"
    echo "  $0 -c my_config.yaml              # 使用自定义配置文件"
    echo "  $0 -l -c configs/templates/parallel_config.yaml     # 列出配置中的组"
    echo ""
    echo "配置文件格式请参考: configs/templates/parallel_config.yaml"
}

# 解析命令行参数
parse_args() {
    local list_mode=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -l|--list)
                list_mode=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "错误: 未知参数 $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查配置文件参数
    if [[ -z "$CONFIG_FILE" ]]; then
        echo "错误: 必须指定配置文件 (-c 参数)"
        show_help
        exit 1
    fi
    
    # 配置文件路径处理
    if [[ ! "$CONFIG_FILE" = /* ]]; then
        CONFIG_FILE="${SCRIPT_DIR}/${CONFIG_FILE}"
    fi
    
    # 检查配置文件存在性
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "错误: 配置文件不存在: $CONFIG_FILE"
        exit 1
    fi
    
    # 列表模式
    if [[ "$list_mode" = true ]]; then
        list_groups
        exit 0
    fi
}

# 列出配置文件中的组
list_groups() {
    echo "配置文件: $CONFIG_FILE"
    echo "可用的处理组:"
    echo "============================================================"
    
    python3 "$CONFIG_PARSER" "$CONFIG_FILE" --list 2>/dev/null || {
        echo "错误: 无法解析配置文件"
        exit 1
    }
}

# 运行单个组
run_group() {
    local group_id="$1"
    local group_config="$2"
    
    # 解析组配置
    local description=$(echo "$group_config" | grep "^description:" | cut -d: -f2- | sed 's/^ *//')
    local config_file=$(echo "$group_config" | grep "^config_file:" | cut -d: -f2- | sed 's/^ *//')
    local work_dir_raw=$(echo "$group_config" | grep "^work_dir:" | cut -d: -f2- | sed 's/^ *//')
    local enabled=$(echo "$group_config" | grep "^enabled:" | cut -d: -f2- | sed 's/^ *//')
    
    # 扩展work_dir中的环境变量和用户主目录
    local work_dir=$(eval echo "$work_dir_raw")
    
    # 检查是否启用
    if [[ "$enabled" != "true" ]]; then
        echo "跳过禁用的组: $group_id"
        return 0
    fi
    
    # 生成日志文件名
    local log_file="${LOG_DIR}/${group_id}_$(date +%Y%m%d_%H%M%S).log"
    
    echo "=== 启动 ${group_id} 处理 ===" | tee -a "$log_file"
    echo "描述: $description" | tee -a "$log_file"
    echo "配置文件: $config_file" | tee -a "$log_file"
    echo "工作目录: $work_dir" | tee -a "$log_file"
    echo "日志文件: $log_file" | tee -a "$log_file"
    echo "开始时间: $(date)" | tee -a "$log_file"
    echo "进程ID: $$" | tee -a "$log_file"
    echo "============================================================" | tee -a "$log_file"
    
    # 检查配置文件
    local full_config_path
    if [[ "$config_file" = /* ]]; then
        full_config_path="$config_file"
    else
        full_config_path="${CONFIG_DIR}/${config_file}"
    fi
    
    if [[ ! -f "$full_config_path" ]]; then
        echo "错误: 配置文件不存在: $full_config_path" | tee -a "$log_file"
        return 1
    fi
    
    # 检查工作目录
    if [[ ! -d "$work_dir" ]]; then
        echo "错误: 工作目录不存在: $work_dir" | tee -a "$log_file"
        return 1
    fi
    
    # 切换到工作目录
    cd "$work_dir" || {
        echo "错误: 无法切换到工作目录: $work_dir" | tee -a "$log_file"
        return 1
    }
    
    # 清理之前的结果
    echo "清理之前的结果..." | tee -a "$log_file"
    local cleanup_patterns=$(echo "$group_config" | grep "^cleanup_patterns:" -A 100 | tail -n +2 | grep "^  -" | sed 's/^  - //' || true)
    if [[ -n "$cleanup_patterns" ]]; then
        while IFS= read -r pattern; do
            if [[ -n "$pattern" && "$pattern" != "cleanup_patterns:"* ]]; then
                echo "删除: $pattern" | tee -a "$log_file"
                rm -rf $pattern 2>/dev/null || true
            fi
        done <<< "$cleanup_patterns"
    fi
    
    # 运行处理流程
    echo "开始运行处理流程..." | tee -a "$log_file"
    $PYTHON_CMD "$PIPELINE_SCRIPT" -c "$full_config_path" $PIPELINE_ARGS 2>&1 | tee -a "$log_file"
    
    local exit_code=${PIPESTATUS[0]}
    
    if [[ $exit_code -eq 0 ]]; then
        echo "=== ${group_id} 处理成功完成 ===" | tee -a "$log_file"
        echo "完成时间: $(date)" | tee -a "$log_file"
        return 0
    else
        echo "=== ${group_id} 处理失败 ===" | tee -a "$log_file"
        echo "错误代码: $exit_code" | tee -a "$log_file"
        echo "失败时间: $(date)" | tee -a "$log_file"
        return $exit_code
    fi
}

# 信号处理函数
cleanup() {
    echo ""
    echo "🛑 接收到中断信号，正在终止所有后台任务..."
    
    if [[ ${#pids[@]} -gt 0 ]]; then
        for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "终止进程组: $pid"
                kill -TERM -"$pid" 2>/dev/null || true
            fi
        done
        sleep 3
        for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "强制终止进程组: $pid"
                kill -KILL -"$pid" 2>/dev/null || true
            fi
        done
    fi
    
    echo "✅ 所有后台任务已终止"
    exit 1
}

# 主程序
main() {
    # 设置信号处理
    trap cleanup INT TERM
    
    # 解析命令行参数
    parse_args "$@"
    
    echo "=== 通用并行处理开始 ==="
    echo "配置文件: $CONFIG_FILE"
    echo "处理时间: $(date)"
    echo "============================================================"
    
    # 检查配置解析器
    if [[ ! -f "$CONFIG_PARSER" ]]; then
        echo "错误: 找不到配置解析器: $CONFIG_PARSER"
        exit 1
    fi
    
    # 解析全局配置
    local global_config
    global_config=$(python3 "$CONFIG_PARSER" "$CONFIG_FILE" --global 2>/dev/null) || {
        echo "错误: 无法解析全局配置"
        exit 1
    }
    
    # 设置全局变量
    eval "$global_config"
    
    # 检查必要的目录和文件
    if [[ ! -f "$PIPELINE_SCRIPT" ]]; then
        echo "错误: 找不到处理脚本: $PIPELINE_SCRIPT"
        exit 1
    fi
    
    # 创建日志目录
    mkdir -p "$LOG_DIR"
    
    # 获取所有启用的组
    local groups_data
    groups_data=$(python3 "$CONFIG_PARSER" "$CONFIG_FILE" --groups 2>/dev/null) || {
        echo "错误: 无法解析组配置"
        exit 1
    }
    
    if [[ -z "$groups_data" ]]; then
        echo "错误: 没有找到启用的组"
        exit 1
    fi
    
    # 启动并行任务
    local valid_groups=()
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^GROUP_START:(.+)$ ]]; then
            local group_id="${BASH_REMATCH[1]}"
            local group_config=""
            
            # 读取组配置
            while IFS= read -r config_line; do
                if [[ "$config_line" = "GROUP_END" ]]; then
                    break
                fi
                group_config+="$config_line"$'\n'
            done
            
            echo "启动 ${group_id} 后台处理..."
            (run_group "$group_id" "$group_config") &
            local pid=$!
            pids+=($pid)
            valid_groups+=($group_id)
            
            echo "${group_id} 进程ID: $pid"
            sleep "$STARTUP_DELAY"
        fi
    done <<< "$groups_data"
    
    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "错误: 没有启动任何处理任务"
        exit 1
    fi
    
    echo "============================================================"
    echo "已启动 ${#pids[@]} 个并行任务"
    echo "组ID: ${valid_groups[*]}"
    echo "进程ID: ${pids[*]}"
    echo "等待所有任务完成..."
    echo "============================================================"
    
    # 等待所有任务完成
    local success_count=0
    local fail_count=0
    
    for i in "${!pids[@]}"; do
        local pid=${pids[$i]}
        local group_id=${valid_groups[$i]}
        
        if wait $pid; then
            echo "✅ ${group_id} (PID: $pid) 处理成功完成"
            ((success_count++))
        else
            echo "❌ ${group_id} (PID: $pid) 处理失败"
            ((fail_count++))
        fi
    done
    
    echo "============================================================"
    echo "=== 所有任务完成 ==="
    echo "总任务数: ${#pids[@]}"
    echo "成功: $success_count"
    echo "失败: $fail_count"
    echo "完成时间: $(date)"
    echo "============================================================"
    
    # 显示日志文件
    echo "详细日志文件:"
    ls -la "$LOG_DIR"/*_$(date +%Y%m%d)*.log 2>/dev/null || echo "未找到今日日志文件"
    
    if [[ $fail_count -eq 0 ]]; then
        echo "🎉 所有任务处理成功完成!"
        exit 0
    else
        echo "⚠️  部分任务处理失败，请检查日志文件"
        exit 1
    fi
}

# 运行主程序
main "$@" 