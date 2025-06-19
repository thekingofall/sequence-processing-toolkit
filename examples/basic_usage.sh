#!/bin/bash

# Sequence Processing Toolkit - Basic Usage Examples
# This script demonstrates common usage patterns for the toolkit

set -e  # Exit on any error

echo "=== Sequence Processing Toolkit Examples ==="
echo

# Set up paths
TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${TOOLKIT_DIR}/src"

echo "Toolkit directory: $TOOLKIT_DIR"
echo "Source directory: $SRC_DIR"
echo

# Example 1: Basic pattern analysis
echo "=== Example 1: Basic Pattern Analysis ==="
echo "Analyzing sequence patterns with S1_Process_gen.py"

if [[ -f "${SRC_DIR}/S1_Process_gen.py" ]]; then
    echo "Command: python ${SRC_DIR}/S1_Process_gen.py -p \"ATCGATCG,GCTAGCTA\" -d \"Basic Example\""
    echo "Note: This will look for *.gz files in current directory"
    echo "To run: python ${SRC_DIR}/S1_Process_gen.py -p \"ATCGATCG,GCTAGCTA\" -d \"Basic Example\""
else
    echo "Error: S1_Process_gen.py not found in ${SRC_DIR}"
fi
echo

# Example 2: FASTQ file splitting
echo "=== Example 2: FASTQ File Splitting ==="
echo "Splitting FASTQ files with S2_Split.py"

if [[ -f "${SRC_DIR}/S2_Split.py" ]]; then
    echo "Command: python ${SRC_DIR}/S2_Split.py -i input.fastq.gz -o output_directory"
    echo "Note: Replace 'input.fastq.gz' with your actual input file"
    echo "To run: python ${SRC_DIR}/S2_Split.py -i your_file.fastq.gz -o split_output"
else
    echo "Error: S2_Split.py not found in ${SRC_DIR}"
fi
echo

# Example 3: Batch processing
echo "=== Example 3: High-Performance Batch Processing ==="
echo "Processing multiple files with S3_process_sequences_count.sh"

if [[ -f "${SRC_DIR}/S3_process_sequences_count.sh" ]]; then
    echo "Command: ${SRC_DIR}/S3_process_sequences_count.sh -p \"SEQUENCE1,SEQUENCE2\" -j 4"
    echo "Note: This will process all *.gz files in current directory using 4 parallel jobs"
    echo "To run: ${SRC_DIR}/S3_process_sequences_count.sh -p \"YOUR_SEQUENCES\" -j \$(nproc)"
else
    echo "Error: S3_process_sequences_count.sh not found in ${SRC_DIR}"
fi
echo

# Example 4: Complete workflow
echo "=== Example 4: Complete Processing Workflow ==="
cat << 'EOF'
# Step 1: Split merged reads into R1/R2 pairs
python src/S2_Split.py \
    -i merged_data.fastq.gz \
    -o split_results \
    --min-length 20

# Step 2: Analyze R1 files for quality control
python src/S1_Process_gen.py \
    -i "split_results/*_R1.fq.gz" \
    -p "PRIMER1,PRIMER2" \
    -d "R1 Quality Control" \
    --write-matching-reads

# Step 3: Batch process R2 files for target sequences
./src/S3_process_sequences_count.sh \
    -p "TARGET_SEQ1,TARGET_SEQ2" \
    -i "split_results/*_R2.fq.gz" \
    -d "R2 Target Analysis" \
    -j 8

EOF
echo

# Example 5: Performance optimization
echo "=== Example 5: Performance Optimization ==="
cat << 'EOF'
# Check system resources
echo "Available CPU cores: $(nproc)"
echo "Available memory: $(free -h | grep '^Mem:' | awk '{print $2}')"

# Optimize for large datasets
export TMPDIR="/fast_storage/tmp"  # Use SSD for temporary files

# Process with optimal settings
./src/S3_process_sequences_count.sh \
    -p "ATCGATCG,GCTAGCTA" \
    -d "Optimized Processing" \
    -N 200000 \
    -j $(($(nproc) * 8 / 10))  # Use 80% of available cores

EOF
echo

# Help information
echo "=== Getting Help ==="
echo "For detailed help on any tool:"
echo "  python src/S1_Process_gen.py -h"
echo "  python src/S2_Split.py -h"
echo "  ./src/S3_process_sequences_count.sh -h"
echo
echo "For comprehensive documentation, see docs/ directory:"
echo "  docs/README.md - S1 tool detailed guide"
echo "  docs/README_S2_Split.md - S2 tool documentation"
echo "  docs/README_process_sequences.md - S3 tool documentation"
echo "  docs/README_Suite.md - Complete toolkit guide"
echo

echo "=== End of Examples ===" 