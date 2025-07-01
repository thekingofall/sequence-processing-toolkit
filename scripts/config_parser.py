#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
通用并行处理配置解析器
用于将YAML配置文件转换为bash脚本可用的格式
"""

import sys
import yaml
import os
import argparse
from pathlib import Path


def load_config(config_file):
    """加载YAML配置文件"""
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"错误: 配置文件不存在: {config_file}", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"错误: 配置文件格式错误: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"错误: 无法读取配置文件: {e}", file=sys.stderr)
        sys.exit(1)


def expand_path(path, base_dir=None):
    """扩展路径，支持环境变量和用户主目录"""
    if not path:
        return path
    
    # 扩展环境变量
    path = os.path.expandvars(path)
    # 扩展用户主目录 (~)
    path = os.path.expanduser(path)
    
    # 如果是绝对路径，直接返回
    if os.path.isabs(path):
        return path
    
    # 如果有base_dir且不是绝对路径，则相对于base_dir
    if base_dir:
        return os.path.join(base_dir, path)
    
    return path


def output_global_config(config, script_dir):
    """输出全局配置为bash变量"""
    global_settings = config.get('global_settings', {})
    
    # 处理script_dir
    script_dir_val = global_settings.get('script_dir', script_dir)
    if script_dir_val == 'auto' or not script_dir_val:
        script_dir_val = script_dir  # 使用配置文件所在目录
    else:
        script_dir_val = expand_path(script_dir_val)
    
    # 处理其他路径
    pipeline_script = global_settings.get('pipeline_script', 'src/S1S2HiC_Pipeline.py')
    pipeline_script = expand_path(pipeline_script, script_dir_val)
    
    config_dir = global_settings.get('config_dir', 'configs')
    config_dir = expand_path(config_dir, script_dir_val)
    
    log_dir = global_settings.get('log_dir', 'parallel_logs')
    log_dir = expand_path(log_dir, script_dir_val)
    
    # 输出bash变量
    print(f'SCRIPT_DIR="{script_dir_val}"')
    print(f'PIPELINE_SCRIPT="{pipeline_script}"')
    print(f'CONFIG_DIR="{config_dir}"')
    print(f'LOG_DIR="{log_dir}"')
    print(f'PYTHON_CMD="{global_settings.get("python_cmd", "python3")}"')
    print(f'PIPELINE_ARGS="{global_settings.get("pipeline_args", "")}"')
    print(f'STARTUP_DELAY={global_settings.get("startup_delay", 2)}')


def output_groups_config(config):
    """输出组配置"""
    processing_groups = config.get('processing_groups', {})
    
    for group_id, group_config in processing_groups.items():
        enabled = group_config.get('enabled', True)
        if not enabled:
            continue
            
        print(f"GROUP_START:{group_id}")
        print(f"description:{group_config.get('description', '')}")
        print(f"config_file:{group_config.get('config_file', '')}")
        print(f"work_dir:{group_config.get('work_dir', '')}")
        print(f"enabled:{enabled}")
        
        # 输出清理模式
        cleanup_patterns = group_config.get('cleanup_patterns', [])
        if cleanup_patterns:
            print("cleanup_patterns:")
            for pattern in cleanup_patterns:
                print(f"  - {pattern}")
        
        print("GROUP_END")


def list_groups(config):
    """列出所有组"""
    processing_groups = config.get('processing_groups', {})
    
    if not processing_groups:
        print("未找到任何处理组")
        return
    
    for group_id, group_config in processing_groups.items():
        enabled = group_config.get('enabled', True)
        status = "✅ 启用" if enabled else "❌ 禁用"
        description = group_config.get('description', '无描述')
        config_file = group_config.get('config_file', '无配置文件')
        work_dir = group_config.get('work_dir', '无工作目录')
        
        print(f"组ID: {group_id}")
        print(f"  状态: {status}")
        print(f"  描述: {description}")
        print(f"  配置: {config_file}")
        print(f"  目录: {work_dir}")
        print("------------------------------------------------------------")


def validate_config(config):
    """验证配置文件格式"""
    errors = []
    
    # 检查必需的顶级字段
    if 'global_settings' not in config:
        errors.append("缺少 'global_settings' 字段")
    
    if 'processing_groups' not in config:
        errors.append("缺少 'processing_groups' 字段")
    
    # 检查全局设置
    global_settings = config.get('global_settings', {})
    
    # 检查处理组
    processing_groups = config.get('processing_groups', {})
    if not processing_groups:
        errors.append("未定义任何处理组")
    
    for group_id, group_config in processing_groups.items():
        if not isinstance(group_config, dict):
            errors.append(f"组 '{group_id}' 配置必须是字典格式")
            continue
        
        # 检查必需字段
        required_fields = ['config_file', 'work_dir']
        for field in required_fields:
            if field not in group_config:
                errors.append(f"组 '{group_id}' 缺少必需字段: {field}")
        
        # 检查启用状态
        enabled = group_config.get('enabled', True)
        if not isinstance(enabled, bool):
            errors.append(f"组 '{group_id}' 的 'enabled' 字段必须是布尔值")
    
    return errors


def main():
    parser = argparse.ArgumentParser(description='并行处理配置解析器')
    parser.add_argument('config_file', help='配置文件路径')
    parser.add_argument('--global', action='store_true', dest='global_config',
                       help='输出全局配置')
    parser.add_argument('--groups', action='store_true',
                       help='输出组配置')
    parser.add_argument('--list', action='store_true',
                       help='列出所有组')
    parser.add_argument('--validate', action='store_true',
                       help='验证配置文件')
    
    args = parser.parse_args()
    
    # 获取脚本目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 加载配置
    config = load_config(args.config_file)
    
    # 验证配置
    if args.validate:
        errors = validate_config(config)
        if errors:
            print("配置文件验证失败:", file=sys.stderr)
            for error in errors:
                print(f"  - {error}", file=sys.stderr)
            sys.exit(1)
        else:
            print("配置文件验证通过")
            sys.exit(0)
    
    # 输出配置
    if args.global_config:
        output_global_config(config, script_dir)
    elif args.groups:
        output_groups_config(config)
    elif args.list:
        list_groups(config)
    else:
        print("请指定输出模式: --global, --groups, --list 或 --validate", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main() 