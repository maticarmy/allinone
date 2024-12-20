#!/bin/bash

# 创建bin目录
mkdir -p bin

# 遍历src目录下的所有.sh文件
find src -name "*.sh" | while read file; do
    # 获取文件名
    filename=$(basename "$file")
    # 复制到bin目录并添加执行权限
    cp "$file" "bin/$filename"
    chmod +x "bin/$filename"
done

echo "Build completed. Scripts are available in bin/ directory" 