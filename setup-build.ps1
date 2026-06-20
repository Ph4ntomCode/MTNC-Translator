# MTNC Translator - Windows Build Script (PowerShell)
# Automatically builds the project on Windows

Write-Host "╔══════════════════════════════════════════════════════════╗"
Write-Host "║  MTNC Translator - Build Script (Windows)               ║"
Write-Host "║  Version: 0.0.1-pre-alpha                               ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# Check for Node.js
try {
  $nodeVersion = node --version
  Write-Host "✓ Node.js found: $nodeVersion"
} catch {
  Write-Host "❌ Node.js is not installed!" -ForegroundColor Red
  Write-Host "   Please install Node.js 20+ from https://nodejs.org/"
  exit 1
}

# Check Node version (must be 20+)
$nodeMajor = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
if ($nodeMajor -lt 20) {
  Write-Host "❌ Node.js version must be 20 or higher (current: $nodeVersion)" -ForegroundColor Red
  exit 1
}

# Check for npm
try {
  $npmVersion = npm --version
  Write-Host "✓ npm found: $npmVersion"
} catch {
  Write-Host "❌ npm is not installed!" -ForegroundColor Red
  exit 1
}

Write-Host ""

# Clean previous build
Write-Host "🧹 Cleaning previous build..."
if (Test-Path "dist") {
  Remove-Item -Recurse -Force "dist"
  Write-Host "  ✓ Removed old dist/"
} else {
  Write-Host "  ℹ️  No previous build found"
}
Write-Host ""

# Install dependencies
Write-Host "📦 Installing dependencies..."
npm install --no-audit --no-fund
Write-Host "  ✓ Dependencies installed"
Write-Host ""

# Build
Write-Host "🔨 Building project..."
npm run build
Write-Host "  ✓ Build complete"
Write-Host ""

# Verify build
Write-Host "🔍 Verifying build..."
if (-not (Test-Path "dist")) {
  Write-Host "❌ Build failed: dist/ directory not found" -ForegroundColor Red
  exit 1
}

if (-not (Test-Path "dist\cli\index.js")) {
  Write-Host "❌ Build failed: dist/cli/index.js not found" -ForegroundColor Red
  exit 1
}

if (-not (Test-Path "dist\translator\mtnc-translate.js")) {
  Write-Host "❌ Build failed: dist/translator/mtnc-translate.js not found" -ForegroundColor Red
  exit 1
}

$fileCount = (Get-ChildItem -Path "dist" -Recurse -File | Measure-Object).Count
Write-Host "  ✓ Build verified: $fileCount files generated"
Write-Host ""

Write-Host "╔══════════════════════════════════════════════════════════╗"
Write-Host "║  ✓ Build Successful!                                    ║"
Write-Host "║                                                          ║"
Write-Host "║  You can now run:                                        ║"
Write-Host "║    npm start                 - Run CLI                   ║"
Write-Host "║    npm test                  - Run tests                 ║"
Write-Host "║    node dist/cli/index.js    - Direct execution          ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"
