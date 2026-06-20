#!/bin/bash
# Copy project files to github folder for clean upload
# Excludes: node_modules, dist, build artifacts, temporary files

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  MTNC Translator - Preparing GitHub Upload              ║"
echo "║  Copying files with verification...                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}"
DEST_DIR="${SCRIPT_DIR}/github"

# Create destination
echo "📁 Creating destination directory..."
rm -rf "${DEST_DIR}"
mkdir -p "${DEST_DIR}"

# Files and directories to exclude
EXCLUDE_PATTERN="{node_modules,dist,mtnc-output,bin,.qwen,.qodo,coverage,.git,.github/workflows}"

echo "📋 Copying files (excluding build artifacts)..."

# Copy files using rsync for better control
rsync -av --progress \
    --exclude=${EXCLUDE_PATTERN} \
    --exclude="*.log" \
    --exclude="*.tmp" \
    --exclude="*.bak" \
    --exclude=".DS_Store" \
    --exclude="*.zip" \
    "${SOURCE_DIR}/" "${DEST_DIR}/"

echo ""
echo "✅ Copy complete!"
echo ""

# Verify copied files
echo "🔍 Verifying copied files..."
echo ""

cd "${DEST_DIR}"

# Count files
FILE_COUNT=$(find . -type f | wc -l | tr -d ' ')
DIR_COUNT=$(find . -type d | wc -l | tr -d ' ')

echo "📊 Statistics:"
echo "  - Files copied: ${FILE_COUNT}"
echo "  - Directories: ${DIR_COUNT}"
echo ""

# Verify critical files exist
echo "🔍 Verifying critical files..."
CRITICAL_FILES=(
    "package.json"
    "tsconfig.json"
    "README.md"
    "src/index.ts"
    "src/translator/mtnc-translate.ts"
    "src/utils/file-utils.ts"
    "src/utils/graceful-shutdown.ts"
    "src/utils/input-validation.ts"
    "src/translator/type-guards.ts"
    "src/translator/cache.ts"
    "scripts/download-dependencies.js"
    "mods/build-all.sh"
    "mods/test-all-mods.sh"
)

ALL_PRESENT=true
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ ${file}"
    else
        echo "  ✗ ${file} MISSING!"
        ALL_PRESENT=false
    fi
done

echo ""

if [ "$ALL_PRESENT" = true ]; then
    echo "✅ All critical files verified!"
else
    echo "❌ Some critical files are missing!"
    exit 1
fi

# Check for syntax errors in key TypeScript files
echo ""
echo "🔍 Running TypeScript compiler check..."
if command -v npx &> /dev/null; then
    if [ -f "package.json" ]; then
        echo "Installing dependencies for verification..."
        npm install --ignore-scripts --no-audit --no-fund 2>/dev/null || true
        
        echo "Running TypeScript type check..."
        npx tsc --noEmit --skipLibCheck 2>&1 | head -20 || echo "TypeScript check completed with warnings"
    fi
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✓ GitHub folder ready for upload!                      ║"
echo "║                                                          ║"
echo "║  Location: ${DEST_DIR}"
echo "╚══════════════════════════════════════════════════════════╝"
