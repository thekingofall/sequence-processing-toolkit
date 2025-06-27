# 🚀 OSS下载脚本 - 快速开始

## 30秒快速开始

```bash
# 1. 进入脚本目录
cd sequence-processing-toolkit/Scripts/

# 2. 设置权限
chmod +x oss_download.sh

# 3. 使用示例配置快速测试
./oss_download.sh -i oss_paths_example.txt -o ./test_downloads
```

## ⚡ 自定义下载

### Step 1: 创建你的路径文件
```bash
cat > my_paths.txt << EOF
oss://your-bucket/path1/data1
oss://your-bucket/path2/data2
EOF
```

### Step 2: 运行下载
```bash
./oss_download.sh -i my_paths.txt -o ./my_downloads
```

### Step 3: 首次使用配置OSS
按提示输入：
- **Endpoint**: `oss-cn-beijing.aliyuncs.com`
- **AccessKey ID**: `你的AccessKey`
- **AccessKey Secret**: `你的Secret`

## 📝 路径文件格式

```
# 注释行以#开头
oss://bucket1/project/data1
oss://bucket2/project/data2
oss://bucket3/project/data3
```

## 🆘 遇到问题？

```bash
# 查看帮助
./oss_download.sh --help

# 重新配置OSS
rm ~/.ossutilconfig
./oss_download.sh -i paths.txt -o output
```

## 📖 详细文档

查看完整文档：[README_OSS.md](./README_OSS.md)

---
*就这么简单！* 🎉 