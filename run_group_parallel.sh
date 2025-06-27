#!/bin/bash

# =============================================================================
# S1S2HiC 组并行处理脚本
# 使用方法: ./run_group_parallel.sh [组号1] [组号2] [组号3] [组号4] [组号5]
# 例如: ./run_group_parallel.sh 1 2 3 4 5  # 并行运行所有5个组
# 例如: ./run_group_parallel.sh 1 3        # 只并行运行组1和组3
# =============================================================================

# 配置参数
SCRIPT_DIR="/home/maolp/Biosoft/Myscript/sequence-processing-toolkit"
CONFIG_DIR="${SCRIPT_DIR}/configs"
PIPELINE_SCRIPT="${SCRIPT_DIR}/src/S1S2HiC_Pipeline.py"
LOG_DIR="${SCRIPT_DIR}/parallel_logs"  # 使用绝对路径

# 创建日志目录
mkdir -p "$LOG_DIR"

# 组配置映射
declare -A GROUP_CONFIGS=(
    [1]="${CONFIG_DIR}/Group1_MboI_GATC_SeqA_config.yaml"
    [2]="${CONFIG_DIR}/Group2_MboI_GATC_SeqB_config.yaml"  
    [3]="${CONFIG_DIR}/Group3_MseI_CviQI_TA_SeqA_config.yaml"
    [4]="${CONFIG_DIR}/Group4_MseI_CviQI_TA_SeqB_config.yaml"
    [5]="${CONFIG_DIR}/Group5_MboI_CviQI_GATC_TA_SeqA_config.yaml"
)

declare -A GROUP_DIRS=(
    [1]="/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups/Group1_MboI_GATC_SeqA"
    [2]="/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups/Group2_MboI_GATC_SeqB"
    [3]="/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups/Group3_MseI_CviQI_TA_SeqA"
    [4]="/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups/Group4_MseI_CviQI_TA_SeqB"
    [5]="/data3/maolp/All_ZengXi_data5/20250502_fq/fastq/Allfq/ByGroups/Group5_MboI_CviQI_GATC_TA_SeqA"
)

# 运行单个组的函数
run_group() {
    local group_num=$1
    local config_file="${GROUP_CONFIGS[$group_num]}"
    local work_dir="${GROUP_DIRS[$group_num]}"
    local log_file="${LOG_DIR}/group${group_num}_$(date +%Y%m%d_%H%M%S).log"
    
    echo "=== 启动 Group${group_num} 处理 ===" | tee -a "$log_file"
    echo "配置文件: $config_file" | tee -a "$log_file"
    echo "工作目录: $work_dir" | tee -a "$log_file"
    echo "日志文件: $log_file" | tee -a "$log_file"
    echo "开始时间: $(date)" | tee -a "$log_file"
    echo "进程ID: $$" | tee -a "$log_file"
    echo "============================================================" | tee -a "$log_file"
    
    # 检查配置文件和工作目录
    if [[ ! -f "$config_file" ]]; then
        echo "错误: 配置文件不存在: $config_file" | tee -a "$log_file"
        return 1
    fi
    
    if [[ ! -d "$work_dir" ]]; then
        echo "错误: 工作目录不存在: $work_dir" | tee -a "$log_file"
        return 1
    fi
    
    # 切换到工作目录并运行流程
    cd "$work_dir" || {
        echo "错误: 无法切换到工作目录: $work_dir" | tee -a "$log_file"
        return 1
    }
    
    # 清理之前的结果
    echo "清理之前的结果..." | tee -a "$log_file"
    rm -rf Group${group_num}_S1_Linker_Separated Group${group_num}_S2_Enzyme_Split Group${group_num}_HiC_Input \
           Run2_trim Run3_hic Run0_log Run4_HICdata* CountFold S1S2HiC_Complete_Report_*.txt 2>/dev/null
    
    # 运行S1S2HiC流程
    echo "开始运行S1S2HiC流程..." | tee -a "$log_file"
    python3 "$PIPELINE_SCRIPT" -c "$config_file" --skip-trim 2>&1 | tee -a "$log_file"
    
    local exit_code=${PIPESTATUS[0]}
    
    if [[ $exit_code -eq 0 ]]; then
        echo "=== Group${group_num} 处理成功完成 ===" | tee -a "$log_file"
        echo "完成时间: $(date)" | tee -a "$log_file"
        
        # 生成结果摘要
        echo -e "\n=== Group${group_num} 结果摘要 ===" | tee -a "$log_file"
        if [[ -d "CountFold" ]]; then
            echo "S1统计文件:" | tee -a "$log_file"
            ls -la CountFold/*.tsv 2>/dev/null | tee -a "$log_file"
        fi
        
        if [[ -d "Group${group_num}_S2_Enzyme_Split" ]]; then
            echo "S2输出目录数: $(find Group${group_num}_S2_Enzyme_Split -maxdepth 1 -type d | wc -l)" | tee -a "$log_file"
        fi
        
        if [[ -d "Run3_hic" ]]; then
            echo "HiC-Pro输出: $(du -sh Run3_hic 2>/dev/null)" | tee -a "$log_file"
        fi
        
        if [[ -f "S1S2HiC_Complete_Report_"*.txt ]]; then
            echo "完整报告: $(ls S1S2HiC_Complete_Report_*.txt)" | tee -a "$log_file"
        fi
        
        return 0
    else
        echo "=== Group${group_num} 处理失败 ===" | tee -a "$log_file"
        echo "错误代码: $exit_code" | tee -a "$log_file"
        echo "失败时间: $(date)" | tee -a "$log_file"
        return $exit_code
    fi
}

# 显示帮助信息
show_help() {
    echo "S1S2HiC 组并行处理脚本"
    echo "使用方法: $0 [组号1] [组号2] [组号3] [组号4] [组号5]"
    echo ""
    echo "可用的组号: 1, 2, 3, 4, 5"
    echo ""
    echo "示例:"
    echo "  $0 1 2 3 4 5    # 并行运行所有5个组"
    echo "  $0 1 3          # 只并行运行组1和组3"
    echo "  $0 2            # 只运行组2"
    echo ""
    echo "组配置信息:"
    echo "  Group1: MboI+GATC+SeqA (3个样本, 6个文件)"
    echo "  Group2: MboI+GATC+SeqB (1个样本, 2个文件)"  
    echo "  Group3: MseI+CviQI+TA+SeqA (3个样本, 6个文件)"
    echo "  Group4: MseI+CviQI+TA+SeqB (1个样本, 2个文件)"
    echo "  Group5: MboI+CviQI+GATC+TA+SeqA (1个样本, 2个文件)"
    echo ""
    echo "日志文件将保存在: $LOG_DIR/"
}

# 信号处理函数 - 清理后台进程
cleanup() {
    echo ""
    echo "🛑 接收到中断信号，正在终止所有后台任务..."
    
    # 方法1: 终止进程组
    if [[ ${#pids[@]} -gt 0 ]]; then
        for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "终止进程组: $pid"
                # 终止整个进程组（包括子进程）
                kill -TERM -"$pid" 2>/dev/null
            fi
        done
        sleep 3
        # 强制终止仍在运行的进程组
        for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "强制终止进程组: $pid"
                kill -KILL -"$pid" 2>/dev/null
            fi
        done
    fi
    
    # 方法2: 额外保险 - 按名称终止相关进程
    echo "清理残留的S1S2HiC相关进程..."
    pkill -f "S1_Process_gen.py" 2>/dev/null
    pkill -f "S2_Split.py" 2>/dev/null
    pkill -f "S1S2HiC_Pipeline.py" 2>/dev/null
    pkill -f "run_hicpro_pipeline.sh" 2>/dev/null
    pkill -f "schic_analysis_pipeline.sh" 2>/dev/null
    pkill -f "HiC-Pro" 2>/dev/null
    # 清理包含Group关键字的相关进程（但排除grep本身）
    ps -ef | grep "Group" | grep -v grep | awk '{print $2}' | xargs -r kill -TERM 2>/dev/null
    
    echo "✅ 所有后台任务已终止"
    exit 1
}

# 主程序
main() {
    # 设置信号处理
    trap cleanup INT TERM
    
    # 检查参数
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # 检查脚本文件
    if [[ ! -f "$PIPELINE_SCRIPT" ]]; then
        echo "错误: 找不到Pipeline脚本: $PIPELINE_SCRIPT"
        exit 1
    fi
    
    echo "=== S1S2HiC 并行处理开始 ==="
    echo "处理时间: $(date)"
    echo "处理组数: $#"
    echo "处理组号: $*"
    echo "日志目录: $LOG_DIR"
    echo "============================================================"
    
    # 验证组号并启动并行任务
    pids=()  # 全局变量，供cleanup函数使用
    local valid_groups=()
    
    for group_num in "$@"; do
        if [[ ! "$group_num" =~ ^[1-5]$ ]]; then
            echo "错误: 无效的组号: $group_num (必须是1-5之间的数字)"
            continue
        fi
        
        if [[ ! -f "${GROUP_CONFIGS[$group_num]}" ]]; then
            echo "错误: 组${group_num}的配置文件不存在: ${GROUP_CONFIGS[$group_num]}"
            continue
        fi
        
        if [[ ! -d "${GROUP_DIRS[$group_num]}" ]]; then
            echo "错误: 组${group_num}的工作目录不存在: ${GROUP_DIRS[$group_num]}"
            continue
        fi
        
        echo "启动 Group${group_num} 后台处理..."
        # 启动后台进程，使用bash的作业控制
        \
        (run_group "$group_num") &
        local pid=$!
        pids+=($pid)
        valid_groups+=($group_num)
        
        echo "Group${group_num} 进程ID: $pid"
        sleep 2  # 避免同时启动造成资源竞争
    done
    
    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "错误: 没有有效的组可以处理"
        exit 1
    fi
    
    echo "============================================================"
    echo "已启动 ${#pids[@]} 个并行任务"
    echo "组号: ${valid_groups[*]}"
    echo "进程ID: ${pids[*]}"
    echo "============================================================"
    
    # 等待所有任务完成 - 真正的并行等待
    local success_count=0
    local fail_count=0
    
    echo "所有组正在并行运行中..."
    echo "运行中的组: ${valid_groups[*]}"
    echo "对应进程ID: ${pids[*]}"
    echo "等待所有组完成... (这可能需要一些时间)"
    echo "============================================================"
    
    # 使用wait等待所有后台进程完成
    for i in "${!pids[@]}"; do
        local pid=${pids[$i]}
        local group_num=${valid_groups[$i]}
        
        # 等待这个进程完成并获取退出状态
        if wait $pid; then
            echo "✅ Group${group_num} (PID: $pid) 处理成功完成"
            ((success_count++))
        else
            echo "❌ Group${group_num} (PID: $pid) 处理失败"
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
    
    # 显示日志文件位置
    echo "详细日志文件:"
    ls -la "$LOG_DIR"/group*_$(date +%Y%m%d)*.log 2>/dev/null || echo "未找到今日日志文件"
    
    # 根据成功失败情况设置退出代码
    if [[ $fail_count -eq 0 ]]; then
        echo "🎉 所有组处理成功完成!"
        exit 0
    else
        echo "⚠️  部分组处理失败，请检查日志文件"
        exit 1
    fi
}

# 运行主程序
main "$@" 