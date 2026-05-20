#!/bin/bash
# ============================================
# 第三方依赖下载脚本
# 下载并解压 libjpeg-turbo, libpng, libyuv, zlib
# 用法: bash download_deps.sh
# ============================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THIRD_PARTY_DIR="$SCRIPT_DIR/third_party"

mkdir -p "$THIRD_PARTY_DIR"

# 下载并解压函数
download_and_extract() {
    local name="$1"
    local url="$2"
    local src_dir="$3"

    if [ -d "$THIRD_PARTY_DIR/$name" ]; then
        echo "[SKIP] $name already exists at $THIRD_PARTY_DIR/$name"
        return
    fi

    echo "========================================"
    echo "[DOWNLOAD] $name"
    echo "  URL: $url"
    echo "========================================"

    local archive="$THIRD_PARTY_DIR/${name}.tar.gz"

    if ! curl -L --progress-bar -o "$archive" "$url"; then
        echo "[ERROR] Failed to download $name from $url"
        rm -f "$archive"
        exit 1
    fi

    echo "[EXTRACT] $name ..."
    tar -xzf "$archive" -C "$THIRD_PARTY_DIR"
    rm -f "$archive"

    # 重命名解压目录为标准名称
    if [ -d "$THIRD_PARTY_DIR/$src_dir" ] && [ "$src_dir" != "$name" ]; then
        mv "$THIRD_PARTY_DIR/$src_dir" "$THIRD_PARTY_DIR/$name"
        echo "[RENAME] $src_dir -> $name"
    fi

    echo "[DONE] $name ready at $THIRD_PARTY_DIR/$name"
    echo ""
}

# ============================================
# 1. zlib v1.3.1
# ============================================
download_and_extract "zlib" \
    "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz" \
    "zlib-1.3.1"

# ============================================
# 2. libpng 1.6.43
# ============================================
download_and_extract "libpng" \
    "https://download.sourceforge.net/libpng/libpng-1.6.43.tar.gz" \
    "libpng-1.6.43"

# ============================================
# 3. libjpeg-turbo 3.1.2
# ============================================
download_and_extract "libjpeg-turbo" \
    "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/3.1.2.tar.gz" \
    "libjpeg-turbo-3.1.2"

# ============================================
# 4. libyuv (bg-1998 fork, tag 1.0.0)
# ============================================
download_and_extract "libyuv" \
    "https://codeload.github.com/bg-1998/libyuv/tar.gz/refs/tags/1.0.0" \
    "bg-1998-libyuv-1.0.0"

echo "========================================"
echo "All dependencies downloaded successfully!"
echo "Location: $THIRD_PARTY_DIR"
echo "========================================"
echo ""
echo "Ready to build with: USE_FULL_DEPENDENCIES=ON"