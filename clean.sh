#!/bin/bash
# =============================================================================
# MTNC Translator - Clean Build Artifacts (Enhanced)
# =============================================================================
# Reliable cleaning with error handling and comprehensive artifact removal
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
REMOVED_DIRS=0
REMOVED_FILES=0
SKIPPED=0

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_step() {
    echo -e "${CYAN}➜${NC} $1"
}

# Safe remove directory function
safe_remove_dir() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        log_step "Removing $description..."
        if rm -rf "$dir" 2>/dev/null; then
            ((REMOVED_DIRS++)) || true
            log_success "  Removed: $dir"
        else
            log_warning "  Failed to remove: $dir"
            ((SKIPPED++)) || true
        fi
    fi
}

# Safe remove file function
safe_remove_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        log_step "Removing $description..."
        if rm -f "$file" 2>/dev/null; then
            ((REMOVED_FILES++)) || true
            log_success "  Removed: $file"
        else
            log_warning "  Failed to remove: $file"
            ((SKIPPED++)) || true
        fi
    fi
}

# Safe clean directory contents (keep directory)
safe_clean_dir() {
    local dir="$1"
    local description="$2"
    local pattern="${3:-*}"
    
    if [ -d "$dir" ]; then
        log_step "Cleaning $description..."
        if find "$dir" -maxdepth 1 -name "$pattern" -exec rm -rf {} + 2>/dev/null; then
            log_success "  Cleaned: $dir"
        else
            log_warning "  Failed to clean: $dir"
            ((SKIPPED++)) || true
        fi
    fi
}

# =============================================================================
# MAIN CLEANING ROUTINES
# =============================================================================

clean_build_artifacts() {
    echo ""
    log_info "╔══════════════════════════════════════════════════════════════╗"
    echo -e "${BLUE}║  MTNC Translator - Clean Build Artifacts                    ║${NC}"
    log_info "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    log_info "Phase 1: Cleaning build artifacts..."
    echo ""
    
    # Clean dist folder
    safe_remove_dir "$PROJECT_ROOT/dist" "distribution folder"
    
    # Clean build folder
    safe_remove_dir "$PROJECT_ROOT/build" "build folder"
    
    # Clean bin folder (preserve install scripts and metadata)
    if [ -d "$PROJECT_ROOT/bin" ]; then
        log_step "Cleaning bin folder (preserving install scripts)..."
        find "$PROJECT_ROOT/bin" -type f ! -name "install.sh" ! -name "*.md" ! -name "*.txt" -delete 2>/dev/null || true
        find "$PROJECT_ROOT/bin" -type d -empty -delete 2>/dev/null || true
        log_success "  Cleaned bin folder"
    fi
}

clean_output_folders() {
    echo ""
    log_info "Phase 2: Cleaning output folders..."
    echo ""
    
    # Clean mods/output test folders
    if [ -d "$PROJECT_ROOT/mods/output" ]; then
        safe_remove_dir "$PROJECT_ROOT/mods/output/testmod*" "test mod outputs"
        safe_clean_dir "$PROJECT_ROOT/mods/output" "mod output folder" "build"
        safe_clean_dir "$PROJECT_ROOT/mods/output" "mod output folder" "CMakeFiles"
        safe_clean_dir "$PROJECT_ROOT/mods/output" "mod output folder" "cmake_install.cmake"
        safe_clean_dir "$PROJECT_ROOT/mods/output" "mod output folder" "Makefile"
        safe_clean_dir "$PROJECT_ROOT/mods/output" "mod output folder" "*.so"
        safe_clean_dir "$PROJECT_ROOT/mods/output" "mod output folder" "*.dll"
    fi
    
    # Clean examples output
    if [ -d "$PROJECT_ROOT/examples/output" ]; then
        safe_clean_dir "$PROJECT_ROOT/examples/output" "example outputs" "build"
    fi
}

clean_cache_files() {
    echo ""
    log_info "Phase 3: Cleaning cache files..."
    echo ""
    
    # Clean MTNC cache
    safe_remove_dir "$PROJECT_ROOT/.mtnc-cache" "MTNC cache"
    
    # Clean temp files
    safe_remove_dir "$PROJECT_ROOT/.mtnc-temp" "MTNC temp"
    
    # Clean ESLint cache
    safe_remove_file "$PROJECT_ROOT/.eslintcache" "ESLint cache"
    
    # Clean TypeScript cache
    safe_remove_dir "$PROJECT_ROOT/.tsbuildinfo" "TypeScript build info"
    safe_remove_file "$PROJECT_ROOT/tsconfig.tsbuildinfo" "TypeScript build info"
    
    # Clean node cache
    safe_remove_dir "$PROJECT_ROOT/.node-cache" "Node cache"
}

clean_test_artifacts() {
    echo ""
    log_info "Phase 4: Cleaning test artifacts..."
    echo ""
    
    # Clean coverage
    safe_remove_dir "$PROJECT_ROOT/coverage" "test coverage"
    
    # Clean test output
    safe_remove_dir "$PROJECT_ROOT/.nyc_output" "NYC test output"
    
    # Clean Jest cache
    safe_remove_dir "$PROJECT_ROOT/node_modules/.cache/jest" "Jest cache" 2>/dev/null || true
}

clean_dependency_cache() {
    echo ""
    log_info "Phase 5: Cleaning dependency cache (optional)..."
    echo ""
    
    # Clean npm cache (project-level only)
    if [ -d "$PROJECT_ROOT/node_modules/.cache" ]; then
        safe_clean_dir "$PROJECT_ROOT/node_modules/.cache" "npm cache"
    fi
    
    # Clean parcel cache if exists
    safe_remove_dir "$PROJECT_ROOT/.parcel-cache" "Parcel cache"
    
    # Clean webpack cache
    safe_remove_dir "$PROJECT_ROOT/node_modules/.cache/webpack" "Webpack cache" 2>/dev/null || true
}

clean_system_files() {
    echo ""
    log_info "Phase 6: Cleaning system files..."
    echo ""
    
    # Clean OS files
    if [ -f "$PROJECT_ROOT/.DS_Store" ]; then
        safe_remove_file "$PROJECT_ROOT/.DS_Store" "macOS DS_Store"
    fi
    
    # Find and remove all .DS_Store files
    if command -v find &> /dev/null; then
        log_step "Removing .DS_Store files..."
        find "$PROJECT_ROOT" -name ".DS_Store" -type f -delete 2>/dev/null || true
        log_success "  Removed .DS_Store files"
    fi
    
    # Clean Thumbs.db (Windows)
    if command -v find &> /dev/null; then
        find "$PROJECT_ROOT" -name "Thumbs.db" -type f -delete 2>/dev/null || true
    fi
    
    # Clean *~ backup files
    if command -v find &> /dev/null; then
        find "$PROJECT_ROOT" -name "*~" -type f -delete 2>/dev/null || true
    fi
}

clean_logs() {
    echo ""
    log_info "Phase 7: Cleaning log files..."
    echo ""
    
    # Clean log files
    safe_clean_dir "$PROJECT_ROOT" "root logs" "*.log"
    safe_remove_dir "$PROJECT_ROOT/logs" "logs directory"
    
    # Clean npm debug logs
    if [ -d "$PROJECT_ROOT/logs/npm" ]; then
        safe_clean_dir "$PROJECT_ROOT/logs/npm" "npm logs"
    fi
}

# =============================================================================
# SUMMARY
# =============================================================================

print_summary() {
    echo ""
    log_info "╔══════════════════════════════════════════════════════════════╗"
    log_info "║  Clean Summary                                                ║"
    log_info "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_success "Removed $REMOVED_DIRS directories"
    log_success "Removed $REMOVED_FILES files"
    
    if [ $SKIPPED -gt 0 ]; then
        log_warning "Skipped $SKIPPED items (may be in use or permission denied)"
    fi
    
    echo ""
    log_info "Next steps:"
    echo -e "  ${CYAN}1.${NC} npm install    (if dependencies need reinstall)"
    echo -e "  ${CYAN}2.${NC} npm run build  (rebuild the translator)"
    echo -e "  ${CYAN}3.${NC} mtnc translate (translate your mods)"
    echo ""
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    local start_time=$(date +%s)
    
    # Check if running in dry-run mode
    if [ "${1:-}" = "--dry-run" ] || [ "${1:-}" = "-n" ]; then
        log_warning "DRY RUN MODE - No files will be deleted"
        echo ""
        log_info "The following would be cleaned:"
        echo "  - dist/ build/ bin/ (partial)"
        echo "  - mods/output/testmod*"
        echo "  - .mtnc-cache/ .mtnc-temp/"
        echo "  - coverage/ .nyc_output/"
        echo "  - *.log logs/"
        echo "  - .DS_Store Thumbs.db *~"
        echo ""
        exit 0
    fi
    
    # Check if running in verbose mode
    if [ "${1:-}" = "--verbose" ] || [ "${1:-}" = "-v" ]; then
        set -x
    fi
    
    # Run all cleaning phases
    clean_build_artifacts
    clean_output_folders
    clean_cache_files
    clean_test_artifacts
    clean_dependency_cache
    clean_system_files
    clean_logs
    
    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_summary
    
    log_success "Clean completed in ${duration}s"
    echo ""
}

# Run main function
main "$@"
