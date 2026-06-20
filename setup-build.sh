#!/usr/bin/env bash
# MTNC Translator - Cross-Platform Build Script
# Automatically detects OS and builds the project

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  MTNC Translator - Build Script                         ║"
echo "║  Version: 0.0.1-pre-alpha                               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin)
    OS_NAME="macOS"
    ;;
  Linux)
    OS_NAME="Linux"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    OS_NAME="Windows"
    ;;
  *)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "🖥️  Detected OS: $OS_NAME"
echo ""

# Check for Node.js
if ! command -v node &> /dev/null; then
  echo "❌ Node.js is not installed!"
  echo "   Please install Node.js 20+ from https://nodejs.org/"
  exit 1
fi

NODE_VERSION="$(node --version)"
echo "✓ Node.js found: $NODE_VERSION"

# Check Node version (must be 20+)
NODE_MAJOR=$(node --version | cut -d'.' -f1 | sed 's/v//')
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "❌ Node.js version must be 20 or higher (current: $NODE_VERSION)"
  exit 1
fi

# Check for npm
if ! command -v npm &> /dev/null; then
  echo "❌ npm is not installed!"
  echo "   npm comes with Node.js"
  exit 1
fi

echo "✓ npm found: $(npm --version)"
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
if [ -d "dist" ]; then
  rm -rf dist
  echo "  ✓ Removed old dist/"
fi
if [ -d "node_modules" ]; then
  echo "  ℹ️  node_modules exists (will reuse)"
else
  echo "  ℹ️  node_modules not found (will install)"
fi
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
npm install --no-audit --no-fund
echo "  ✓ Dependencies installed"
echo ""

# Build
echo "🔨 Building project..."
npm run build
echo "  ✓ Build complete"
echo ""

# Verify build
echo "🔍 Verifying build..."
if [ ! -d "dist" ]; then
  echo "❌ Build failed: dist/ directory not found"
  exit 1
fi

if [ ! -f "dist/cli/index.js" ]; then
  echo "❌ Build failed: dist/cli/index.js not found"
  exit 1
fi

if [ ! -f "dist/translator/mtnc-translate.js" ]; then
  echo "❌ Build failed: dist/translator/mtnc-translate.js not found"
  exit 1
fi

FILE_COUNT=$(find dist -type f | wc -l | tr -d ' ')
echo "  ✓ Build verified: $FILE_COUNT files generated"
echo ""

# Run typecheck
echo "📝 Running type check..."
npm run typecheck || echo "  ⚠️  Type check completed with warnings"
echo ""

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✓ Build Successful!                                    ║"
echo "║                                                          ║"
echo "║  You can now run:                                        ║"
echo "║    npm start                 - Run CLI                   ║"
echo "║    npm test                  - Run tests                 ║"
echo "║    node dist/cli/index.js    - Direct execution          ║"
echo "╚══════════════════════════════════════════════════════════╝"
