## S1S2HiC 流程总结

已成功为您配置了完整的S1S2HiC处理流程：

### 配置文件 (5个组)
✅ Group1_MboI_GATC_SeqA_config.yaml (MME-1,12,13 - 6文件)
✅ Group2_MboI_GATC_SeqB_config.yaml (MME-2 - 2文件)  
✅ Group3_MseI_CviQI_TA_SeqA_config.yaml (MME-4,5,6,10,11 - 10文件)
✅ Group4_MseI_CviQI_TA_SeqB_config.yaml (MME-3 - 2文件)
✅ Group5_MboI_CviQI_GATC_TA_SeqA_config.yaml (MME-7 - 2文件)

### 关键改进
✅ 添加了 S1/S2 输入输出目录参数
✅ lines_to_process = 1000000000 (10亿行)
✅ min_length = 5 (降低片段长度阈值)
✅ 完整的目录路径管理

### 使用方法
批量处理: ./run_all_groups_S1S2HiC.sh
单独处理: python3 src/S1S2HiC_Pipeline.py -c configs/GroupX_config.yaml

流程: S1(linker分离) → S2(酶切+分割) → HiC(完整分析)

