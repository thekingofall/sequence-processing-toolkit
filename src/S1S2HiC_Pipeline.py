#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import sys
import glob
import subprocess
from pathlib import Path
from datetime import datetime
import shutil
import yaml

# --- Default Values ---
DEFAULT_INPUT_PATTERN = "*gz"
DEFAULT_S1_OUTPUT_DIR = "S1_Matched"
DEFAULT_S2_OUTPUT_DIR = "S2_Split"
DEFAULT_HIC_INPUT_DIR = "HiC_Input"
DEFAULT_SEQUENCE_DESCRIPTION = "S1S2HiC完整流程"
DEFAULT_LINES_TO_PROCESS = 100000

def load_config(config_file):
    """
    加载YAML配置文件
    """
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
        print(f"成功加载配置文件: {config_file}")
        return config
    except FileNotFoundError:
        print(f"错误: 配置文件不存在: {config_file}", file=sys.stderr)
        return None
    except yaml.YAMLError as e:
        print(f"错误: 配置文件格式错误: {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"错误: 读取配置文件失败: {e}", file=sys.stderr)
        return None

def merge_config_with_args(config, args):
    """
    将命令行参数与配置文件合并，命令行参数优先级更高
    """
    if not config:
        return None
    
    # S1配置
    s1_config = config.get('S1_config', {})
    if hasattr(args, 'patterns') and args.patterns:
        s1_config['patterns'] = args.patterns
    if hasattr(args, 'description') and args.description != DEFAULT_SEQUENCE_DESCRIPTION:
        s1_config['description'] = args.description
    if hasattr(args, 'input_pattern') and args.input_pattern != DEFAULT_INPUT_PATTERN:
        s1_config['input_pattern'] = args.input_pattern
    if hasattr(args, 'lines') and args.lines != str(DEFAULT_LINES_TO_PROCESS):
        s1_config['lines_to_process'] = args.lines
    if hasattr(args, 'jobs') and args.jobs:
        s1_config['jobs'] = args.jobs
    if hasattr(args, 's1_output_dir') and args.s1_output_dir != DEFAULT_S1_OUTPUT_DIR:
        s1_config['output_dir'] = args.s1_output_dir
    
    # S2配置
    s2_config = config.get('S2_config', {})
    if hasattr(args, 'sep1') and args.sep1:
        s2_config['separator1'] = args.sep1
    if hasattr(args, 'sep2') and args.sep2:
        s2_config['separator2'] = args.sep2
    if hasattr(args, 'min_length') and args.min_length != 10:
        s2_config['min_length'] = args.min_length
    if hasattr(args, 's2_output_dir') and args.s2_output_dir != DEFAULT_S2_OUTPUT_DIR:
        s2_config['output_dir'] = args.s2_output_dir
    
    # HiC配置
    hic_config = config.get('HiC_config', {})
    if hasattr(args, 'hic_input_dir') and args.hic_input_dir != DEFAULT_HIC_INPUT_DIR:
        hic_config['input_dir'] = args.hic_input_dir
    if hasattr(args, 'project_name') and args.project_name:
        hic_config['project_name'] = args.project_name
    if hasattr(args, 'hic_config') and args.hic_config != 1:
        hic_config['config_type'] = args.hic_config
    if hasattr(args, 'hic_modules') and args.hic_modules != "1,2,3":
        hic_config['modules'] = args.hic_modules
    if hasattr(args, 'hic_cpu') and args.hic_cpu != 10:
        hic_config['cpu_count'] = args.hic_cpu
    if hasattr(args, 'hic_conda_env') and args.hic_conda_env != "hicpro3":
        hic_config['conda_env'] = args.hic_conda_env
    
    # 流程控制
    workflow_control = config.get('workflow_control', {})
    if hasattr(args, 'skip_s1') and args.skip_s1:
        workflow_control['skip_s1'] = args.skip_s1
    if hasattr(args, 'skip_s2') and args.skip_s2:
        workflow_control['skip_s2'] = args.skip_s2
    if hasattr(args, 'skip_hic') and args.skip_hic:
        workflow_control['skip_hic'] = args.skip_hic
    
    return {
        'S1_config': s1_config,
        'S2_config': s2_config,
        'HiC_config': hic_config,
        'workflow_control': workflow_control,
        'advanced_config': config.get('advanced_config', {})
    }

def validate_config(config):
    """
    验证配置文件的完整性
    """
    required_sections = ['S1_config', 'S2_config', 'HiC_config']
    
    for section in required_sections:
        if section not in config:
            print(f"错误: 配置文件缺少必需的部分: {section}", file=sys.stderr)
            return False
    
    # 验证S1配置
    s1_config = config['S1_config']
    if 'patterns' not in s1_config or not s1_config['patterns']:
        print("错误: S1_config缺少patterns配置", file=sys.stderr)
        return False
    
    # 验证必需的输出目录
    if 'output_dir' not in s1_config:
        s1_config['output_dir'] = DEFAULT_S1_OUTPUT_DIR
    if 'output_dir' not in config['S2_config']:
        config['S2_config']['output_dir'] = DEFAULT_S2_OUTPUT_DIR
    if 'input_dir' not in config['HiC_config']:
        config['HiC_config']['input_dir'] = DEFAULT_HIC_INPUT_DIR
    
    return True

def run_s1_process(s1_config):
    """
    运行S1处理步骤
    """
    print(f"\n=== 第一步: 运行S1序列匹配处理 ===")
    
    s1_script = Path(__file__).parent / "S1_Process_gen.py"
    if not s1_script.exists():
        print(f"错误: 找不到S1脚本: {s1_script}", file=sys.stderr)
        return False
    
    # 检查输入目录
    input_dir = s1_config.get('input_dir')
    if input_dir and not Path(input_dir).exists():
        print(f"错误: S1输入目录不存在: {input_dir}", file=sys.stderr)
        return False
    
    # 如果有输入目录，切换到该目录运行
    current_dir = os.getcwd()
    if input_dir:
        print(f"切换到S1输入目录: {input_dir}")
        os.chdir(input_dir)
    
    # 构建S1命令
    s1_cmd = [
        sys.executable, str(s1_script),
        "-p", s1_config['patterns'],
        "-d", s1_config.get('description', DEFAULT_SEQUENCE_DESCRIPTION),
        "-i", s1_config.get('input_pattern', DEFAULT_INPUT_PATTERN),
        "-N", str(s1_config.get('lines_to_process', DEFAULT_LINES_TO_PROCESS)),
        "--write-matching-reads"
    ]
    
    # 设置输出目录(相对于当前工作目录或绝对路径)
    output_dir = s1_config['output_dir']
    if not Path(output_dir).is_absolute():
        output_dir = Path(current_dir) / output_dir
    s1_cmd.extend(["--fastq-output-dir", str(output_dir)])
    
    if s1_config.get('jobs'):
        s1_cmd.extend(["-j", str(s1_config['jobs'])])
    
    print(f"执行命令: {' '.join(s1_cmd)}")
    
    try:
        result = subprocess.run(s1_cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        print("S1处理成功完成!")
        print("S1输出:")
        print(result.stdout)
        if result.stderr:
            print("S1警告/信息:")
            print(result.stderr)
        
        # 返回原目录
        os.chdir(current_dir)
        return True
    except subprocess.CalledProcessError as e:
        print(f"S1处理失败: {e}", file=sys.stderr)
        print(f"错误输出: {e.stderr}", file=sys.stderr)
        # 返回原目录
        os.chdir(current_dir)
        return False

def run_s2_split(s1_config, s2_config):
    """
    运行S2分割步骤
    """
    print(f"\n=== 第二步: 运行S2序列分割处理 ===")
    
    s2_script = Path(__file__).parent / "S2_Split.py"
    if not s2_script.exists():
        print(f"错误: 找不到S2脚本: {s2_script}", file=sys.stderr)
        return False
    
    # 获取S2输入目录
    s2_input_dir = s2_config.get('input_dir', s1_config['output_dir'])
    if not Path(s2_input_dir).exists():
        print(f"错误: S2输入目录不存在: {s2_input_dir}", file=sys.stderr)
        return False
    
    # 查找S2输入的文件
    s1_files = glob.glob(os.path.join(s2_input_dir, "*.gz"))
    if not s1_files:
        print(f"错误: 在 {s2_input_dir} 中未找到任何.gz文件", file=sys.stderr)
        return False
    
    print(f"S2输入目录: {s2_input_dir}")
    print(f"找到 {len(s1_files)} 个S2输入文件")
    
    success_count = 0
    failed_files = []
    
    for s1_file in s1_files:
        file_name = Path(s1_file).name
        print(f"\n处理文件: {file_name}")
        
        # 为每个文件创建独立的输出目录
        file_base_name = file_name.replace('.gz', '').replace('.fq', '').replace('.fastq', '')
        file_output_dir = Path(s2_config['output_dir']) / file_base_name
        
        # 构建S2命令
        s2_cmd = [
            sys.executable, str(s2_script),
            "-i", s1_file,
            "-o", str(file_output_dir),
            "--sep1", s2_config.get('separator1', "GATCATGTCGGAACTGTTGCTTGTCCGACTGATC"),
            "--sep2", s2_config.get('separator2', "AGATCGGAAGA"),
            "--min-length", str(s2_config.get('min_length', 5))
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

def prepare_hic_input(s2_config, hic_config):
    """
    将S2输出整理为HiC-Pro输入格式
    """
    print(f"\n=== 第三步: 准备HiC-Pro输入目录 ===")
    
    s2_output_dir = Path(s2_config['output_dir'])
    hic_input_dir = Path(hic_config['input_dir'])
    
    if not s2_output_dir.exists():
        print(f"错误: S2输出目录不存在: {s2_output_dir}", file=sys.stderr)
        return False
    
    # 创建HiC输入目录
    hic_input_dir.mkdir(exist_ok=True)
    
    print(f"S2数据源目录: {s2_output_dir}")
    
    # 找到所有S2输出目录
    s2_sample_dirs = [d for d in s2_output_dir.iterdir() if d.is_dir()]
    print(f"找到 {len(s2_sample_dirs)} 个S2输出目录")
    
    success_count = 0
    for s2_sample_dir in s2_sample_dirs:
        sample_name = s2_sample_dir.name
        print(f"\n处理样本: {sample_name}")
        
        # 创建HiC输入样本目录
        hic_sample_dir = hic_input_dir / sample_name
        hic_sample_dir.mkdir(exist_ok=True)
        
        # 查找R1和R2文件
        r1_files = list(s2_sample_dir.glob("*_R1.fq.gz"))
        r2_files = list(s2_sample_dir.glob("*_R2.fq.gz"))
        
        if not r1_files or not r2_files:
            print(f"  错误: 在{s2_sample_dir}中未找到R1或R2文件")
            continue
        
        # 复制文件到HiC输入目录
        for r1_file in r1_files:
            dest_r1 = hic_sample_dir / r1_file.name
            shutil.copy2(r1_file, dest_r1)
            print(f"  已复制: {r1_file.name} -> {sample_name}/{r1_file.name}")
        
        for r2_file in r2_files:
            dest_r2 = hic_sample_dir / r2_file.name
            shutil.copy2(r2_file, dest_r2)
            print(f"  已复制: {r2_file.name} -> {sample_name}/{r2_file.name}")
        
        success_count += 1
    
    print(f"\n=== HiC输入准备完成 ===")
    print(f"成功处理 {success_count} 个样本")
    print(f"HiC输入目录: {hic_input_dir}")
    
    return success_count > 0

def prepare_hic_rawdata(hic_config):
    """
    直接将HiC输入数据放入Run2_trim目录，跳过trim步骤
    """
    print(f"\n=== 准备HiC-Pro Run2_trim目录（跳过trim步骤） ===")
    
    hic_input_dir = Path(hic_config['input_dir'])
    if not hic_input_dir.exists():
        print(f"错误: HiC输入目录不存在: {hic_input_dir}", file=sys.stderr)
        return False
    
    # 创建Run2_trim目录（HiC-Pro期望的目录）
    trim_dir = Path("Run2_trim")
    trim_dir.mkdir(exist_ok=True)
    
    # 找到所有样本目录
    sample_dirs = [d for d in hic_input_dir.iterdir() if d.is_dir()]
    print(f"找到 {len(sample_dirs)} 个样本目录")
    
    success_count = 0
    for sample_dir in sample_dirs:
        sample_name = sample_dir.name
        print(f"\n处理样本: {sample_name}")
        
        # 创建样本子目录
        sample_trim_dir = trim_dir / sample_name
        sample_trim_dir.mkdir(exist_ok=True)
        
        # 查找R1和R2文件
        r1_files = list(sample_dir.glob("*_R1.fq.gz"))
        r2_files = list(sample_dir.glob("*_R2.fq.gz"))
        
        if not r1_files or not r2_files:
            print(f"  错误: 在{sample_dir}中未找到R1或R2文件")
            continue
        
        # HiC-Pro期望的文件命名格式：sample_R1.fq.gz 和 sample_R2.fq.gz
        for i, (r1_file, r2_file) in enumerate(zip(r1_files, r2_files)):
            # 使用原始样本名，如果有多个文件则添加索引
            if len(r1_files) > 1:
                hic_r1_name = f"{sample_name}_{i+1}_R1.fq.gz"
                hic_r2_name = f"{sample_name}_{i+1}_R2.fq.gz"
            else:
                hic_r1_name = f"{sample_name}_R1.fq.gz"
                hic_r2_name = f"{sample_name}_R2.fq.gz"
            
            # 复制并重命名文件到样本子目录
            dest_r1 = sample_trim_dir / hic_r1_name
            dest_r2 = sample_trim_dir / hic_r2_name
            
            shutil.copy2(r1_file, dest_r1)
            shutil.copy2(r2_file, dest_r2)
            
            print(f"  已复制: {r1_file.name} -> Run2_trim/{sample_name}/{hic_r1_name}")
            print(f"  已复制: {r2_file.name} -> Run2_trim/{sample_name}/{hic_r2_name}")
        
        success_count += 1
    
    print(f"\n=== HiC Run2_trim准备完成 ===")
    print(f"成功处理 {success_count} 个样本")
    print(f"Run2_trim目录: {trim_dir.absolute()}")
    
    return success_count > 0

def run_hic_pipeline(hic_config):
    """
    运行HiC-Pro流程
    支持两种HiC-Pro脚本：
    1. 新版本（默认）: /home/maolp/mao/Biosoft/scHICprocess/run_hicpro_pipeline.sh
    2. 旧版本: schic_analysis_pipeline.sh
    """
    print(f"\n=== 第四步: 运行HiC-Pro流程 ===")
    
    # 确定使用哪个HiC-Pro脚本（默认使用新版本）
    hic_script_type = hic_config.get('script_type', 'new')  # 'new' 或 'old'
    
    if hic_script_type == 'new':
        # 新版本HiC-Pro脚本（默认）
        hic_script = Path("/home/maolp/mao/Biosoft/scHICprocess/run_hicpro_pipeline.sh")
        print(f"使用新版本HiC-Pro脚本: {hic_script}")
        
        if not hic_script.exists():
            print(f"错误: 找不到新版本HiC-Pro脚本: {hic_script}", file=sys.stderr)
            return False
        
        # 生成项目名称（如果未指定）
        project_name = hic_config.get('project_name')
        if not project_name:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            project_name = f"S1S2HiC_{timestamp}"
        
        # 新脚本的参数格式
        hic_cmd = [
            str(hic_script),
            "-n", str(hic_config.get('config_type', 1)),
            "-p", project_name,
            "-t", "Run2_trim",  # 修剪目录参数
            "-o", "Run3_hic",   # 输出目录参数  
            "-u", str(hic_config.get('cpu_count', 10)),
            "-e", hic_config.get('conda_env', 'hicpro3'),
            "-m", hic_config.get('modules', '2,3')  # 默认跳过trim模块
        ]
        
    else:
        # 旧版本HiC-Pro脚本（兼容性）
        hic_script = Path(__file__).parent.parent / "Scripts" / "schic_analysis_pipeline.sh"
        print(f"使用旧版本HiC-Pro脚本: {hic_script}")
        
        if not hic_script.exists():
            print(f"错误: 找不到旧版本HiC-Pro脚本: {hic_script}", file=sys.stderr)
            return False
        
        # 生成项目名称（如果未指定）
        project_name = hic_config.get('project_name')
        if not project_name:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            project_name = f"S1S2HiC_{timestamp}"
        
        # 旧脚本的参数格式
        hic_cmd = [
            str(hic_script),
            "-n", str(hic_config.get('config_type', 1)),
            "-p", project_name,
            "-i", hic_config['input_dir'],
            "-u", str(hic_config.get('cpu_count', 10)),
            "-e", hic_config.get('conda_env', 'hicpro3'),
            "-m", hic_config.get('modules', '1,2,3')
        ]
    
    print(f"执行命令: {' '.join(hic_cmd)}")
    
    try:
        # 使用bash运行脚本
        result = subprocess.run(["bash"] + hic_cmd, check=True, universal_newlines=True)
        print("HiC-Pro流程成功完成!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"HiC-Pro流程失败: {e}", file=sys.stderr)
        return False

def run_hicpro_direct(hic_config):
    """
    直接运行HiC-Pro命令，不使用中间脚本
    """
    print(f"\n=== 第四步: 直接运行HiC-Pro流程 ===")
    
    # HiC-Pro路径
    hicpro_bin = "/data1/Ref/hicpro/HiC-Pro-3.1.0/bin/HiC-Pro"
    if not Path(hicpro_bin).exists():
        print(f"错误: 找不到HiC-Pro: {hicpro_bin}", file=sys.stderr)
        return False
    
    # 配置文件路径
    config_file = "/data1/Ref/hicpro/configs/scCARE.txt"
    if not Path(config_file).exists():
        print(f"错误: 找不到HiC-Pro配置文件: {config_file}", file=sys.stderr)
        return False
    
    # 创建输出目录
    output_dir = Path("hicpro_results")
    output_dir.mkdir(exist_ok=True)
    
    # 生成项目名称（如果未指定）
    project_name = hic_config.get('project_name', f"HiC_{datetime.now().strftime('%Y%m%d_%H%M%S')}")
    
    # 构建HiC-Pro命令
    hic_cmd = [
        hicpro_bin,
        "-i", "rawdata",  # 输入目录（rawdata）
        "-o", str(output_dir),  # 输出目录
        "-c", config_file,  # 配置文件
        "-p", str(hic_config.get('cpu_count', 10))  # CPU数量
    ]
    
    # 根据模块设置决定运行步骤
    modules = hic_config.get('modules', '2,3')
    if '1' not in modules:
        # 跳过mapping步骤，从step2开始
        hic_cmd.extend(["-s", "proc_hic"])
    
    print(f"执行HiC-Pro命令: {' '.join(hic_cmd)}")
    print(f"工作目录: {Path.cwd()}")
    print(f"rawdata目录: {Path('rawdata').absolute()}")
    print(f"输出目录: {output_dir.absolute()}")
    
    try:
        # 运行HiC-Pro
        result = subprocess.run(hic_cmd, check=True, universal_newlines=True)
        
        print("HiC-Pro流程成功完成!")
        
        # 检查输出
        print(f"\n=== 检查HiC-Pro输出 ===")
        if output_dir.exists():
            output_files = list(output_dir.rglob("*"))
            print(f"生成了 {len(output_files)} 个输出文件")
            # 显示主要输出目录
            main_dirs = [d for d in output_dir.iterdir() if d.is_dir()]
            for main_dir in main_dirs:
                print(f"  输出目录: {main_dir}")
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"HiC-Pro流程失败: {e}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"运行HiC-Pro时发生错误: {e}", file=sys.stderr)
        return False

def generate_complete_report(config):
    """
    生成完整的流程报告
    """
    print(f"\n=== 生成完整流程报告 ===")
    
    s1_config = config['S1_config']
    s2_config = config['S2_config']
    hic_config = config['HiC_config']
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = Path(f"S1S2HiC_Complete_Report_{timestamp}.txt")
    
    try:
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("S1S2HiC 完整处理流程报告\n")
            f.write("=" * 60 + "\n")
            f.write(f"处理时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"项目名称: {hic_config.get('project_name', 'N/A')}\n")
            f.write(f"查询序列: {s1_config['patterns']}\n")
            f.write(f"序列描述: {s1_config.get('description', 'N/A')}\n\n")
            
            f.write("目录结构:\n")
            f.write(f"S1输出目录: {s1_config['output_dir']}\n")
            f.write(f"S2输出目录: {s2_config['output_dir']}\n")
            f.write(f"HiC输入目录: {hic_config['input_dir']}\n\n")
            
            # 统计S1输出文件
            s1_files = glob.glob(os.path.join(s1_config['output_dir'], "*.gz"))
            f.write(f"S1输出文件数: {len(s1_files)}\n")
            for s1_file in s1_files:
                f.write(f"  - {Path(s1_file).name}\n")
            
            f.write("\n")
            
            # 统计S2输出目录
            s2_dirs = [d for d in Path(s2_config['output_dir']).iterdir() if d.is_dir()]
            f.write(f"S2输出目录数: {len(s2_dirs)}\n")
            for s2_dir in s2_dirs:
                f.write(f"  - {s2_dir.name}/\n")
                s2_files = list(s2_dir.glob("*.gz"))
                for s2_file in s2_files:
                    f.write(f"    * {s2_file.name}\n")
            
            f.write("\n")
            
            # 统计HiC输入目录
            if Path(hic_config['input_dir']).exists():
                hic_dirs = [d for d in Path(hic_config['input_dir']).iterdir() if d.is_dir()]
                f.write(f"HiC输入目录数: {len(hic_dirs)}\n")
                for hic_dir in hic_dirs:
                    f.write(f"  - {hic_dir.name}/\n")
                    hic_files = list(hic_dir.glob("*.gz"))
                    for hic_file in hic_files:
                        f.write(f"    * {hic_file.name}\n")
            
            f.write("\n配置信息:\n")
            f.write(f"S1分隔符1: {s2_config.get('separator1', 'N/A')}\n")
            f.write(f"S1分隔符2: {s2_config.get('separator2', 'N/A')}\n")
            f.write(f"最小长度: {s2_config.get('min_length', 'N/A')}\n")
            f.write(f"HiC配置类型: {hic_config.get('config_type', 'N/A')}\n")
            f.write(f"HiC CPU数: {hic_config.get('cpu_count', 'N/A')}\n")
            
            f.write("\n完整流程说明:\n")
            f.write("1. S1_Process_gen.py: 从原始文件中筛选匹配指定序列模式的reads\n")
            f.write("2. S2_Split.py: 将匹配的reads根据分隔符分割为R1和R2配对文件\n")
            f.write("3. 数据整理: 将R1/R2文件整理为HiC-Pro输入格式\n")
            f.write("4. run_hicpro_pipeline.sh: 执行完整的HiC-Pro分析流程\n")
            
        print(f"完整报告已生成: {report_file}")
        return True
        
    except Exception as e:
        print(f"生成报告失败: {e}", file=sys.stderr)
        return False

def main():
    parser = argparse.ArgumentParser(
        description="S1S2HiC完整处理流程：S1筛选→S2分割→HiC-Pro分析\n支持配置文件模式（推荐）和命令行参数模式",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    # 主要参数
    parser.add_argument(
        "-c", "--config",
        help="(推荐) 配置文件路径（YAML格式）。使用配置文件可以更好地管理复杂参数"
    )
    
    # 兼容性参数（用于覆盖配置文件或非配置文件模式）
    parser.add_argument(
        "-p", "--patterns",
        help="(可选) 逗号分隔的多个原始搜索序列，用于S1筛选。覆盖配置文件中的设置"
    )
    parser.add_argument(
        "-d", "--description",
        default=DEFAULT_SEQUENCE_DESCRIPTION,
        help=f"(可选) 对当前查询的序列组合的描述性名称。覆盖配置文件中的设置"
    )
    parser.add_argument(
        "-i", "--input-pattern",
        default=DEFAULT_INPUT_PATTERN,
        help=f"(可选) 输入 .gz 文件的匹配模式。覆盖配置文件中的设置"
    )
    parser.add_argument(
        "--project-name",
        help="(可选) HiC-Pro项目名称。覆盖配置文件中的设置"
    )
    
    # 流程控制参数
    parser.add_argument(
        "--skip-s1",
        action="store_true",
        help="(可选) 跳过S1步骤，直接使用现有的S1输出目录"
    )
    parser.add_argument(
        "--skip-s2",
        action="store_true",
        help="(可选) 跳过S2步骤，直接使用现有的S2输出目录"
    )
    parser.add_argument(
        "--skip-hic",
        action="store_true",
        help="(可选) 跳过HiC步骤，只运行S1S2流程"
    )
    parser.add_argument(
        "--skip-trim",
        action="store_true",
        help="(可选) 跳过trim步骤，直接将S2输出作为HiC-Pro rawdata"
    )
    
    # 生成配置模板
    parser.add_argument(
        "--generate-config",
        metavar="CONFIG_FILE",
        help="生成配置文件模板并退出"
    )
    
    args = parser.parse_args()
    
    # 生成配置模板
    if args.generate_config:
        try:
            template_path = Path(__file__).parent.parent / "config_template.yaml"
            shutil.copy2(template_path, args.generate_config)
            print(f"配置文件模板已生成: {args.generate_config}")
            print("请编辑配置文件后使用: python S1S2HiC_Pipeline.py -c your_config.yaml")
            return
        except Exception as e:
            print(f"生成配置文件模板失败: {e}", file=sys.stderr)
            sys.exit(1)
    
    # 加载配置
    config = None
    if args.config:
        config = load_config(args.config)
        if not config:
            sys.exit(1)
        
        # 合并命令行参数
        config = merge_config_with_args(config, args)
        
        # 验证配置
        if not validate_config(config):
            sys.exit(1)
    else:
        # 如果没有配置文件，检查必需的命令行参数
        if not args.patterns:
            print("错误: 必须提供配置文件(-c)或指定查询序列(-p)", file=sys.stderr)
            print("使用 --generate-config 生成配置文件模板", file=sys.stderr)
            sys.exit(1)
        
        # 使用命令行参数创建配置
        config = {
            'S1_config': {
                'patterns': args.patterns,
                'description': args.description,
                'input_pattern': args.input_pattern,
                'lines_to_process': DEFAULT_LINES_TO_PROCESS,
                'jobs': None,
                'output_dir': DEFAULT_S1_OUTPUT_DIR
            },
            'S2_config': {
                'separator1': "GATCATGTCGGAACTGTTGCTTGTCCGACTGATC",
                'separator2': "AGATCGGAAGA",
                'min_length': 10,
                'output_dir': DEFAULT_S2_OUTPUT_DIR
            },
            'HiC_config': {
                'input_dir': DEFAULT_HIC_INPUT_DIR,
                'project_name': args.project_name,
                'config_type': 1,
                'modules': "1,2,3",
                'cpu_count': 10,
                'conda_env': "hicpro3"
            },
            'workflow_control': {
                'skip_s1': args.skip_s1,
                'skip_s2': args.skip_s2,
                'skip_hic': args.skip_hic
            },
            'advanced_config': {
                'generate_report': True
            }
        }
    
    # 显示配置摘要
    print("S1S2HiC 完整处理流程开始")
    print("=" * 60)
    if args.config:
        print(f"配置文件: {args.config}")
    print(f"项目名称: {config['HiC_config'].get('project_name', '自动生成')}")
    print(f"查询序列: {config['S1_config']['patterns']}")
    print(f"序列描述: {config['S1_config'].get('description', 'N/A')}")
    print(f"输入模式: {config['S1_config'].get('input_pattern', DEFAULT_INPUT_PATTERN)}")
    print(f"S1输出目录: {config['S1_config']['output_dir']}")
    print(f"S2输出目录: {config['S2_config']['output_dir']}")
    print(f"HiC输入目录: {config['HiC_config']['input_dir']}")
    print(f"HiC配置类型: {config['HiC_config'].get('config_type', 1)}")
    
    success = True
    workflow_control = config.get('workflow_control', {})
    
    # 第一步：运行S1处理（除非跳过）
    if not workflow_control.get('skip_s1', False):
        success = run_s1_process(config['S1_config'])
        
        if not success:
            print("S1处理失败，终止流程", file=sys.stderr)
            sys.exit(1)
    else:
        print("\n=== 跳过S1步骤，使用现有S1输出 ===")
        if not Path(config['S1_config']['output_dir']).exists():
            print(f"错误: S1输出目录不存在: {config['S1_config']['output_dir']}", file=sys.stderr)
            sys.exit(1)
    
    # 第二步：运行S2处理（除非跳过）
    if not workflow_control.get('skip_s2', False):
        success = run_s2_split(config['S1_config'], config['S2_config'])
        
        if not success:
            print("S2处理失败，终止流程", file=sys.stderr)
            sys.exit(1)
    else:
        print("\n=== 跳过S2步骤，使用现有S2输出 ===")
        if not Path(config['S2_config']['output_dir']).exists():
            print(f"错误: S2输出目录不存在: {config['S2_config']['output_dir']}", file=sys.stderr)
            sys.exit(1)
    
    # 第三步：准备HiC输入
    if not workflow_control.get('skip_hic', False):
        # 检查是否跳过trim步骤
        if args.skip_trim:
            # 跳过trim，直接准备rawdata
            success = prepare_hic_input(config['S2_config'], config['HiC_config'])
            if success:
                success = prepare_hic_rawdata(config['HiC_config'])
        else:
            # 正常流程，准备HiC输入用于trim步骤
            success = prepare_hic_input(config['S2_config'], config['HiC_config'])
        
        if not success:
            print("HiC输入准备失败，终止流程", file=sys.stderr)
            sys.exit(1)
        
        # 第四步：运行HiC-Pro流程
        if args.skip_trim:
            # 修改HiC配置，跳过模块1（trim）
            original_modules = config['HiC_config'].get('modules', '1,2,3')
            config['HiC_config']['modules'] = '2,3'  # 跳过模块1
            print(f"跳过trim步骤，运行HiC-Pro模块: {config['HiC_config']['modules']}")
        
        success = run_hic_pipeline(config['HiC_config'])
        
        if not success:
            print("HiC-Pro流程失败", file=sys.stderr)
            sys.exit(1)
    else:
        print("\n=== 跳过HiC步骤，只运行S1S2流程 ===")
    
    # 生成完整报告
    if config.get('advanced_config', {}).get('generate_report', True):
        generate_complete_report(config)
    
    print("\n" + "=" * 60)
    print("S1S2HiC 完整处理流程成功完成!")
    if not workflow_control.get('skip_hic', False):
        print("流程说明:")
        print("1. S1步骤: 筛选包含指定序列模式的reads")
        print("2. S2步骤: 将筛选的reads按分隔符分割为R1/R2配对文件")
        print("3. 数据整理: 将R1/R2文件整理为HiC-Pro输入格式")
        print("4. HiC-Pro: 执行完整的Hi-C数据分析流程")
        print(f"5. 最终HiC结果可在项目目录的Run3_hic和Run4_HICdata*中找到")
    else:
        print(f"S1S2流程完成，HiC输入文件已准备在: {config['HiC_config']['input_dir']}")

if __name__ == "__main__":
    main() 