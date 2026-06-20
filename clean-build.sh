#!/bin/bash

# MTNC Translator - Build Cleanup Script
# Removes unnecessary files from dist directory

set -e

DIST_DIR="./dist"

echo "🧹 Cleaning build directory..."

# Remove markdown files
find "$DIST_DIR" -name "*.md" -type f -delete 2>/dev/null && echo "  ✓ Removed .md files"

# Remove test files
find "$DIST_DIR" -name "*.test.js" -type f -delete 2>/dev/null && echo "  ✓ Removed test files"
find "$DIST_DIR" -name "*.test.d.ts" -type f -delete 2>/dev/null && echo "  ✓ Removed test type files"
find "$DIST_DIR" -name "*.test.js.map" -type f -delete 2>/dev/null && echo "  ✓ Removed test source maps"

# Remove demo files
find "$DIST_DIR" -name "demo.js" -type f -delete 2>/dev/null && echo "  ✓ Removed demo files"
find "$DIST_DIR" -name "demo.d.ts" -type f -delete 2>/dev/null && echo "  ✓ Removed demo type files"

# Remove empty directories
find "$DIST_DIR" -type d -empty -delete 2>/dev/null && echo "  ✓ Removed empty directories"

echo ""
echo "✅ Build cleanup complete!"

# Show final size
if command -v du &> /dev/null; then
    SIZE=$(du -sh "$DIST_DIR" 2>/dev/null | cut -f1)
    echo "📊 Final build size: $SIZE"
fi
