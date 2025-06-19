# Documentation Index

Welcome to the Sequence Processing Toolkit documentation!

## 📚 Documentation Structure

### Tool-Specific Documentation

| Tool | Document | Description |
|------|----------|-------------|
| **S1_Process_gen.py** | [README.md](README.md) | Comprehensive guide for sequence pattern analysis |
| **S2_Split.py** | [README_S2_Split.md](README_S2_Split.md) | Complete documentation for FASTQ splitting tool |
| **S3_process_sequences_count.sh** | [README_process_sequences.md](README_process_sequences.md) | Advanced guide for batch processing script |

### General Documentation

| Document | Description |
|----------|-------------|
| [README_Suite.md](README_Suite.md) | Complete toolkit overview and workflow guide |

## 🚀 Quick Navigation

### Getting Started
1. **New Users**: Start with [README_Suite.md](README_Suite.md) for a complete overview
2. **Pattern Analysis**: See [README.md](README.md) for S1 tool usage
3. **File Splitting**: Check [README_S2_Split.md](README_S2_Split.md) for S2 tool
4. **Batch Processing**: Review [README_process_sequences.md](README_process_sequences.md) for S3 tool

### Common Tasks

#### Basic Sequence Analysis
```bash
# From project root directory
python src/S1_Process_gen.py -p "ATCGATCG,GCTAGCTA" -d "Analysis"
```
See: [S1 Documentation](README.md)

#### FASTQ File Splitting
```bash
# From project root directory
python src/S2_Split.py -i input.fastq.gz -o output_dir
```
See: [S2 Documentation](README_S2_Split.md)

#### Batch Processing
```bash
# From project root directory
./src/S3_process_sequences_count.sh -p "SEQ1,SEQ2" -j 8
```
See: [S3 Documentation](README_process_sequences.md)

## 📖 Documentation Guidelines

### Path References in Documentation
All example commands in the documentation assume you are running from the project root directory:

```
sequence-processing-toolkit/
├── src/           # Scripts are here
├── docs/          # You are here
└── examples/      # Usage examples
```

### File Paths in Commands
- Scripts: `src/script_name.py` or `src/script_name.sh`
- Documentation: `docs/document_name.md`
- Examples: `examples/example_name.sh`

## 🔧 Troubleshooting

### Common Issues
1. **Script not found**: Ensure you're in the project root directory
2. **Permission denied**: Run `chmod +x src/*.py src/*.sh`
3. **Path issues**: Use relative paths from project root

### Getting Help
```bash
# Tool-specific help
python src/S1_Process_gen.py -h
python src/S2_Split.py -h
./src/S3_process_sequences_count.sh -h
```

## 📝 Contributing to Documentation

When updating documentation:
1. Keep examples relative to project root
2. Update this index when adding new documents
3. Ensure cross-references are accurate
4. Test all example commands

---

🏠 **Return to Main README**: [../README.md](../README.md) 