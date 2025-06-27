#!/bin/bash

# =============================================================================
# 脚本名称: schic_analysis_pipeline.sh
# 描述: 单细胞Hi-C数据分析流程，整合HiC-Pro运行脚本，支持配置文件选择和参数调整。
# 使用方法:
#   ./schic_analysis_pipeline.sh [选项]
#
# 选项:
#   -n <1|2|3>             选择配置文件类型（1: scCARE_MboI.txt, 2: hicpro_NlaIII.txt, 3: hicpro_MboI.txt），默认: 1 # MODIFIED HERE
#   -p <项目名称>           项目名称（默认: scC-HiCMOBI）
#   -i <输入目录>           输入目录（默认: Run1_fastq）
#   -t <修剪目录>           修剪目录（默认: Run2_trim）
#   -o <输出目录>           输出目录（默认: Run3_hic）
#   -j <日志目录>           日志目录（默认: Run0_log）
#   -u <CPU数量>            并行CPU数量（默认: 10）
#   -e <Conda环境>          Conda环境名称（默认: hicpro3）
#   -m <模块>               指定要运行的模块（默认: 1,2,3）
#                          1: 执行trim_galore (生成$trim_dir)
#                          2: 执行HiC-Pro (生成$output_dir)
#                          3: 转换为Juicebox和收集.hic文件 (生成Run4_HICdata)
#                          4: 单纯移动.hic文件到Run4_HICdata_m4文件夹
#                          例如: -m 2,3 只运行HiC-Pro和后续步骤
#   --HiC-Pro <路径>        HiC-Pro可执行文件路径（默认: ${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/HiC-Pro）
#   --SentEmail <路径>      SentEmail.py脚本路径（默认: ${HICPRO_BASE_DIR}/scripts/SentEmail.py）
#   --SummaryScript <路径>  hicpro_summary_trans.pl脚本路径（默认: ${HICPRO_BASE_DIR}/scripts/hicpro_summary_trans.pl）
#   --JuiceboxScript <路径> hicpro2juicebox.sh脚本路径（默认: ${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/utils/hicpro2juicebox.sh）
#   --JuicerTools <路径>    Juicer_tools.jar路径（默认: ${HICPRO_BASE_DIR}/tools/juicer_tools_1.22.01.jar）
#   --GenomeSizes <路径>    hg19.sizes文件路径（默认: ${HICPRO_BASE_DIR}/genome/hg19.sizes）
#   --GenomeBed <路径>      hg19mboi.bed文件路径（默认: ${HICPRO_BASE_DIR}/genome/HG19mboi.bed）
#   --remove-large-files    删除大型输出文件(>2GB)（默认: 启用）
#   --keep-large-files      保留大型输出文件（默认: 禁用）
#   -h                      显示帮助信息
# =============================================================================

# 默认参数
Project_name="scC-HiCMOBI_$(date +%Y%m%d)"
input_dir="Run1_fastq"
trim_dir="Run2_trim"
output_dir="Run3_hic"
log_dir="Run0_log"
cpu=10
conda_env="hicpro3"
remove_large_files=true
# 默认运行所有模块
run_modules="1,2,3,4"

# 标准化基础路径 - 可根据需要修改
HICPRO_BASE_DIR="/data1/Ref/hicpro"

# 默认软件路径 - 基于标准化基础路径构建
default_HiC_Pro_path="${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/HiC-Pro"
default_SentEmail_path="${HICPRO_BASE_DIR}/scripts/SentEmail.py"
default_SummaryScript_path="${HICPRO_BASE_DIR}/scripts/hicpro_summary_trans.pl"
default_JuiceboxScript_path="${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/utils/hicpro2juicebox.sh"
default_JuicerTools_path="${HICPRO_BASE_DIR}/tools/juicer_tools_1.22.01.jar"
default_GenomeSizes_path="${HICPRO_BASE_DIR}/genome/hg19.sizes"
default_GenomeBed_path="${HICPRO_BASE_DIR}/genome/HG19mboi.bed"

HiC_Pro_path="$default_HiC_Pro_path"
SentEmail_path="$default_SentEmail_path"
SummaryScript_path="$default_SummaryScript_path"
JuiceboxScript_path="$default_JuiceboxScript_path"
JuicerTools_path="$default_JuicerTools_path"
GenomeSizes_path="$default_GenomeSizes_path"
GenomeBed_path="$default_GenomeBed_path"

# 默认配置文件
config_type=1
config_file="${HICPRO_BASE_DIR}/configs/scCARE_MboI.txt"

# 收集hic文件函数 - 在每个模块完成后调用
collect_hic_files() {
    local module_num=$1
    local hic_dir="Run4_HICdata_m${module_num}"
    
    echo "检查并收集.hic文件到 ${hic_dir}..."
    mkdir -p "$hic_dir"
    
    # 查找所有.hic文件
    local hic_files=$(find . -name "*.hic" -type f 2>/dev/null)
    
    if [[ -n "$hic_files" ]]; then
        echo "找到以下.hic文件:"
        echo "$hic_files" | while read -r file; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                local source_dir=$(dirname "$file")
                echo "- $filename (来源: $source_dir)"
                
                # 检查文件是否已经在目标目录中
                if [[ ! -f "$hic_dir/$filename" ]]; then
                    cp "$file" "$hic_dir/" && echo "  已复制到${hic_dir}/"
                else
                    echo "  文件已存在于${hic_dir}/，跳过"
                fi
            fi
        done
        echo ".hic文件收集到${hic_dir}完成"
    else
        echo "当前未找到.hic文件"
    fi
}

# 清理函数 - 用于中断时自动清理大文件
cleanup_large_files() {
    local exit_code=$?
    echo "执行清理操作..."

    # 如果输出目录存在且启用了删除大文件选项
    if [[ -d "${output_dir}" && "$remove_large_files" = true ]]; then
        echo "检查并删除大型输出文件（>2GB）..."
        local large_files=$(find "${output_dir}" -type f -size +2G 2>/dev/null)
        if [[ -n "$large_files" ]]; then
            echo "正在删除以下大型文件:"
            echo "$large_files" | while read -r file; do
                if [[ -f "$file" ]]; then
                    echo "- $file ($(du -h "$file" 2>/dev/null | cut -f1))"
                    rm -f "$file" 2>/dev/null
                fi
            done
            echo "大型文件已删除"
        else
            echo "未找到需要删除的大型文件"
        fi
    fi

    # 发送中断通知邮件(如果脚本异常终止)
    if [[ $exit_code -ne 0 ]]; then
        if [[ -f "$SentEmail_path" ]]; then
            echo "发送中断通知邮件..."
            python "$SentEmail_path" "${Project_name}_interrupted" "Pipeline执行中断，退出代码: $exit_code" || true
        fi
    fi

    exit $exit_code
}

# 设置信号陷阱，在脚本退出时调用cleanup_large_files函数
trap cleanup_large_files EXIT INT TERM ERR

# 显示帮助信息
usage() {
    echo "用法: \$0 [选项]"
    echo
    echo "选项:"
    # *** MODIFIED usage description for -n ***
    echo "  -n <1|2|3>             选择配置文件类型（1: scCARE_MboI.txt, 2: hicpro_NlaIII.txt, 3: hicpro_MboI.txt），默认: 1"
    echo "  -p <项目名称>           项目名称（默认: $Project_name）"
    echo "  -i <输入目录>           输入目录（默认: $input_dir）"
    echo "  -t <修剪目录>           修剪目录（默认: $trim_dir）"
    echo "  -o <输出目录>           输出目录（默认: $output_dir）"
    echo "  -j <日志目录>           日志目录（默认: $log_dir）"
    echo "  -u <CPU数量>            并行CPU数量（默认: $cpu）"
    echo "  -e <Conda环境>          Conda环境名称（默认: $conda_env）"
    echo "  -m <模块>               指定要运行的模块（默认: 1,2,3）"
    echo "                           1: 执行trim_galore (生成$trim_dir)"
    echo "                           2: 执行HiC-Pro (生成$output_dir)"
    echo "                           3: 转换为Juicebox和收集.hic文件 (生成Run4_HICdata)"
    echo "                           4: 单纯移动.hic文件到Run4_HICdata_m4文件夹"
    echo "                           例如: -m 2,3 只运行HiC-Pro和后续步骤"
    echo "  --HiC-Pro <路径>        HiC-Pro可执行文件路径（默认: ${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/HiC-Pro）"
    echo "  --SentEmail <路径>      SentEmail.py脚本路径（默认: ${HICPRO_BASE_DIR}/scripts/SentEmail.py）"
    echo "  --SummaryScript <路径>  hicpro_summary_trans.pl脚本路径（默认: ${HICPRO_BASE_DIR}/scripts/hicpro_summary_trans.pl）"
    echo "  --JuiceboxScript <路径> hicpro2juicebox.sh脚本路径（默认: ${HICPRO_BASE_DIR}/HiC-Pro-3.1.0/bin/utils/hicpro2juicebox.sh）"
    echo "  --JuicerTools <路径>    Juicer_tools.jar路径（默认: ${HICPRO_BASE_DIR}/tools/juicer_tools_1.22.01.jar）"
    echo "  --GenomeSizes <路径>    hg19.sizes文件路径（默认: ${HICPRO_BASE_DIR}/genome/hg19.sizes）"
    echo "  --GenomeBed <路径>      hg19mboi.bed文件路径（默认: ${HICPRO_BASE_DIR}/genome/HG19mboi.bed）"
    echo "  --remove-large-files    删除大型输出文件(>2GB)（默认: 启用）"
    echo "  --keep-large-files      保留大型输出文件（默认: 禁用）"
    echo "  -h                      显示此帮助信息"
    echo
    # 直接退出而不触发清理函数
    trap - EXIT INT TERM ERR
    exit 1
}

# 解析命令行选项
while getopts ":n:p:i:t:o:j:u:e:m:-:" opt; do
    case ${opt} in
        n )
            config_type="$OPTARG"
            # *** MODIFIED getopts case for -n ***
            if [[ "$config_type" -eq 1 ]]; then
                config_file="${HICPRO_BASE_DIR}/configs/scCARE_MboI.txt"
            elif [[ "$config_type" -eq 2 ]]; then
                config_file="${HICPRO_BASE_DIR}/configs/hicpro_NlaIII.txt"
            elif [[ "$config_type" -eq 3 ]]; then
                config_file="${HICPRO_BASE_DIR}/configs/hicpro_MboI.txt"
            else
                echo "无效的选项值: -n $OPTARG. 请选择1, 2或3." >&2 # Updated error message
                usage
            fi
            ;;
        p )
            Project_name="$OPTARG"
            ;;
        i )
            input_dir="$OPTARG"
            ;;
        t )
            trim_dir="$OPTARG"
            ;;
        o )
            output_dir="$OPTARG"
            ;;
        j )
            log_dir="$OPTARG"
            ;;
        u )
            cpu="$OPTARG"
            ;;
        e )
            conda_env="$OPTARG"
            ;;
        m )
            run_modules="$OPTARG"
            ;;
        - )
            case "${OPTARG}" in
                HiC-Pro)
                    HiC_Pro_path="${!OPTIND}"; OPTIND=$((OPTIND +1))
                    ;;
                SentEmail)
                    SentEmail_path="${!OPTIND}"; OPTIND=$((OPTIND +1))
                    ;;
                SummaryScript)
                    SummaryScript_path="${!OPTIND}"; OPTIND=$((OPTIND +1))
                    ;;
                JuiceboxScript)
                    JuiceboxScript_path="${!OPTIND}"; OPTIND=$((OPTIND +1))
                    ;;
                JuicerTools)
                    JuicerTools_path="${!OPTIND}"; OPTIND=$((OPTIND +1))
                    ;;
                GenomeSizes)
                    GenomeSizes_path="${!OPTIND}"; OPTIND=$((OPTIND +1))
                    ;;
                GenomeBed)
                    GenomeBed_path="${!OPTIND}"; OPTIND=$((OPTIND +1))
                    ;;
                remove-large-files)
                    remove_large_files=true
                    ;;
                keep-large-files)
                    remove_large_files=false
                    ;;
                *)
                    echo "无效的选项 --${OPTARG}" >&2
                    usage
                    ;;
            esac
            ;;
        h )
            usage
            ;;
        \? )
            echo "无效的选项: -$OPTARG" >&2
            usage
            ;;
        : )
            echo "选项 -$OPTARG 需要一个参数." >&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# 设置配置文件基于选择
# *** MODIFIED post-getopts logic for config_file ***
if [[ "$config_type" -eq 1 ]]; then
    config_file="/data1/Ref/hicpro/configs/scCARE.txt"
elif [[ "$config_type" -eq 2 ]]; then
    config_file="/data1/Ref/hicpro/configs/SCCARE_INlaIIl.txt"
elif [[ "$config_type" -eq 3 ]]; then
    config_file="/data1/Ref/hicpro/configs/hicpro_config.txt"
# Default case (should match initial default if -n is not provided)
# else
#     config_file="/data1/Ref/hicpro/configs/scCARE.txt"
fi

# 检查配置文件是否存在
if [[ ! -f "$config_file" ]]; then
    echo "错误: 配置文件 '$config_file' 不存在。" >&2
    exit 1
fi

# 检查HiC-Pro可执行文件是否存在
if [[ ! -x "$HiC_Pro_path" ]]; then
    echo "错误: HiC-Pro可执行文件 '$HiC_Pro_path' 不存在或不可执行。" >&2
    exit 1
fi

# 检查SentEmail.py脚本是否存在
if [[ ! -f "$SentEmail_path" ]]; then
    echo "错误: SentEmail.py脚本 '$SentEmail_path' 不存在。" >&2
    exit 1
fi

# 检查SummaryScript.pl脚本是否存在
if [[ ! -f "$SummaryScript_path" ]]; then
    echo "错误: SummaryScript.pl脚本 '$SummaryScript_path' 不存在。" >&2
    exit 1
fi

# 检查JuiceboxScript.sh脚本是否存在
if [[ ! -x "$JuiceboxScript_path" ]]; then
    echo "错误: JuiceboxScript.sh脚本 '$JuiceboxScript_path' 不存在或不可执行。" >&2
    exit 1
fi

# 检查JuicerTools.jar文件是否存在
if [[ ! -f "$JuicerTools_path" ]]; then
    echo "错误: JuicerTools.jar文件 '$JuicerTools_path' 不存在。" >&2
    exit 1
fi

# 检查GenomeSizes文件是否存在
if [[ ! -f "$GenomeSizes_path" ]]; then
    echo "错误: GenomeSizes文件 '$GenomeSizes_path' 不存在。" >&2
    exit 1
fi

# 检查GenomeBed文件是否存在
if [[ ! -f "$GenomeBed_path" ]]; then
    echo "错误: GenomeBed文件 '$GenomeBed_path' 不存在。" >&2
    exit 1
fi

# 激活指定的Conda环境
echo "正在激活Conda环境: $conda_env"
if ! command -v conda &> /dev/null; then
    echo "错误: conda 未安装或未在PATH中。" >&2
    exit 1
fi

# 初始化conda
source "$(conda info --base)/etc/profile.d/conda.sh"

# 激活环境
if ! conda activate "$conda_env"; then
    echo "错误: 无法激活Conda环境 '$conda_env'" >&2
    exit 1
fi

# 获取当前时间
current_time=$(date +"%Y%m%d-%H%M%S")
logfile="${Project_name}_${current_time}_log.txt"

# 创建日志目录
mkdir -p "$log_dir"

# 开始记录日志
{
    echo "=== Pipeline 开始于 $(date) ==="
    echo "项目名称: $Project_name"
    echo "输入目录: $input_dir"
    echo "修剪目录: $trim_dir"
    echo "输出目录: $output_dir"
    echo "日志目录: $log_dir"
    echo "配置文件: $config_file"
    echo "并行CPU数量: $cpu"
    echo "Conda环境: $conda_env"
    echo "运行模块: $run_modules"
    echo "HiC-Pro路径: $HiC_Pro_path"
    echo "SentEmail.py路径: $SentEmail_path"
    echo "SummaryScript.pl路径: $SummaryScript_path"
    echo "JuiceboxScript.sh路径: $JuiceboxScript_path"
    echo "JuicerTools.jar路径: $JuicerTools_path"
    echo "GenomeSizes路径: $GenomeSizes_path"
    echo "GenomeBed路径: $GenomeBed_path"
    echo "===================================="

    # 检查模块是否要运行
    run_module() {
        local module_num=$1
        echo "$run_modules" | grep -q -E "(^|,)$module_num(,|$)"
    }

    # 模块1: 执行trim_galore (生成Run2_trim)
    if run_module 1; then
        echo "===== 执行模块1: trim_galore处理 ====="
        # 创建修剪目录
        mkdir -p "$trim_dir"

        # 进入输入目录并重命名文件
        cd "$input_dir" || { echo "无法进入目录 '$input_dir'"; exit 1; }
        echo "检查文件格式并重命名..."
        
        # 检查是否已有_R1.fq.gz格式的文件
        if ls *_R1.fq.gz 1> /dev/null 2>&1; then
            echo "检测到文件已经是_R1.fq.gz格式，跳过重命名"
        else
            echo "文件不是标准格式，开始重命名..."
            # 检查是否有_1格式的文件需要重命名为_R1
            if ls *_1.* 1> /dev/null 2>&1; then
                echo "重命名 _1 -> _R1"
                rename _1 _R1 *
            fi
            # 检查是否有_2格式的文件需要重命名为_R2
            if ls *_2.* 1> /dev/null 2>&1; then
                echo "重命名 _2 -> _R2"
                rename _2 _R2 *
            fi
            # 检查是否有.fastq.gz格式的文件需要重命名为.fq.gz
            if ls *.fastq.gz 1> /dev/null 2>&1; then
                echo "重命名 .fastq.gz -> .fq.gz"
                rename .fastq.gz .fq.gz *
            fi
        fi
        cd ..

        # 生成trim_galore脚本
        trim_script="Run2_trim_script.sh"
        > "$trim_script" # 清空或创建trim脚本
        for sample in $(ls "${input_dir}"/*_R1.fq.gz | rev | cut -d "_" -f 2- | rev | sort | uniq); do
            echo "trim_galore -q 20 --phred33 --stringency 3 --length 20 -e 0.1 --paired ${sample}_R1.fq.gz ${sample}_R2.fq.gz --gzip -o ${trim_dir}" >> "$trim_script"
        done
        chmod +x "$trim_script"
        echo "生成trim_galore脚本: $trim_script"

        # 使用ParaFly并行执行trim_galore
        echo "开始运行trim_galore..."
        ParaFly -c "$trim_script" -CPU "$cpu" || { echo "错误: trim_galore 运行失败"; exit 1; }

        # 进入修剪目录并重命名文件
        cd "$trim_dir" || { echo "无法进入目录 '$trim_dir'"; exit 1; }
        echo "重命名修剪后的文件..."
        rename _val_1 "" *
        rename _val_2 "" *

        # 将修剪后的文件移动到各自的子目录
        echo "整理修剪后的文件..."
        for sample in $(ls ../"${input_dir}"/*_R1.fq.gz | xargs -n 1 basename | rev | cut -d "_" -f 2- | rev | sort | uniq); do
            mkdir -p "${sample}"
            mv "${sample}"* "${sample}/" || { echo "警告: 移动文件到 '${sample}/' 失败"; }
        done

        cd ..
        
        # 收集hic文件
        collect_hic_files 1
        echo "===== 模块1完成 ====="
    else
        echo "===== 跳过模块1: trim_galore处理 ====="
    fi

    # 模块2: 执行HiC-Pro (生成Run3_hic)
    if run_module 2; then
        echo "===== 执行模块2: HiC-Pro处理 ====="
        # 运行HiC-Pro
        echo "运行HiC-Pro..."
        "$HiC_Pro_path" -i "${trim_dir}" -o "${output_dir}" -c "${config_file}" || { echo "错误: HiC-Pro 运行失败"; exit 1; }

        # 生成摘要文件
        summary_file="${Project_name}_Summary.txt"
        echo "生成摘要文件..."
        perl "$SummaryScript_path" "${output_dir}" > "${summary_file}" || { echo "错误: 生成摘要文件失败"; exit 1; }

        # 发送摘要邮件
        echo "发送摘要邮件..."
        python "$SentEmail_path" "${Project_name}" "${summary_file}" || { echo "错误: 发送摘要邮件失败"; exit 1; }
        
        # 收集hic文件
        collect_hic_files 2
        echo "===== 模块2完成 ====="
    else
        echo "===== 跳过模块2: HiC-Pro处理 ====="
    fi

    # 模块3: 转换为Juicebox格式并收集.hic文件 (生成Run4_HICdata)
    if run_module 3; then
        echo "===== 执行模块3: Juicebox转换和.hic文件收集 ====="
        # 检查输出目录是否存在
        if [[ ! -d "${output_dir}/hic_results/data" ]]; then
            echo "错误: HiC-Pro输出目录'${output_dir}/hic_results/data'不存在" >&2
            exit 1
        fi

        # 处理HiC-Pro结果并转换为Juicebox格式
        echo "处理HiC-Pro结果并转换为Juicebox格式..."
        cd "${output_dir}/hic_results/data" || { echo "无法进入目录 '${output_dir}/hic_results/data'"; exit 1; }
        for i in *; do
            echo "处理样本: $i"
            cd "${i}"* || { echo "无法进入样本目录 '${i}'"; continue; }
            mkdir -p "${i}"
            ls *all* || { echo "警告: 在样本 '${i}' 中找不到 *all* 文件"; }
            bash "$JuiceboxScript_path" \
                -i *.allValidPairs \
                -g "$GenomeSizes_path" \
                -j "$JuicerTools_path" \
                -r "$GenomeBed_path" \
                -o "${i}" || { echo "错误: Juicebox转换失败 for sample '${i}'"; }
            cd ..
        done

        # 返回项目根目录
        cd ../../../..

        # 如果启用了删除大文件选项，则删除大于2GB的文件
        if [[ "$remove_large_files" = true ]]; then
            echo "正在删除大型输出文件（>2GB）..."
            large_files=$(find "${output_dir}" -type f -size +2G)
            if [[ -n "$large_files" ]]; then
                echo "以下大型文件将被删除:"
                echo "$large_files" | while read -r file; do
                    echo "- $file ($(du -h "$file" 2>/dev/null | cut -f1))"
                done
                find "${output_dir}" -type f -size +2G -delete || { echo "警告: 删除大型文件失败"; }
                echo "大型文件已删除"
            else
                echo "未找到需要删除的大型文件"
            fi
        else
            echo "已选择保留所有输出文件"
        fi

        # 收集hic文件
        collect_hic_files 3
        echo "===== 模块3完成 ====="
    else
        echo "===== 跳过模块3: Juicebox转换和.hic文件收集 ====="
    fi

    # 模块4: 单纯移动.hic文件到Run4_HICdata文件夹
    if run_module 4; then
        echo "===== 执行模块4: 移动.hic文件到Run4_HICdata_m4 ====="
        
        # 创建Run4_HICdata_m4目录
        hic_target_dir="Run4_HICdata_m4"
        mkdir -p "$hic_target_dir"
        
        echo "搜索所有.hic文件..."
        # 查找当前目录及子目录中的所有.hic文件
        hic_files=$(find . -name "*.hic" -type f 2>/dev/null)
        
        if [[ -n "$hic_files" ]]; then
            echo "找到以下.hic文件，准备移动到${hic_target_dir}:"
            file_count=0
            while IFS= read -r file; do
                if [[ -f "$file" ]]; then
                    filename=$(basename "$file")
                    source_dir=$(dirname "$file")
                    echo "- $filename (来源: $source_dir)"
                    
                    # 检查目标文件是否已存在
                    if [[ -f "$hic_target_dir/$filename" ]]; then
                        echo "  警告: 目标文件${hic_target_dir}/${filename}已存在，跳过移动"
                    else
                        # 移动文件而不是复制
                        if mv "$file" "$hic_target_dir/"; then
                            echo "  已移动到${hic_target_dir}/"
                            ((file_count++))
                        else
                            echo "  错误: 移动文件失败"
                        fi
                    fi
                fi
            done <<< "$hic_files"
            echo "模块4完成，共移动了 ${file_count} 个.hic文件到${hic_target_dir}/"
        else
            echo "未找到任何.hic文件"
        fi
        
        echo "===== 模块4完成 ====="
    else
        echo "===== 跳过模块4: 移动.hic文件到Run4_HICdata_m4 ====="
    fi

    # 发送完成邮件
    echo "发送完成邮件..."
    python "$SentEmail_path" "${Project_name}_trans" "end" || { echo "错误: 发送完成邮件失败"; exit 1; }

    echo "=== Pipeline 结束于 $(date) ==="
} | tee -a "${log_dir}/${logfile}"

# 退出Conda环境
# conda deactivate

exit 0