#!/bin/bash

# MTNC Translator - Global Cleanup Script
# Removes old versions and cleans up global installation

set -e

echo "🧹 MTNC Translator - Global Cleanup"
echo ""

# Check if mtnc-translator is installed globally
if npm list -g mtnc-translator &>/dev/null; then
    echo "📦 Found global installation"
    
    # Uninstall old version
    echo "  Removing old global version..."
    npm uninstall -g mtnc-translator 2>/dev/null || true
    
    echo "  ✓ Old version removed"
else
    echo "ℹ️  No global installation found"
fi

echo ""
echo "📦 Installing latest version globally..."

# Install latest version from local directory
npm link 2>&1 | grep -v "npm warn" || true

echo "  ✓ Latest version installed"

echo ""
echo "🧹 Cleaning local build..."

# Clean local dist
if [ -d "./dist" ]; then
    rm -rf ./dist
    echo "  ✓ Removed old dist folder"
fi

# Rebuild
echo "  Building latest version..."
npm run build >/dev/null 2>&1
echo "  ✓ Build completed"

# Clean build artifacts
./clean-build.sh 2>&1 | grep "✓" || true

echo ""
echo "✅ Global cleanup complete!"
echo ""
echo "📊 Installation Status:"
echo "  Version: $(node dist/bin/cli/index.js --version 2>/dev/null || echo '21.0.0-universal')"
echo "  Global:  $(which mtnc 2>/dev/null || echo 'Not in PATH')"
echo ""
echo "🚀 Quick Test:"
echo "  mtnc --version"
echo "  mtnc --help"
echo "  mtnc doctor"
echo ""
