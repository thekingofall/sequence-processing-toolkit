#!/bin/bash

# 便利清理脚本 - 调用Scripts目录中的clean_results.sh
# 使用方法:
#   ./clean.sh              # 交互式清理
#   ./clean.sh --all        # 清理所有组
#   ./clean.sh Group1_MboI_GATC_SeqA  # 清理指定组

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 调用实际的脚本
exec "${SCRIPT_DIR}/Scripts/clean_results.sh" "$@" 