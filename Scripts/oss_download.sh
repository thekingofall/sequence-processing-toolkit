#!/bin/bash
# OSS数据下载脚本
# 创建日期: $(date +%Y-%m-%d)
# 使用方法: ./oss_download.sh -i <input_file> -o <output_dir>

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    cat << EOF
${GREEN}=== OSS数据下载脚本 ===${NC}

${BLUE}使用方法:${NC}
    $0 -i <input_file> -o <output_dir>
    $0 --input <input_file> --output <output_dir>

${BLUE}参数说明:${NC}
    -i, --input     输入文件路径，包含要下载的OSS路径列表（每行一个路径）
    -o, --output    输出目录路径，下载的数据将保存到此目录
    -h, --help      显示此帮助信息

${BLUE}输入文件格式示例:${NC}
    oss://bucket-name/path1/data1
    oss://bucket-name/path2/data2
    oss://bucket-name/path3/data3

${BLUE}使用示例:${NC}
    $0 -i oss_paths.txt -o ./downloads
    $0 --input /path/to/paths.txt --output /path/to/output

EOF
}

# 初始化变量
INPUT_FILE=""
OUTPUT_DIR=""

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            INPUT_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知参数 '$1'${NC}"
            echo -e "${YELLOW}使用 '$0 --help' 查看帮助信息${NC}"
            exit 1
            ;;
    esac
done

# 验证必需参数
if [[ -z "$INPUT_FILE" || -z "$OUTPUT_DIR" ]]; then
    echo -e "${RED}错误: 缺少必需参数${NC}"
    echo -e "${YELLOW}使用方法: $0 -i <input_file> -o <output_dir>${NC}"
    echo -e "${YELLOW}使用 '$0 --help' 查看详细帮助${NC}"
    exit 1
fi

# 验证输入文件是否存在
if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}错误: 输入文件不存在: $INPUT_FILE${NC}"
    exit 1
fi

# 验证输入文件是否为空
if [[ ! -s "$INPUT_FILE" ]]; then
    echo -e "${RED}错误: 输入文件为空: $INPUT_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}=== OSS数据下载脚本 ===${NC}"
echo -e "${BLUE}输入文件: $INPUT_FILE${NC}"
echo -e "${BLUE}输出目录: $OUTPUT_DIR${NC}"

# 读取OSS路径到数组
OSS_PATHS=()
while IFS= read -r line; do
    # 跳过空行和注释行
    if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
        OSS_PATHS+=("$line")
    fi
done < "$INPUT_FILE"

# 检查是否有有效的OSS路径
if [[ ${#OSS_PATHS[@]} -eq 0 ]]; then
    echo -e "${RED}错误: 输入文件中没有找到有效的OSS路径${NC}"
    echo -e "${YELLOW}请确保文件包含以 'oss://' 开头的路径，每行一个${NC}"
    exit 1
fi

echo -e "${GREEN}发现 ${#OSS_PATHS[@]} 个下载路径${NC}"

# 创建输出目录（支持嵌套目录）
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}错误: 无法创建输出目录: $OUTPUT_DIR${NC}"
        exit 1
    fi
fi

# 转换为绝对路径
OUTPUT_DIR=$(realpath "$OUTPUT_DIR")
echo -e "${GREEN}输出目录: $OUTPUT_DIR${NC}"

# 设置用户bin目录
USER_BIN_DIR="$HOME/bin"
OSSUTIL_PATH="$USER_BIN_DIR/ossutil"

# 创建用户bin目录
mkdir -p "$USER_BIN_DIR"

# 检查ossutil是否已安装
if [ ! -f "$OSSUTIL_PATH" ] && ! command -v ossutil &> /dev/null; then
    echo -e "${YELLOW}警告: ossutil未找到，开始安装到用户目录...${NC}"
    
    # 下载并安装ossutil到用户目录
    echo -e "${YELLOW}下载ossutil到 $USER_BIN_DIR ...${NC}"
    wget -O "$OSSUTIL_PATH" https://gosspublic.alicdn.com/ossutil/1.7.18/ossutil64
    
    if [ $? -eq 0 ]; then
        chmod +x "$OSSUTIL_PATH"
        echo -e "${GREEN}ossutil安装成功到: $OSSUTIL_PATH${NC}"
        
        # 提示用户添加到PATH
        if [[ ":$PATH:" != *":$USER_BIN_DIR:"* ]]; then
            echo -e "${YELLOW}提示: 建议将 $USER_BIN_DIR 添加到您的PATH环境变量中${NC}"
            echo -e "${YELLOW}可以在 ~/.bashrc 或 ~/.profile 中添加:${NC}"
            echo -e "${YELLOW}export PATH=\"\$HOME/bin:\$PATH\"${NC}"
        fi
    else
        echo -e "${RED}ossutil下载失败${NC}"
        exit 1
    fi
else
    if [ -f "$OSSUTIL_PATH" ]; then
        echo -e "${GREEN}✓ 使用本地ossutil: $OSSUTIL_PATH${NC}"
    else
        echo -e "${GREEN}✓ 使用系统ossutil${NC}"
        OSSUTIL_PATH="ossutil"
    fi
fi

# 配置ossutil（如果没有配置文件）
if [ ! -f ~/.ossutilconfig ]; then
    echo -e "${YELLOW}需要配置OSS访问凭证${NC}"
    echo "请按照提示输入您的OSS配置信息："
    echo "如果您没有AccessKey，请联系数据提供方获取"
    
    "$OSSUTIL_PATH" config
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}OSS配置失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ OSS配置文件存在${NC}"
fi

# 测试OSS连接
echo -e "${YELLOW}测试OSS连接...${NC}"
first_bucket=$(echo "${OSS_PATHS[0]}" | cut -d'/' -f3)
"$OSSUTIL_PATH" ls "oss://$first_bucket/" --limited-num 1 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ OSS连接测试成功${NC}"
else
    echo -e "${YELLOW}⚠ OSS连接测试失败，但将继续尝试下载${NC}"
    echo -e "${YELLOW}  可能需要检查访问凭证或网络连接${NC}"
fi

# 开始下载数据
echo -e "${GREEN}开始下载OSS数据...${NC}"

# 创建checkpoint目录
CHECKPOINT_DIR="$OUTPUT_DIR/.checkpoint"
mkdir -p "$CHECKPOINT_DIR"

# 初始化统计信息
total_count=${#OSS_PATHS[@]}
success_count=0
failed_count=0
failed_paths=()

for i in "${!OSS_PATHS[@]}"; do
    path="${OSS_PATHS[$i]}"
    echo -e "${YELLOW}下载第 $((i+1))/$total_count 个数据集...${NC}"
    echo "路径: $path"
    
    # 提取文件夹名称作为本地目录名
    folder_name=$(basename "$path")
    local_dir="$OUTPUT_DIR/$folder_name"
    
    echo "本地目录: $local_dir"
    
    # 首先检查远程路径是否存在
    echo -e "${YELLOW}检查远程路径...${NC}"
    "$OSSUTIL_PATH" ls "$path" --limited-num 1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ 远程路径不存在或无权限访问${NC}"
        failed_count=$((failed_count + 1))
        failed_paths+=("$path")
        continue
    fi
    
    echo -e "${YELLOW}开始下载（带进度显示）...${NC}"
    
    # 使用ossutil下载，添加详细参数
    "$OSSUTIL_PATH" cp -r "$path" "$local_dir" \
        --update \
        --jobs 3 \
        --part-size 104857600 \
        --bigfile-threshold 104857600 \
        --checkpoint-dir "$CHECKPOINT_DIR"
    
    download_result=$?
    
    if [ $download_result -eq 0 ]; then
        echo -e "${GREEN}✓ 数据集 $((i+1)) 下载完成${NC}"
        success_count=$((success_count + 1))
        
        # 显示下载内容大小
        if [ -d "$local_dir" ]; then
            size=$(du -sh "$local_dir" 2>/dev/null | cut -f1)
            echo -e "${GREEN}  下载大小: $size${NC}"
        fi
    else
        echo -e "${RED}✗ 数据集 $((i+1)) 下载失败 (退出码: $download_result)${NC}"
        failed_count=$((failed_count + 1))
        failed_paths+=("$path")
    fi
    
    echo "----------------------------------------"
done

echo -e "${GREEN}=== 下载完成 ===${NC}"
echo -e "${GREEN}成功: $success_count/$total_count${NC}"
echo -e "${RED}失败: $failed_count/$total_count${NC}"
echo "所有数据已下载到: $OUTPUT_DIR"

# 显示下载的内容
if [ $success_count -gt 0 ]; then
echo -e "${GREEN}下载内容概览:${NC}"
    du -sh "$OUTPUT_DIR"/*/ 2>/dev/null | grep -v "\.checkpoint"
fi

# 生成下载报告
cat > "$OUTPUT_DIR/download_report.txt" << EOF
OSS数据下载报告
===============

下载时间: $(date)
输入文件: $INPUT_FILE  
输出目录: $OUTPUT_DIR

下载统计:
- 总计: $total_count 个数据集
- 成功: $success_count 个
- 失败: $failed_count 个

成功下载的数据集:
$(for i in "${!OSS_PATHS[@]}"; do
    path="${OSS_PATHS[$i]}"
    folder_name=$(basename "$path")
    local_dir="$OUTPUT_DIR/$folder_name"
    if [ -d "$local_dir" ]; then
        size=$(du -sh "$local_dir" 2>/dev/null | cut -f1)
        echo "$((i+1)). $folder_name (大小: $size)"
    fi
done)

失败的路径:
$(for path in "${failed_paths[@]}"; do
    echo "- $path"
done)

总下载大小: $(du -sh "$OUTPUT_DIR" 2>/dev/null | cut -f1)
EOF

echo -e "${GREEN}下载报告已保存至: $OUTPUT_DIR/download_report.txt${NC}"

# 如果有失败的下载，提供重试建议
if [ $failed_count -gt 0 ]; then
    echo -e "${YELLOW}提示: 如需重试失败的下载，可以创建新的输入文件包含失败的路径后重新运行${NC}"
fi

