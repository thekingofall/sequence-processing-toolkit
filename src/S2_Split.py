#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import gzip
import os
import sys
from pathlib import Path

def get_reverse_complement(dna_sequence):
    """
    计算DNA序列的反向互补序列
    """
    complement_map = str.maketrans("ATCGatcgNn", "TAGCtagcNn")
    complemented_seq = dna_sequence.translate(complement_map)
    return complemented_seq[::-1]

def find_separators_in_sequence(sequence, sep1_fwd, sep1_rc, sep2_fwd, sep2_rc):
    """
    在序列中查找分隔符的所有可能组合
    返回: (sep1_pos, sep1_end, sep2_pos, orientation)
    orientation: 'forward', 'reverse', 'mixed_fwd_rc', 'mixed_rc_fwd'
    """
    results = []
    
    # 1. 正向组合: sep1_fwd + sep2_fwd
    sep1_pos = sequence.find(sep1_fwd)
    if sep1_pos != -1:
        sep1_end = sep1_pos + len(sep1_fwd)
        sep2_pos = sequence.find(sep2_fwd, sep1_end)
        if sep2_pos != -1:
            results.append((sep1_pos, sep1_end, sep2_pos, 'forward'))
    
    # 2. 反向互补组合: sep1_rc + sep2_rc
    sep1_pos = sequence.find(sep1_rc)
    if sep1_pos != -1:
        sep1_end = sep1_pos + len(sep1_rc)
        sep2_pos = sequence.find(sep2_rc, sep1_end)
        if sep2_pos != -1:
            results.append((sep1_pos, sep1_end, sep2_pos, 'reverse'))
    
    # 3. 混合组合1: sep1_fwd + sep2_rc
    sep1_pos = sequence.find(sep1_fwd)
    if sep1_pos != -1:
        sep1_end = sep1_pos + len(sep1_fwd)
        sep2_pos = sequence.find(sep2_rc, sep1_end)
        if sep2_pos != -1:
            results.append((sep1_pos, sep1_end, sep2_pos, 'mixed_fwd_rc'))
    
    # 4. 混合组合2: sep1_rc + sep2_fwd
    sep1_pos = sequence.find(sep1_rc)
    if sep1_pos != -1:
        sep1_end = sep1_pos + len(sep1_rc)
        sep2_pos = sequence.find(sep2_fwd, sep1_end)
        if sep2_pos != -1:
            results.append((sep1_pos, sep1_end, sep2_pos, 'mixed_rc_fwd'))
    
    # 返回最佳匹配（最短的R2序列，通常更可靠）
    if results:
        # 按R2长度排序，选择最短的
        results.sort(key=lambda x: x[2] - x[1])
        return results[0]
    
    return None

def split_fastq_by_sequences_paired(input_file, output_dir, separator1, separator2, min_length=10):
    """
    根据两个分隔符序列分割FASTQ文件，确保R1和R2完全配对
    支持反向互补匹配
    
    Args:
        input_file: 输入的FASTQ.gz文件路径
        output_dir: 输出目录
        separator1: 第一个分隔符序列 (GATCATGTCGGAACTGTTGCTTGTCCGACTGATC)
        separator2: 第二个分隔符序列 (AGATCGGAAGA)
        min_length: 分割后序列的最小长度
    """
    
    # 计算反向互补序列
    sep1_fwd = separator1
    sep1_rc = get_reverse_complement(separator1)
    sep2_fwd = separator2
    sep2_rc = get_reverse_complement(separator2)
    
    # 创建输出目录
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # 准备输出文件名
    input_filename = Path(input_file).name
    base_name = input_filename.replace('.fq.gz', '').replace('.fastq.gz', '')
    
    r1_output = output_path / f"{base_name}_R1.fq.gz"
    r2_output = output_path / f"{base_name}_R2.fq.gz"
    discarded_output = output_path / f"{base_name}_discarded.fq.gz"
    
    # 统计计数器
    total_reads = 0
    paired_reads = 0  # 成功配对的reads数
    discarded_reads = 0  # 丢弃的reads数
    
    # 方向统计
    orientation_stats = {
        'forward': 0,
        'reverse': 0,
        'mixed_fwd_rc': 0,
        'mixed_rc_fwd': 0
    }
    
    print(f"开始处理文件: {input_file}")
    print(f"正向分隔符1: {sep1_fwd}")
    print(f"反向分隔符1: {sep1_rc}")
    print(f"正向分隔符2: {sep2_fwd}")
    print(f"反向分隔符2: {sep2_rc}")
    print(f"输出目录: {output_dir}")
    print(f"最小长度要求: {min_length}")
    
    try:
        with gzip.open(input_file, 'rt', errors='ignore') as infile, \
             gzip.open(r1_output, 'wt') as r1_file, \
             gzip.open(r2_output, 'wt') as r2_file, \
             gzip.open(discarded_output, 'wt') as discarded_file:
            
            while True:
                # 读取FASTQ的4行记录
                header = infile.readline().strip()
                if not header:
                    break
                    
                sequence = infile.readline().strip()
                plus = infile.readline().strip()
                quality = infile.readline().strip()
                
                # 检查是否是完整的FASTQ记录
                if not header.startswith('@') or not plus.startswith('+'):
                    print(f"警告: 跳过格式错误的记录，行号约为 {total_reads * 4}")
                    continue
                
                total_reads += 1
                
                # 查找分隔符（包括反向互补）
                result = find_separators_in_sequence(sequence, sep1_fwd, sep1_rc, sep2_fwd, sep2_rc)
                
                if result:
                    sep1_pos, sep1_end, sep2_pos, orientation = result
                    
                    # R1: 从开始到第一个分隔符之前
                    r1_seq = sequence[:sep1_pos]
                    r1_qual = quality[:sep1_pos]
                    
                    # R2: 从第一个分隔符结束到第二个分隔符之前
                    r2_seq = sequence[sep1_end:sep2_pos]
                    r2_qual = quality[sep1_end:sep2_pos]
                    
                    # 检查长度是否满足要求
                    if len(r1_seq) >= min_length and len(r2_seq) >= min_length:
                        # 同时写入R1和R2，确保配对
                        read_id = header.split()[0]  # 获取read ID（去掉可能的描述）
                        
                        # 写入R1
                        r1_file.write(f"{read_id}/1\n")
                        r1_file.write(f"{r1_seq}\n")
                        r1_file.write(f"+\n")
                        r1_file.write(f"{r1_qual}\n")
                        
                        # 写入R2
                        r2_file.write(f"{read_id}/2\n")
                        r2_file.write(f"{r2_seq}\n")
                        r2_file.write(f"+\n")
                        r2_file.write(f"{r2_qual}\n")
                        
                        paired_reads += 1
                        orientation_stats[orientation] += 1
                    else:
                        # 长度不满足要求，丢弃
                        discarded_file.write(f"{header}\n")
                        discarded_file.write(f"{sequence}\n")
                        discarded_file.write(f"{plus}\n")
                        discarded_file.write(f"{quality}\n")
                        discarded_reads += 1
                        
                else:
                    # 没有找到合适的分隔符组合，丢弃
                    discarded_file.write(f"{header}\n")
                    discarded_file.write(f"{sequence}\n")
                    discarded_file.write(f"{plus}\n")
                    discarded_file.write(f"{quality}\n")
                    discarded_reads += 1
                
                # 每处理10000条记录打印一次进度
                if total_reads % 10000 == 0:
                    print(f"已处理 {total_reads} 条reads，配对 {paired_reads} 条...")
    
    except Exception as e:
        print(f"处理文件时发生错误: {e}", file=sys.stderr)
        return False
    
    # 打印统计结果
    print(f"\n=== 处理完成统计 ===")
    print(f"总reads数: {total_reads}")
    print(f"成功配对的reads数: {paired_reads}")
    print(f"丢弃的reads数: {discarded_reads}")
    print(f"配对成功率: {paired_reads / total_reads * 100:.2f}%")
    
    print(f"\n=== 方向统计 ===")
    print(f"正向匹配 (sep1_fwd + sep2_fwd): {orientation_stats['forward']}")
    print(f"反向匹配 (sep1_rc + sep2_rc): {orientation_stats['reverse']}")
    print(f"混合匹配1 (sep1_fwd + sep2_rc): {orientation_stats['mixed_fwd_rc']}")
    print(f"混合匹配2 (sep1_rc + sep2_fwd): {orientation_stats['mixed_rc_fwd']}")
    
    print(f"\n输出文件:")
    print(f"R1: {r1_output} ({paired_reads} reads)")
    print(f"R2: {r2_output} ({paired_reads} reads)")
    print(f"丢弃: {discarded_output} ({discarded_reads} reads)")
    
    # 验证配对
    print(f"\n=== 配对验证 ===")
    print(f"R1文件reads数 = R2文件reads数: {paired_reads == paired_reads} ✓")
    
    return True

def main():
    parser = argparse.ArgumentParser(
        description="根据指定的分隔符序列分割FASTQ文件为配对的R1和R2\n支持反向互补匹配",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument(
        "-i", "--input",
        required=True,
        help="输入的FASTQ.gz文件路径"
    )
    
    parser.add_argument(
        "-o", "--output",
        required=True,
        help="输出目录路径"
    )
    
    parser.add_argument(
        "--sep1",
        default="GATCATGTCGGAACTGTTGCTTGTCCGACTGATC",
        help="第一个分隔符序列 (默认: GATCATGTCGGAACTGTTGCTTGTCCGACTGATC)"
    )
    
    parser.add_argument(
        "--sep2", 
        default="AGATCGGAAGA",
        help="第二个分隔符序列 (默认: AGATCGGAAGA)"
    )
    
    parser.add_argument(
        "--min-length",
        type=int,
        default=10,
        help="分割后序列的最小长度 (默认: 10)"
    )
    
    args = parser.parse_args()
    
    # 检查输入文件是否存在
    if not os.path.isfile(args.input):
        print(f"错误: 输入文件 '{args.input}' 不存在", file=sys.stderr)
        sys.exit(1)
    
    # 执行分割
    success = split_fastq_by_sequences_paired(
        args.input,
        args.output,
        args.sep1.upper(),  # 转换为大写以确保匹配
        args.sep2.upper(),  # 转换为大写以确保匹配
        args.min_length
    )
    
    if success:
        print("配对分割完成!")
    else:
        print("分割失败!", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main() 
