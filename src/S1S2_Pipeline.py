#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import sys
import glob
import subprocess
from pathlib import Path
from datetime import datetime

# --- Default Values ---
DEFAULT_INPUT_PATTERN = "*gz"
DEFAULT_S1_OUTPUT_DIR = "S1_Matched"
DEFAULT_S2_OUTPUT_DIR = "S2_Split"
DEFAULT_SEQUENCE_DESCRIPTION = "S1S2串联处理"
DEFAULT_LINES_TO_PROCESS = 100000

def run_s1_process(patterns, input_pattern, s1_output_dir, description, lines_to_process, jobs):
    """
    运行S1处理步骤
    """
    print(f"\n=== 第一步: 运行S1序列匹配处理 ===")
    
    s1_script = Path(__file__).parent / "S1_Process_gen.py"
    if not s1_script.exists():
        print(f"错误: 找不到S1脚本: {s1_script}", file=sys.stderr)
        return False
    
    # 构建S1命令
    s1_cmd = [
        sys.executable, str(s1_script),
        "-p", patterns,
        "-d", description,
        "-i", input_pattern,
        "-N", str(lines_to_process),
        "--write-matching-reads",
        "--fastq-output-dir", s1_output_dir
    ]
    
    if jobs:
        s1_cmd.extend(["-j", str(jobs)])
    
    print(f"执行命令: {' '.join(s1_cmd)}")
    
    try:
        result = subprocess.run(s1_cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        print("S1处理成功完成!")
        print("S1输出:")
        print(result.stdout)
        if result.stderr:
            print("S1警告/信息:")
            print(result.stderr)
        return True
    except subprocess.CalledProcessError as e:
        print(f"S1处理失败: {e}", file=sys.stderr)
        print(f"错误输出: {e.stderr}", file=sys.stderr)
        return False

def run_s2_split(s1_output_dir, s2_output_dir, sep1, sep2, min_length, r1_only=True):
    """
    运行S2分割步骤
    """
    print(f"\n=== 第二步: 运行S2序列分割处理 ===")
    
    s2_script = Path(__file__).parent / "S2_Split.py"
    if not s2_script.exists():
        print(f"错误: 找不到S2脚本: {s2_script}", file=sys.stderr)
        return False
    
    # 查找S1输出的文件
    s1_files = glob.glob(os.path.join(s1_output_dir, "*.gz"))
    if not s1_files:
        print(f"错误: 在 {s1_output_dir} 中未找到任何.gz文件", file=sys.stderr)
        return False
    
    print(f"找到 {len(s1_files)} 个S1输出文件")
    
    success_count = 0
    failed_files = []
    
    for s1_file in s1_files:
        file_name = Path(s1_file).name
        print(f"\n处理文件: {file_name}")
        
        # 为每个文件创建独立的输出目录
        file_base_name = file_name.replace('.gz', '').replace('.fq', '').replace('.fastq', '')
        file_output_dir = Path(s2_output_dir) / file_base_name
        
        # 构建S2命令
        s2_cmd = [
            sys.executable, str(s2_script),
            "-i", s1_file,
            "-o", str(file_output_dir),
            "--sep1", sep1,
            "--sep2", sep2,
            "--min-length", str(min_length)
        ]
        
        print(f"执行命令: {' '.join(s2_cmd)}")
        
        try:
            result = subprocess.run(s2_cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            print(f"✓ {file_name} 处理成功!")
            print("S2输出:")
            print(result.stdout)
            if result.stderr:
                print("S2警告/信息:")
                print(result.stderr)
            success_count += 1
        except subprocess.CalledProcessError as e:
            print(f"✗ {file_name} 处理失败: {e}", file=sys.stderr)
            print(f"错误输出: {e.stderr}", file=sys.stderr)
            failed_files.append(file_name)
    
    print(f"\n=== S2处理完成统计 ===")
    print(f"成功处理: {success_count}/{len(s1_files)} 个文件")
    
    if failed_files:
        print(f"失败文件: {', '.join(failed_files)}")
        return False
    
    return True

def generate_summary_report(s1_output_dir, s2_output_dir, patterns, description):
    """
    生成处理总结报告
    """
    print(f"\n=== 生成处理总结报告 ===")
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = Path(s2_output_dir) / f"S1S2_Pipeline_Report_{timestamp}.txt"
    
    try:
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("S1S2 串联处理流程报告\n")
            f.write("=" * 50 + "\n")
            f.write(f"处理时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"查询序列: {patterns}\n")
            f.write(f"序列描述: {description}\n")
            f.write(f"S1输出目录: {s1_output_dir}\n")
            f.write(f"S2输出目录: {s2_output_dir}\n\n")
            
            # 统计S1输出文件
            s1_files = glob.glob(os.path.join(s1_output_dir, "*.gz"))
            f.write(f"S1输出文件数: {len(s1_files)}\n")
            for s1_file in s1_files:
                f.write(f"  - {Path(s1_file).name}\n")
            
            f.write("\n")
            
            # 统计S2输出目录
            s2_dirs = [d for d in Path(s2_output_dir).iterdir() if d.is_dir()]
            f.write(f"S2输出目录数: {len(s2_dirs)}\n")
            for s2_dir in s2_dirs:
                f.write(f"  - {s2_dir.name}/\n")
                # 列出每个目录中的文件
                s2_files = list(s2_dir.glob("*.gz"))
                for s2_file in s2_files:
                    f.write(f"    * {s2_file.name}\n")
            
            f.write("\n处理流程:\n")
            f.write("1. S1_Process_gen.py: 从原始文件中筛选匹配指定序列模式的reads\n")
            f.write("2. S2_Split.py: 将匹配的reads根据分隔符分割为R1和R2配对文件\n")
            
        print(f"报告已生成: {report_file}")
        return True
        
    except Exception as e:
        print(f"生成报告失败: {e}", file=sys.stderr)
        return False

def main():
    parser = argparse.ArgumentParser(
        description="S1S2串联处理流程：先用S1筛选匹配序列的reads，再用S2将匹配的reads分割为R1/R2配对文件",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    # S1相关参数
    parser.add_argument(
        "-p", "--patterns",
        required=True,
        help="(必需) 逗号分隔的多个原始搜索序列，用于S1筛选"
    )
    parser.add_argument(
        "-d", "--description",
        default=DEFAULT_SEQUENCE_DESCRIPTION,
        help=f"(可选) 对当前查询的序列组合的描述性名称。默认: '{DEFAULT_SEQUENCE_DESCRIPTION}'"
    )
    parser.add_argument(
        "-i", "--input-pattern",
        default=DEFAULT_INPUT_PATTERN,
        help=f"(可选) 输入 .gz 文件的匹配模式。默认: '{DEFAULT_INPUT_PATTERN}'"
    )
    parser.add_argument(
        "-N", "--lines",
        type=str,
        default=str(DEFAULT_LINES_TO_PROCESS),
        help=f"(可选) S1处理：每个文件的前N行。输入'all'处理所有行。默认: {DEFAULT_LINES_TO_PROCESS}"
    )
    parser.add_argument(
        "-j", "--jobs",
        type=int,
        default=None,
        help="(可选) S1处理：并行处理的最大任务数"
    )
    
    # S2相关参数
    parser.add_argument(
        "--sep1",
        default="GATCATGTCGGAACTGTTGCTTGTCCGACTGATC",
        help="(可选) S2处理：第一个分隔符序列"
    )
    parser.add_argument(
        "--sep2",
        default="AGATCGGAAGA", 
        help="(可选) S2处理：第二个分隔符序列"
    )
    parser.add_argument(
        "--min-length",
        type=int,
        default=10,
        help="(可选) S2处理：分割后序列的最小长度。默认: 10"
    )
    
    # 输出目录参数
    parser.add_argument(
        "--s1-output-dir",
        default=DEFAULT_S1_OUTPUT_DIR,
        help=f"(可选) S1输出目录。默认: '{DEFAULT_S1_OUTPUT_DIR}'"
    )
    parser.add_argument(
        "--s2-output-dir", 
        default=DEFAULT_S2_OUTPUT_DIR,
        help=f"(可选) S2输出目录。默认: '{DEFAULT_S2_OUTPUT_DIR}'"
    )
    
    # 流程控制参数
    parser.add_argument(
        "--skip-s1",
        action="store_true",
        help="(可选) 跳过S1步骤，直接使用现有的S1输出目录进行S2处理"
    )
    
    args = parser.parse_args()
    
    print("S1S2 串联处理流程开始")
    print("=" * 50)
    print(f"查询序列: {args.patterns}")
    print(f"序列描述: {args.description}")
    print(f"输入模式: {args.input_pattern}")
    print(f"S1输出目录: {args.s1_output_dir}")
    print(f"S2输出目录: {args.s2_output_dir}")
    
    success = True
    
    # 第一步：运行S1处理（除非跳过）
    if not args.skip_s1:
        success = run_s1_process(
            args.patterns,
            args.input_pattern, 
            args.s1_output_dir,
            args.description,
            args.lines,
            args.jobs
        )
        
        if not success:
            print("S1处理失败，终止流程", file=sys.stderr)
            sys.exit(1)
    else:
        print("\n=== 跳过S1步骤，使用现有S1输出 ===")
        if not Path(args.s1_output_dir).exists():
            print(f"错误: S1输出目录不存在: {args.s1_output_dir}", file=sys.stderr)
            sys.exit(1)
    
    # 第二步：运行S2处理
    success = run_s2_split(
        args.s1_output_dir,
        args.s2_output_dir,
        args.sep1,
        args.sep2,
        args.min_length
    )
    
    if not success:
        print("S2处理失败", file=sys.stderr)
        sys.exit(1)
    
    # 第三步：生成总结报告
    generate_summary_report(
        args.s1_output_dir,
        args.s2_output_dir, 
        args.patterns,
        args.description
    )
    
    print("\n" + "=" * 50)
    print("S1S2 串联处理流程成功完成!")
    print(f"最终输出目录: {args.s2_output_dir}")
    print("流程说明:")
    print("1. S1步骤: 筛选包含指定序列模式的reads")
    print("2. S2步骤: 将筛选的reads按分隔符分割为R1/R2配对文件")
    print("3. 每个原始文件生成独立的R1/R2配对文件")

if __name__ == "__main__":
    main() 