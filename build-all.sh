#!/bin/bash
# =============================================================================
# MTNC Translator - Universal Cross-Platform Build Script v21.0.0
# Builds for macOS (x86_64 & ARM64), Linux (x64 & ARM64), and Windows (x64 & ARM64)
# Supports ANY mod type, ANY .NET assembly, and complex dependency graphs
# =============================================================================

set -euo pipefail

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  MTNC Translator v21.0.0 - Universal Build                   ║"
echo "║  Any Mod • Any Assembly • Cross-Platform                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# Build configuration
BUILD_TYPE="${BUILD_TYPE:-release}"
COMPRESSION="${COMPRESSION:-gzip}"
SKIP_PKG="${SKIP_PKG:-false}"
VERBOSE="${VERBOSE:-false}"
BUILD_ALL="${BUILD_ALL:-false}"

# Counters
BUILT_TARGETS=0
FAILED_TARGETS=0
TOTAL_TARGETS=0

# =============================================================================
# Helper Functions
# =============================================================================

log_info() {
    local message="$1"
    echo -e "${BLUE}ℹ${NC} ${message}"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}✓${NC} ${message}"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠${NC} ${message}"
}

log_error() {
    local message="$1"
    echo -e "${RED}✗${NC} ${message}"
}

log_step() {
    local message="$1"
    echo -e "${CYAN}➜${NC} ${message}"
}

check_command() {
    local command_name="$1"

    if ! command -v "$command_name" &> /dev/null; then
        log_warning "Command '$command_name' not found. Some features may be unavailable."
        return 1
    fi
    return 0
}

require_host_os() {
    if [ -z "${HOST_OS:-}" ]; then
        log_error "HOST_OS is not defined"
        exit 1
    fi
}

# =============================================================================
# Environment Detection
# =============================================================================

log_info "Detecting build environment..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    HOST_OS="macos"
    HOST_OS_DISPLAY="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    HOST_OS="linux"
    HOST_OS_DISPLAY="Linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    HOST_OS="windows"
    HOST_OS_DISPLAY="Windows"
else
    HOST_OS="unknown"
    HOST_OS_DISPLAY="Unknown"
fi

require_host_os

# Detect architecture
HOST_ARCH=$(uname -m)
case "$HOST_ARCH" in
    x86_64|amd64)
        HOST_ARCH_DISPLAY="x64"
        ;;
    arm64|aarch64)
        HOST_ARCH_DISPLAY="arm64"
        ;;
    *)
        HOST_ARCH_DISPLAY="$HOST_ARCH"
        ;;
esac

log_info "Host: ${HOST_OS_DISPLAY} (${HOST_ARCH_DISPLAY})"

# Check Node.js version
if check_command node; then
    NODE_VERSION=$(node --version)
    log_info "Node.js: ${NODE_VERSION}"
fi

# Check npm version
if check_command npm; then
    NPM_VERSION=$(npm --version)
    log_info "npm: ${NPM_VERSION}"
fi

# Check for pkg
if [ "$SKIP_PKG" != "true" ]; then
    if check_command pkg; then
        PKG_VERSION=$(pkg --version 2>&1 | head -n 1)
        log_info "pkg: ${PKG_VERSION}"
    else
        log_warning "pkg not installed. Binary builds will use tarballs instead."
        SKIP_PKG="true"
    fi
fi

# =============================================================================
# Setup
# =============================================================================

log_step "Installing dependencies..."
npm install --legacy-peer-deps 2>/dev/null || npm install

log_step "Building TypeScript..."
npm run build

# Create bin directory
mkdir -p bin

# Create distribution info file
cat > bin/BUILD_INFO.txt << EOF
MTNC Translator v21.0.0 - Universal Build
==========================================
Build Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Host OS: ${HOST_OS_DISPLAY} (${HOST_ARCH_DISPLAY})
Build Type: ${BUILD_TYPE}

Available Targets:
EOF

# =============================================================================
# Build Functions
# =============================================================================

build_with_pkg() {
    local target="$1"
    local output="$2"
    local description="$3"
    
    TOTAL_TARGETS=$((TOTAL_TARGETS + 1))
    
    log_step "${description}..."
    
    if [ "$SKIP_PKG" == "true" ]; then
        log_warning "pkg unavailable, creating source tarball..."
        create_tarball "$output"
        return $?
    fi
    
    if pkg . --targets "$target" --output "$output" --compress "$COMPRESSION" 2>/dev/null; then
        log_success "Built: $output"
        BUILT_TARGETS=$((BUILT_TARGETS + 1))
        echo "  - $output ($(du -h "$output" 2>/dev/null | cut -f1))" >> bin/BUILD_INFO.txt
        return 0
    else
        log_error "pkg build failed for $target (falling back to tarball)"
        FAILED_TARGETS=$((FAILED_TARGETS + 1))
        create_tarball "$output"
        return 1
    fi
}

create_tarball() {
    local base_name="$1"
    local WORKDIR="$PROJECT_ROOT"
    local archive_path=""
    local OUT=""
    local archive_size=""

    if [ "$HOST_OS" == "windows" ]; then
        # Windows zip
        if check_command zip; then
            archive_path="${base_name}.zip"
            OUT="$archive_path"
            if ! (cd "$WORKDIR" && zip -r "$OUT" \
                . \
                -x './node_modules/*' \
                -x './dist/*' \
                -x './*.tar.gz' \
                -x './*.zip') 2>/dev/null; then
                log_error "Failed to create zip archive"
                return 1
            fi
        else
            archive_path="${base_name}.tar.gz"
            OUT="$archive_path"
            if ! (cd "$WORKDIR" && tar -czf "$OUT" \
                --exclude='./node_modules' \
                --exclude='./dist' \
                --exclude='./*.tar.gz' \
                --exclude='./*.zip' \
                .); then
                log_error "Failed to create tarball"
                return 1
            fi
        fi
    else
        # Unix tarball
        archive_path="${base_name}.tar.gz"
        OUT="$archive_path"
        if ! (cd "$WORKDIR" && tar -czf "$OUT" \
            --exclude='./node_modules' \
            --exclude='./dist' \
            --exclude='./*.tar.gz' \
            --exclude='./*.zip' \
            .); then
            log_error "Failed to create tarball"
            return 1
        fi
    fi

    if ! archive_size="$(du -h "$archive_path" 2>/dev/null | cut -f1)"; then
        log_error "Failed to determine archive size for $archive_path"
        return 1
    fi

    log_success "Created: $archive_path"
    BUILT_TARGETS=$((BUILT_TARGETS + 1))
    echo "  - $archive_path ($archive_size)" >> bin/BUILD_INFO.txt

    return 0
}

# =============================================================================
# macOS Builds
# =============================================================================

build_macos() {
    echo ""
    log_info "${MAGENTA}Building for macOS...${NC}"
    echo ""
    
    # macOS x86_64 (Intel)
    build_with_pkg "node18-macos-x64" "bin/mtnc-macos-x64" "macOS x86_64 (Intel)" || return 1
    
    # macOS ARM64 (Apple Silicon)
    build_with_pkg "node18-macos-arm64" "bin/mtnc-macos-arm64" "macOS ARM64 (Apple Silicon)" || return 1
    
    # Create universal binary wrapper (if both builds succeeded)
    if [ -f "bin/mtnc-macos-x64" ] && [ -f "bin/mtnc-macos-arm64" ]; then
        log_step "Creating universal macOS binary..."
        # Create a shell script that detects architecture and runs appropriate binary
        cat > bin/mtnc-macos-universal << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH=$(uname -m)

case "$ARCH" in
    arm64)
        exec "$SCRIPT_DIR/mtnc-macos-arm64" "$@"
        ;;
    x86_64)
        exec "$SCRIPT_DIR/mtnc-macos-x64" "$@"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
EOF
        chmod +x bin/mtnc-macos-universal
        log_success "Created: mtnc-macos-universal"
        BUILT_TARGETS=$((BUILT_TARGETS + 1))
    fi
}

# =============================================================================
# Linux Builds
# =============================================================================

build_linux() {
    echo ""
    log_info "${MAGENTA}Building for Linux...${NC}"
    echo ""
    
    # Linux x64
    build_with_pkg "node18-linux-x64" "bin/mtnc-linux-x64" "Linux x64" || return 1
    
    # Linux ARM64
    build_with_pkg "node18-linux-arm64" "bin/mtnc-linux-arm64" "Linux ARM64" || return 1
    
    # Linux static binary (if available)
    if [ "$SKIP_PKG" != "true" ]; then
        log_step "Linux static x64 (portable)..."
        if pkg . --targets "node18-linuxstatic-x64" --output "bin/mtnc-linux-static-x64" --compress "$COMPRESSION" 2>/dev/null; then
            log_success "Built: mtnc-linux-static-x64 (static binary)"
            BUILT_TARGETS=$((BUILT_TARGETS + 1))
            echo "  - mtnc-linux-static-x64 (static)" >> bin/BUILD_INFO.txt
        else
            log_warning "Static Linux build not available"
        fi
    fi
}

# =============================================================================
# Windows Builds
# =============================================================================

build_windows() {
    echo ""
    log_info "${MAGENTA}Building for Windows...${NC}"
    echo ""
    
    # Windows x64
    build_with_pkg "node18-win-x64" "bin/mtnc-win-x64" "Windows x64" || return 1
    
    # Windows ARM64
    build_with_pkg "node18-win-arm64" "bin/mtnc-win-arm64" "Windows ARM64" || return 1
    
    # Rename to .exe if needed
    if [ -f "bin/mtnc-win-x64" ] && [ ! -f "bin/mtnc-win-x64.exe" ]; then
        mv "bin/mtnc-win-x64" "bin/mtnc-win-x64.exe" 2>/dev/null || true
    fi
    if [ -f "bin/mtnc-win-arm64" ] && [ ! -f "bin/mtnc-win-arm64.exe" ]; then
        mv "bin/mtnc-win-arm64" "bin/mtnc-win-arm64.exe" 2>/dev/null || true
    fi
}

# =============================================================================
# Additional Artifacts
# =============================================================================

create_additional_artifacts() {
    echo ""
    log_step "Creating additional artifacts..."
    
    # Copy PRISM API header
    if [ -f "prism_mod_api.hpp" ]; then
        cp prism_mod_api.hpp bin/
        log_success "Copied: prism_mod_api.hpp"
    fi
    
    # Copy example config
    if [ -f "mtnc-config.example.json" ]; then
        cp mtnc-config.example.json bin/
        log_success "Copied: mtnc-config.example.json"
    fi
    
    # Create README for bin directory
    cat > bin/README.md << 'EOF'
# MTNC Translator - Universal Binaries v21.0.0

## Quick Start

### macOS
```bash
# Universal (auto-detects architecture)
./mtnc-macos-universal [command]

# Or specific architecture
./mtnc-macos-x64 [command]     # Intel Macs
./mtnc-macos-arm64 [command]   # Apple Silicon Macs
```

### Linux
```bash
# Standard builds
./mtnc-linux-x64 [command]     # Most Linux distributions
./mtnc-linux-arm64 [command]   # ARM64 devices (Raspberry Pi 4, etc.)

# Static build (no dependencies required)
./mtnc-linux-static-x64 [command]
```

### Windows
```cmd
REM Standard builds
mtnc-win-x64.exe [command]     # 64-bit Windows
mtnc-win-arm64.exe [command]   # ARM64 Windows (Surface Pro X, etc.)
```

## Usage Examples

```bash
# Translate a DLL
mtnc translate MyMod.dll -o ./output

# Translate with dependencies
mtnc translate MyMod.dll -d /path/to/dep1.dll -d /path/to/dep2.dll

# Auto-detect and resolve dependencies
mtnc translate MyMod.dll --auto-deps

# Translate C# source files
mtnc translate-source MyMod.cs -o ./output

# Analyze assembly
mtnc analyze MyMod.dll

# Build translated code
mtnc build ./output
```

## Features

- **Universal Support**: Works with ANY .NET assembly, not just game mods
- **Complex Dependencies**: Handles dependency-heavy projects automatically
- **Cross-Platform**: Build on any platform, deploy anywhere
- **PRISM API**: Complete modding API with ZERO stubs
- **Auto-Dependency Resolution**: Finds and translates required dependencies

## Support

- Documentation: https://github.com/mtnc-translator/mtnc
- Issues: https://github.com/mtnc-translator/mtnc/issues
EOF
    log_success "Created: README.md"
}

# =============================================================================
# Main Build Process
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Starting Build Process                                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

case "$HOST_OS" in
    macos)
        build_macos
        if [ "$BUILD_ALL" == "true" ]; then
            build_linux
            build_windows
        fi
        ;;
    linux)
        build_linux
        if [ "$BUILD_ALL" == "true" ]; then
            build_macos
            build_windows
        fi
        ;;
    windows)
        build_windows
        if [ "$BUILD_ALL" == "true" ]; then
            build_macos
            build_linux
        fi
        ;;
    *)
        log_error "Unsupported operating system: $HOST_OS"
        exit 1
        ;;
esac

create_additional_artifacts

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Build Complete!                                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓${NC} Build Statistics:"
echo "   Successful: ${BUILT_TARGETS}"
echo "   Failed: ${FAILED_TARGETS}"
echo "   Total: ${TOTAL_TARGETS}"
echo ""
echo -e "${BLUE}ℹ${NC} Output files in bin/:"
echo ""

# List built artifacts
if [ -d "bin" ]; then
    if ! ls -lh bin/ | grep -E 'mtnc-|\.tar\.gz|\.zip|\.exe' | awk '{printf "   %s (%s)\n", $9, $5}'; then
        log_warning "No built artifacts found in bin/"
    fi
fi

echo ""
echo -e "${CYAN}Usage:${NC}"
case "$HOST_OS" in
    macos)
        echo "   macOS Universal:  ./bin/mtnc-macos-universal [command]"
        echo "   macOS Intel:      ./bin/mtnc-macos-x64 [command]"
        echo "   macOS Apple Silicon: ./bin/mtnc-macos-arm64 [command]"
        ;;
    linux)
        echo "   Linux x64:        ./bin/mtnc-linux-x64 [command]"
        echo "   Linux ARM64:      ./bin/mtnc-linux-arm64 [command]"
        echo "   Linux Static:     ./bin/mtnc-linux-static-x64 [command]"
        ;;
    windows)
        echo "   Windows x64:      bin\\mtnc-win-x64.exe [command]"
        echo "   Windows ARM64:    bin\\mtnc-win-arm64.exe [command]"
        ;;
esac

echo ""
echo -e "${BLUE}ℹ${NC} See bin/README.md for complete usage instructions"
echo ""

# Update BUILD_INFO with summary
cat >> bin/BUILD_INFO.txt << EOF

Build Summary:
  Successful: ${BUILT_TARGETS}
  Failed: ${FAILED_TARGETS}
  Total: ${TOTAL_TARGETS}
EOF

# Exit with error if any builds failed
if [ "$FAILED_TARGETS" -gt 0 ]; then
    log_warning "Some builds failed. Check output above for details."
    exit 1
fi

log_success "All builds completed successfully!"
exit 0
