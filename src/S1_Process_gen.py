#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import gzip
import glob
import os
import sys
from datetime import datetime
import concurrent.futures
from pathlib import Path
import shutil # For nproc equivalent check

# --- Default Values ---
DEFAULT_INPUT_PATTERN = "*gz"
DEFAULT_OUTPUT_DIR_COUNTS = "CountFold" # For the summary TSV file
DEFAULT_OUTPUT_DIR_FASTQ = "Outfastq"  # Default for matched FASTQ records
DEFAULT_UNMATCHED_SUBDIR = "Unmap"   # Subdirectory for unmatched reads
DEFAULT_LINES_TO_PROCESS = 100000
DEFAULT_SEQUENCE_DESCRIPTION = "未说明序列名字"
DEFAULT_MAX_JOBS_FALLBACK = 4

# --- Helper Functions ---

def get_reverse_complement(dna_sequence):
    """
    Calculates the reverse complement of a DNA sequence.
    Handles both upper and lower case.
    """
    complement_map = str.maketrans("ATCGatcg", "TAGCTAGC")
    complemented_seq = dna_sequence.translate(complement_map)
    return complemented_seq[::-1]

def get_cpu_count():
    """
    Tries to get the number of CPU cores.
    Falls back to DEFAULT_MAX_JOBS_FALLBACK if nproc is not available or fails.
    """
    nproc_path = shutil.which("nproc")
    if nproc_path:
        try:
            import subprocess
            result = subprocess.run([nproc_path], capture_output=True, text=True, check=True)
            return int(result.stdout.strip())
        except Exception:
            return DEFAULT_MAX_JOBS_FALLBACK
    return DEFAULT_MAX_JOBS_FALLBACK

def process_file_worker(args_tuple):
    """
    Worker function to process a single file.
    Args:
        args_tuple (tuple): Contains (
            gz_file_path,
            patterns_string,
            forward_patterns_list,
            rc_patterns_list,
            effective_lines_to_process, # int or None
            process_all_lines_flag,     # bool
            sequence_description_str,
            write_matching_reads_flag,  # bool
            out_fastq_dir_path_str,     # string, path to the directory for matched output FASTQ files
            write_unmatched_reads_flag, # bool
            unmap_output_dir_path_str   # string, path to the directory for unmatched output FASTQ files
        )
    Returns:
        tuple: (sample_name, sequence_description, patterns_string,
                all_fwd_line_count, all_rc_line_count, total_reads_processed,
                fwd_percentage_str, rc_percentage_str)
               or None if file processing failed.
    """
    (gz_file_path, patterns_string, forward_patterns_list, rc_patterns_list,
     effective_lines_to_process, process_all_lines_flag, sequence_description_str,
     write_matching_reads_flag, out_fastq_dir_path_str,
     write_unmatched_reads_flag, unmap_output_dir_path_str) = args_tuple

    base_input_filename = Path(gz_file_path).name
    sample_name = base_input_filename
    if sample_name.endswith(".gz"):
        sample_name = sample_name[:-3]
    if sample_name.endswith(".fq"):
        sample_name = sample_name[:-3]
    elif sample_name.endswith(".fastq"):
        sample_name = sample_name[:-6]

    lines_scanned_content = []
    try:
        with gzip.open(gz_file_path, 'rt', errors='ignore') as f:
            if not process_all_lines_flag and effective_lines_to_process is not None:
                for i, line in enumerate(f):
                    if i >= effective_lines_to_process:
                        break
                    lines_scanned_content.append(line)
            else:
                lines_scanned_content = list(f)
    except Exception as e:
        print(f"警告: 处理文件 '{gz_file_path}' 时发生错误 (读取阶段): {e}", file=sys.stderr)
        return None

    num_lines_scanned = len(lines_scanned_content)
    total_reads_processed = num_lines_scanned // 4

    all_fwd_line_count = 0 # Counts lines where all forward patterns co-occur in sequence
    all_rc_line_count = 0  # Counts lines where all RC patterns co-occur in sequence
    
    # For counting, we check the sequence line of each read.
    # A read matches if its sequence line contains ALL forward patterns OR ALL RC patterns.
    # The counts all_fwd_line_count and all_rc_line_count are based on reads, not individual lines.
    
    # Temporary storage for reads to be written
    matched_reads_to_write = []
    unmatched_reads_to_write = []

    if lines_scanned_content:
        # Iterate through records for counting and preparing for writing
        for i in range(0, num_lines_scanned, 4):
            current_record_lines = lines_scanned_content[i : i + 4]
            if len(current_record_lines) == 4: # Ensure it's a full record
                sequence_line = current_record_lines[1] # Second line is the sequence

                match_fwd = False
                if forward_patterns_list:
                    match_fwd = all(pattern in sequence_line for pattern in forward_patterns_list)

                match_rc = False
                if rc_patterns_list:
                    match_rc = all(rc_pattern in sequence_line for rc_pattern in rc_patterns_list)

                if match_fwd: # Count as a forward match if all forward patterns are present
                    all_fwd_line_count += 1
                if match_rc: # Count as an RC match if all RC patterns are present
                    all_rc_line_count +=1
                # Note: A read could match both fwd and rc criteria if patterns overlap; it's counted for both.
                # The percentages will be based on these counts relative to total_reads_processed.

                if write_matching_reads_flag and (match_fwd or match_rc):
                    matched_reads_to_write.append("".join(current_record_lines))
                elif write_unmatched_reads_flag and not (match_fwd or match_rc): # Only if it didn't match fwd/rc
                    unmatched_reads_to_write.append("".join(current_record_lines))


        # Writing logic
        if write_matching_reads_flag and matched_reads_to_write:
            output_fastq_file_matched = Path(out_fastq_dir_path_str) / base_input_filename # Matched reads go to .gz
            try:
                with gzip.open(output_fastq_file_matched, 'at', errors='ignore') as writer: # 'at' for text mode append
                    for record_str in matched_reads_to_write:
                        writer.write(record_str)
            except Exception as e:
                print(f"警告: 写入匹配的FASTQ记录到 '{output_fastq_file_matched}' 时发生错误: {e}", file=sys.stderr)

        if write_unmatched_reads_flag and unmatched_reads_to_write:
            # Unmatched reads also go to a .gz file inside the unmap directory
            output_fastq_file_unmatched = Path(unmap_output_dir_path_str) / base_input_filename
            try:
                with gzip.open(output_fastq_file_unmatched, 'at', errors='ignore') as writer: # 'at' for text mode append
                    for record_str in unmatched_reads_to_write:
                        writer.write(record_str)
            except Exception as e:
                print(f"警告: 写入未匹配的FASTQ记录到 '{output_fastq_file_unmatched}' 时发生错误: {e}", file=sys.stderr)


    fwd_percentage_str = "N/A"
    rc_percentage_str = "N/A"

    if total_reads_processed > 0:
        # Percentages are based on reads matching the criteria, not lines.
        fwd_percentage = (all_fwd_line_count / total_reads_processed) * 100
        rc_percentage = (all_rc_line_count / total_reads_processed) * 100
        fwd_percentage_str = f"{fwd_percentage:.2f}%"
        rc_percentage_str = f"{rc_percentage:.2f}%"
    elif all_fwd_line_count == 0 and all_rc_line_count == 0 and total_reads_processed == 0:
        pass

    return (sample_name, sequence_description_str, patterns_string,
            all_fwd_line_count, all_rc_line_count, total_reads_processed,
            fwd_percentage_str, rc_percentage_str)

def main():
    parser = argparse.ArgumentParser(
        description="处理序列文件，计数指定序列组合（及其反向互补）的共现情况，支持并行处理和输出匹配及未匹配的FASTQ记录。",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        "-p", "--patterns",
        required=True,
        help="(必需) 逗号分隔的多个原始搜索序列。"
    )
    parser.add_argument(
        "-d", "--description",
        default=DEFAULT_SEQUENCE_DESCRIPTION,
        help=f"(可选) 对当前查询的序列组合的描述性名称。\n默认为 \"{DEFAULT_SEQUENCE_DESCRIPTION}\"。"
    )
    parser.add_argument(
        "-i", "--input-pattern",
        default=DEFAULT_INPUT_PATTERN,
        help=f"(可选) 输入 .gz 文件的匹配模式。\n默认: \"{DEFAULT_INPUT_PATTERN}\""
    )
    parser.add_argument(
        "-o", "--output-file",
        default=None,
        help=f"(可选) TSV总结输出文件的路径和名称。\n"
             f"如果只提供文件名, 文件将保存在 '{DEFAULT_OUTPUT_DIR_COUNTS}/文件名'.\n"
             f"如果省略, 结果将默认保存到 '{DEFAULT_OUTPUT_DIR_COUNTS}/YYYYMMDD_HHMMSS_序列摘要[_m行数].tsv'."
    )
    parser.add_argument(
        "-N", "--lines",
        type=str,
        default=str(DEFAULT_LINES_TO_PROCESS),
        help=f"(可选) 只处理每个文件的前 N 行。\n输入 'all' 处理所有行。默认为 {DEFAULT_LINES_TO_PROCESS} 行。\n如果提供无效数字，则处理所有行。"
    )
    parser.add_argument(
        "-j", "--jobs",
        type=int,
        default=None,
        help=f"(可选) 并行处理文件的最大任务数。\n默认尝试使用CPU核心数，否则为 {DEFAULT_MAX_JOBS_FALLBACK}。"
    )
    parser.add_argument(
        "--write-matching-reads",
        action="store_true",
        help=f"(可选) 如果设置此项, 匹配所有正向序列组合 或 所有反向互补序列组合的FASTQ记录\n"
             f"将被写入输出目录中对应的新文件。\n"
             f"默认输出目录为 '{DEFAULT_OUTPUT_DIR_FASTQ}', 可通过 --fastq-output-dir 参数修改。"
    )
    parser.add_argument(
        "--fastq-output-dir",
        type=str,
        default=None,
        help=f"(可选) 指定输出匹配FASTQ记录的目录。\n"
             f"仅当 --write-matching-reads 设置时生效。\n"
             f"如果未指定, 将使用默认目录 '{DEFAULT_OUTPUT_DIR_FASTQ}'。"
    )
    parser.add_argument(
        "--write-unmatched-reads", # New argument
        action="store_true",
        help=f"(可选) 如果设置此项, 未匹配任何指定序列组合的FASTQ记录将被写入到\n"
             f"'{DEFAULT_UNMATCHED_SUBDIR}' 子目录中 (位于FASTQ输出目录下)。\n"
             f"此选项仅在 --write-matching-reads 也被设置时生效。"
    )

    args = parser.parse_args()

    patterns_string = args.patterns
    sequence_description = args.description

    effective_lines_to_process = None
    process_all_lines_flag = False
    head_param_for_filename = ""

    if args.lines is None or args.lines.lower() == 'all':
        process_all_lines_flag = True
        head_param_for_filename = ""
    else:
        try:
            n_val = int(args.lines)
            if n_val > 0:
                effective_lines_to_process = n_val
                head_param_for_filename = f"_m{n_val}"
            else:
                print(f"警告: -N 的值 '{args.lines}' 不是一个有效的正整数或 'all'。将对每个文件处理所有行。", file=sys.stderr)
                process_all_lines_flag = True
                head_param_for_filename = ""
        except ValueError:
            if args.lines == str(DEFAULT_LINES_TO_PROCESS) and isinstance(DEFAULT_LINES_TO_PROCESS, int):
                effective_lines_to_process = DEFAULT_LINES_TO_PROCESS
                head_param_for_filename = f"_m{DEFAULT_LINES_TO_PROCESS}"
            else:
                print(f"警告: -N 的值 '{args.lines}' 不是一个有效的正整数或 'all'。将对每个文件处理所有行。", file=sys.stderr)
                process_all_lines_flag = True
                head_param_for_filename = ""

    if not process_all_lines_flag and effective_lines_to_process is None:
        if args.lines == str(DEFAULT_LINES_TO_PROCESS):
            effective_lines_to_process = DEFAULT_LINES_TO_PROCESS
            head_param_for_filename = f"_m{DEFAULT_LINES_TO_PROCESS}"

    num_parallel_jobs = args.jobs
    if num_parallel_jobs is None:
        num_parallel_jobs = get_cpu_count()
    elif num_parallel_jobs <= 0:
        print(f"警告: -j 的值 '{args.jobs}' 不是有效的正整数。将使用默认值 {get_cpu_count()}。", file=sys.stderr)
        num_parallel_jobs = get_cpu_count()
    print(f"信息: 将使用 {num_parallel_jobs} 个并行任务处理文件。", file=sys.stderr)

    raw_patterns_list = [p.strip().upper() for p in patterns_string.split(',') if p.strip()] # Convert patterns to upper for case-insensitive match
    if not raw_patterns_list:
        print("错误: 未提供有效的搜索序列。请检查 -p 参数。", file=sys.stderr)
        sys.exit(1)

    forward_patterns = raw_patterns_list
    rc_patterns = [get_reverse_complement(p) for p in raw_patterns_list] # RC will also be upper

    final_tsv_output_path_str = args.output_file
    if final_tsv_output_path_str is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        seq_summary_for_fn = "_".join(raw_patterns_list)
        seq_summary_for_fn = "".join(c if c.isalnum() or c == '_' else '' for c in seq_summary_for_fn)
        max_seq_part_len = 40
        if len(seq_summary_for_fn) > max_seq_part_len:
            seq_summary_for_fn = seq_summary_for_fn[:max_seq_part_len] + "_etc"
        if not seq_summary_for_fn: seq_summary_for_fn = "patterns"
        actual_head_param_fn = head_param_for_filename
        dynamic_filename = f"{timestamp}_{seq_summary_for_fn}{actual_head_param_fn}.tsv"
        final_tsv_output_path = Path(DEFAULT_OUTPUT_DIR_COUNTS) / dynamic_filename
    else:
        final_tsv_output_path = Path(final_tsv_output_path_str)
        if final_tsv_output_path.parent == Path("."):
            final_tsv_output_path = Path(DEFAULT_OUTPUT_DIR_COUNTS) / final_tsv_output_path_str

    tsv_output_directory = final_tsv_output_path.parent
    try:
        tsv_output_directory.mkdir(parents=True, exist_ok=True)
    except Exception as e:
        print(f"错误: 无法创建TSV输出目录 '{tsv_output_directory}': {e}", file=sys.stderr)
        sys.exit(1)

    # --- FASTQ Output Directory Setup ---
    actual_out_fastq_dir_path_for_worker = DEFAULT_OUTPUT_DIR_FASTQ # Base for matched
    unmap_dir_path_for_worker = "" # Path for unmatched
    
    # Make write_matching_reads_flag for worker reflect actual possibility of writing
    write_matching_reads_enabled_for_worker = args.write_matching_reads
    write_unmatched_reads_enabled_for_worker = False # Default to false

    if args.write_matching_reads:
        if args.fastq_output_dir:
            fastq_base_dir_to_create = Path(args.fastq_output_dir)
        else:
            fastq_base_dir_to_create = Path(DEFAULT_OUTPUT_DIR_FASTQ)
        
        actual_out_fastq_dir_path_for_worker = str(fastq_base_dir_to_create)

        try:
            fastq_base_dir_to_create.mkdir(parents=True, exist_ok=True)
            print(f"信息: 匹配的FASTQ记录将被写入到 '{fastq_base_dir_to_create}' 目录。", file=sys.stderr)

            # Now handle unmatched reads directory if that flag is also set
            if args.write_unmatched_reads:
                unmap_specific_dir = fastq_base_dir_to_create / DEFAULT_UNMATCHED_SUBDIR
                unmap_dir_path_for_worker = str(unmap_specific_dir)
                try:
                    unmap_specific_dir.mkdir(parents=True, exist_ok=True)
                    print(f"信息: 未匹配的FASTQ记录将被写入到 '{unmap_specific_dir}' 目录。", file=sys.stderr)
                    write_unmatched_reads_enabled_for_worker = True # Enable for worker
                except Exception as e_unmap:
                    print(f"错误: 无法创建未匹配FASTQ输出子目录 '{unmap_specific_dir}': {e_unmap}", file=sys.stderr)
                    print("警告: 由于无法创建子目录，将不写入未匹配的FASTQ记录。", file=sys.stderr)
                    # write_unmatched_reads_enabled_for_worker remains False
        except Exception as e_fastq:
            print(f"错误: 无法创建主要的FASTQ输出目录 '{fastq_base_dir_to_create}': {e_fastq}", file=sys.stderr)
            print("警告: 由于无法创建主要的FASTQ目录，将不写入任何FASTQ记录 (匹配或未匹配)。", file=sys.stderr)
            write_matching_reads_enabled_for_worker = False # Disable for worker
            write_unmatched_reads_enabled_for_worker = False # Also disable this
    elif args.write_unmatched_reads: # --write-unmatched-reads is on, but --write-matching-reads is off
        print(f"警告: --write-unmatched-reads 选项仅在 --write-matching-reads 也启用时生效。", file=sys.stderr)
        print("警告: 将不写入未匹配的FASTQ记录。", file=sys.stderr)
        # write_unmatched_reads_enabled_for_worker remains False

    input_files = glob.glob(args.input_pattern)
    if not input_files:
        print(f"警告: 未找到匹配模式 '{args.input_pattern}' 的文件。", file=sys.stderr)

    results_list = []
    worker_args_list = []
    for gz_file in input_files:
        if not os.path.isfile(gz_file):
            print(f"警告: '{gz_file}' 不是一个有效的文件，已跳过。", file=sys.stderr)
            continue
        worker_args_list.append(
            (gz_file, patterns_string, forward_patterns, rc_patterns,
             effective_lines_to_process, process_all_lines_flag, sequence_description,
             write_matching_reads_enabled_for_worker, # Use the flag that reflects actual possibility
             actual_out_fastq_dir_path_for_worker,
             write_unmatched_reads_enabled_for_worker, # Use the flag that reflects actual possibility
             unmap_dir_path_for_worker)
        )

    if worker_args_list:
        with concurrent.futures.ProcessPoolExecutor(max_workers=num_parallel_jobs) as executor:
            future_to_file = {executor.submit(process_file_worker, arg_tuple): arg_tuple[0] for arg_tuple in worker_args_list}
            for future in concurrent.futures.as_completed(future_to_file):
                file_path = future_to_file[future]
                try:
                    result = future.result()
                    if result:
                        results_list.append(result)
                except Exception as exc:
                    print(f"警告: 文件 '{file_path}' 在处理时产生错误: {exc}", file=sys.stderr)

    if results_list:
        results_list.sort(key=lambda x: x[0]) # Sort by sample_name

    header = (
        "样本\t序列描述\t查询序列组合\t全正向匹配Reads数\t" # Changed wording
        "全反向互补匹配Reads数\t总处理Reads数\t全正向匹配比例(%)\t全反向互补匹配比例(%)" # Changed wording
    )

    output_lines = [header]
    for res_tuple in results_list:
        output_lines.append("\t".join(map(str, res_tuple)))

    try:
        with open(final_tsv_output_path, 'w', encoding='utf-8') as f_out:
            for line in output_lines:
                print(line)
                f_out.write(line + "\n")
        print(f"\n信息: TSV结果已写入文件: {final_tsv_output_path}", file=sys.stderr)
    except Exception as e:
        print(f"错误: 无法写入TSV输出文件 '{final_tsv_output_path}': {e}", file=sys.stderr)
        if not output_lines or len(output_lines) == 1:
            print("信息: 没有TSV数据行被处理或写入。", file=sys.stderr)

if __name__ == "__main__":
    main()
