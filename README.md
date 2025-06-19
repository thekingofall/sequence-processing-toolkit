# Sequence Processing Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Bash](https://img.shields.io/badge/bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)

A comprehensive toolkit for high-throughput sequencing data processing, featuring sequence pattern analysis, FASTQ file manipulation, and batch processing capabilities.

## 🚀 Features

- **🔍 Sequence Pattern Analysis**: Search and quantify specific sequence motifs with forward and reverse complement matching
- **✂️ Intelligent FASTQ Splitting**: Split FASTQ files into paired R1/R2 reads based on separator sequences
- **⚡ High-Performance Batch Processing**: Process multiple compressed files in parallel with optimized performance
- **📊 Comprehensive Statistics**: Generate detailed reports with matching percentages and quality metrics
- **🧬 Reverse Complement Support**: Automatic reverse complement calculation and matching
- **📁 Batch Operations**: Process hundreds of files simultaneously with multi-core support

## 📋 Quick Start

### Prerequisites

```bash
# Python 3.6+ required
python --version

# Standard Unix tools (usually pre-installed)
which gzip grep awk wc head sort tee
```

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd sequence-processing-toolkit

# Make scripts executable
chmod +x src/*.py src/*.sh
```

### Basic Usage

```bash
# 1. Sequence pattern analysis
python src/S1_Process_gen.py -p "ATCGATCG,GCTAGCTA" -d "Pattern Analysis"

# 2. FASTQ file splitting
python src/S2_Split.py -i input.fastq.gz -o output_dir

# 3. Batch processing
./src/S3_process_sequences_count.sh -p "SEQUENCE1,SEQUENCE2" -j 8
```

## 🛠️ Tools Overview

| Tool | Purpose | Best For |
|------|---------|----------|
| **S1_Process_gen.py** | Sequence pattern search & statistics | Quality control, motif analysis |
| **S2_Split.py** | FASTQ file splitting & pairing | Data preprocessing, barcode separation |
| **S3_process_sequences_count.sh** | High-performance batch processing | Large-scale analysis, production pipelines |

## 📁 Project Structure

```
sequence-processing-toolkit/
├── README.md                 # Main project documentation
├── src/                      # Source code
│   ├── S1_Process_gen.py     # Pattern analysis tool
│   ├── S2_Split.py           # FASTQ splitting tool
│   └── S3_process_sequences_count.sh  # Batch processing tool
├── docs/                     # Detailed documentation
│   ├── README_Suite.md       # Comprehensive toolkit guide
│   ├── README_S2_Split.md    # S2 tool documentation
│   └── README_process_sequences.md  # S3 tool documentation
└── examples/                 # Usage examples and sample data
```

## 🔧 Common Workflows

### Workflow 1: Data Quality Assessment
```bash
# Analyze sequence quality with pattern matching
python src/S1_Process_gen.py \
    -p "PRIMER1,PRIMER2" \
    -d "Quality Assessment" \
    -N all \
    --write-matching-reads
```

### Workflow 2: Data Preprocessing Pipeline
```bash
# Step 1: Split merged reads
python src/S2_Split.py \
    -i merged_reads.fastq.gz \
    -o split_data \
    --min-length 20

# Step 2: Quality analysis
python src/S1_Process_gen.py \
    -i "split_data/*_R1.fq.gz" \
    -p "QUALITY_MOTIF1,QUALITY_MOTIF2" \
    -d "Post-split QC"
```

### Workflow 3: Large-Scale Batch Processing
```bash
# High-performance processing of multiple files
./src/S3_process_sequences_count.sh \
    -p "TARGET_SEQ1,TARGET_SEQ2" \
    -i "data/*.gz" \
    -d "Batch Analysis" \
    -N 200000 \
    -j 16
```

## 📖 Documentation

### Quick References
- [🔍 **S1_Process_gen.py**](docs/README.md) - Detailed usage guide for pattern analysis
- [✂️ **S2_Split.py**](docs/README_S2_Split.md) - Complete splitting tool documentation
- [⚡ **S3_process_sequences_count.sh**](docs/README_process_sequences.md) - Batch processing advanced guide
- [📚 **Complete Toolkit Guide**](docs/README_Suite.md) - Comprehensive usage scenarios

### Getting Help
```bash
# Get help for any tool
python src/S1_Process_gen.py -h
python src/S2_Split.py -h
./src/S3_process_sequences_count.sh -h
```

## 🚀 Performance Optimization

### Hardware Recommendations
- **CPU**: Multi-core processor (8+ cores recommended)
- **Memory**: 8GB+ RAM (16GB+ for large datasets)
- **Storage**: SSD preferred for input/output operations

### Performance Tips
```bash
# 1. Optimize parallel processing
nproc  # Check available cores
./src/S3_process_sequences_count.sh -p "SEQ" -j $(nproc)

# 2. Use SSD storage for temporary files
export TMPDIR=/fast_storage/tmp

# 3. Process in chunks for memory efficiency
python src/S1_Process_gen.py -p "SEQ" -N 100000  # Limit lines processed
```

## 📊 Example Results

### Pattern Analysis Output
```
Sample          Description    Patterns              Forward_Matches  RC_Matches   Total_Reads  Forward_%  RC_%
sample1.fastq   Test Analysis  ATCGATCG,GCTAGCTA    1250            890          25000        5.00%      3.56%
sample2.fastq   Test Analysis  ATCGATCG,GCTAGCTA    1100            950          25000        4.40%      3.80%
```

### Splitting Statistics
```
=== Processing Complete ===
Total reads: 100,000
Successfully paired: 85,000
Discarded reads: 15,000
Pairing success rate: 85.00%

=== Orientation Statistics ===
Forward matches: 45,000
Reverse matches: 25,000
Mixed matches: 15,000
```

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for details.

### Development Setup
```bash
# Development environment setup
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Run tests
python -m pytest tests/  # If test suite available
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Version History

- **v1.0.0** (2025-05-28): Initial release
  - Complete toolkit with three main tools
  - Comprehensive documentation
  - Performance optimizations
  - Multi-platform support

## 🙋 Support

- **📚 Documentation**: Check the `docs/` directory for detailed guides
- **🐛 Issues**: Report bugs with detailed error messages and data characteristics
- **💡 Feature Requests**: Suggest improvements and new features
- **📧 Contact**: Reach out to the development team for support

## 🎯 Use Cases

- **🧬 Genomics Research**: Quality control and sequence analysis
- **🔬 Molecular Biology**: Primer/probe validation and design
- **📈 Bioinformatics**: High-throughput data processing pipelines
- **🏭 Production Environments**: Automated sequence processing workflows
- **🎓 Educational**: Teaching sequence analysis concepts

---

⭐ **Star this repository** if you find it useful!

**Citation**: If you use this toolkit in your research, please cite: [Citation details to be added] 