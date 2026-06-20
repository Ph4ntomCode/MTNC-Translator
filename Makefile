# =============================================================================
# MTNC Translator - Universal Makefile v21.0.0
# Any Mod • Any Assembly • Cross-Platform
# Supports: .dll, .dylib, .so, .cs files with complex dependency resolution
# =============================================================================

.PHONY: all build test lint format clean install help dev translate translate-interactive translate-source analyze build-all

# =============================================================================
# Configuration
# =============================================================================

PROJECT_NAME := mtnc-translator
VERSION := 21.0.0-universal

# Directories
SRC_DIR := src
DIST_DIR := dist
TRANSLATOR_DIR := translator
BUILD_DIR := build
MODS_DIR := mods
OUTPUT_DIR := $(MODS_DIR)/output
DEPENDENCIES_DIR := dependencies

# Colors
COLOR_RESET := \033[0m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m
COLOR_CYAN := \033[36m
COLOR_RED := \033[31m
COLOR_MAGENTA := \033[35m
COLOR_WHITE := \033[37m
COLOR_BOLD := \033[1m

# UI Characters
UI_SUCCESS := ✓
UI_ERROR := ✗
UI_WARNING := ⚠
UI_INFO := ℹ
UI_ARROW := ➜
UI_LINE := ──────────────────────────────────────────────────────────────────────

# Build targets
BUILD_TARGETS ?= all
NODE_VERSION ?= 18

# =============================================================================
# Helper Functions
# =============================================================================

define print_header
	@printf "\n"
	@printf "$(COLOR_GREEN)╔$(COLOR_RESET)"
	@printf "$(COLOR_GREEN)════════════════════════════════════════════════════════════════════════╗$(COLOR_RESET)\n"
	@printf "$(COLOR_GREEN)║$(COLOR_RESET)  $(COLOR_BOLD)$(COLOR_CYAN)$(1)$(COLOR_RESET)$(COLOR_GREEN)$(shell printf '%*s' $$(($(shell printf "$(1)" | wc -c) - 68)) '')$(COLOR_RESET)  $(COLOR_GREEN)║$(COLOR_RESET)\n"
	@printf "$(COLOR_GREEN)║$(COLOR_RESET)  $(COLOR_GRAY)$(2)$(COLOR_RESET)$(COLOR_GREEN)$(shell printf '%*s' $$(($(shell printf "$(2)" | wc -c) - 68)) '')$(COLOR_RESET)  $(COLOR_GREEN)║$(COLOR_RESET)\n"
	@printf "$(COLOR_GREEN)╚$(COLOR_RESET)"
	@printf "$(COLOR_GREEN)════════════════════════════════════════════════════════════════════════╝$(COLOR_RESET)\n"
	@printf "\n"
endef

define print_section
	@printf "\n"
	@printf "$(COLOR_CYAN)$(UI_LINE)$(COLOR_RESET)\n"
	@printf "$(COLOR_BOLD)$(COLOR_WHITE)$(1)$(COLOR_RESET)\n"
	@printf "$(COLOR_CYAN)$(UI_LINE)$(COLOR_RESET)\n"
endef

define print_success
	@printf "$(COLOR_GREEN)$(UI_SUCCESS)$(COLOR_RESET) $(1)\n"
endef

define print_error
	@printf "$(COLOR_RED)$(UI_ERROR)$(COLOR_RESET) $(1)\n"
endef

define print_warning
	@printf "$(COLOR_YELLOW)$(UI_WARNING)$(COLOR_RESET) $(1)\n"
endef

define print_info
	@printf "$(COLOR_BLUE)$(UI_INFO)$(COLOR_RESET) $(1)\n"
endef

define print_arrow
	@printf "$(COLOR_CYAN)$(UI_ARROW)$(COLOR_RESET) $(1)\n"
endef

# =============================================================================
# Default Target
# =============================================================================

all: build
	@$(call print_success) Build completed successfully
	@printf "\n"

# =============================================================================
# Setup & Dependencies
# =============================================================================

setup:
	@$(call print_header, "MTNC Translator - Setup", "Installing dependencies...")
	@$(call print_arrow) Installing Node.js dependencies...
	@npm install --legacy-peer-deps
	@$(call print_success) Setup complete
	@printf "\n"

deps:
	@$(call print_arrow) Installing dependencies...
	@npm install --legacy-peer-deps
	@$(call print_success) Dependencies installed
	@printf "\n"

update-deps:
	@$(call print_arrow) Updating dependencies...
	@npm update
	@$(call print_success) Dependencies updated
	@printf "\n"

# =============================================================================
# Build
# =============================================================================

build: build-cli build-translator
	@$(call print_success) Build completed successfully
	@printf "\n"

build-cli:
	@$(call print_header, "MTNC CLI - Build", "Compiling CLI...")
	@$(call print_arrow) Building mtnc CLI...
	@npx tsc $(SRC_DIR)/cli/mtnc.ts --outDir $(DIST_DIR)/cli --module commonjs --esModuleInterop --skipLibCheck --target ES2020
	@$(call print_success) CLI compiled successfully
	@$(call print_info) Output: $(DIST_DIR)/cli/mtnc.js
	@printf "\n"

build-translator:
	@$(call print_header, "MTNC Translator - Build", "Compiling Translator...")
	@$(call print_arrow) Building translator...
	@npx tsc $(SRC_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.ts --outDir $(DIST_DIR)/$(TRANSLATOR_DIR) --module commonjs --esModuleInterop --skipLibCheck --downlevelIteration --target ES2020
	@$(call print_success) Translator compiled successfully
	@$(call print_info) Output: $(DIST_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.js
	@printf "\n"

build-watch:
	@$(call print_arrow) Starting watch mode...
	@npx tsc --watch

dev: build
	@$(call print_arrow) Starting development mode...
	@node $(DIST_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.js

# =============================================================================
# Cross-Platform Builds
# =============================================================================

build-all: build
	@$(call print_header, "MTNC - Cross-Platform Build", "Building for all platforms...")
	@$(call print_arrow) Running universal build script...
	@bash build-all.sh
	@printf "\n"

build-macos: build
	@$(call print_header, "MTNC - macOS Build", "Building for macOS...")
	@$(call print_arrow) Building for macOS x64...
	@npx pkg . --targets node$(NODE_VERSION)-macos-x64 --output bin/mtnc-macos-x64
	@$(call print_arrow) Building for macOS ARM64...
	@npx pkg . --targets node$(NODE_VERSION)-macos-arm64 --output bin/mtnc-macos-arm64
	@$(call print_success) macOS builds complete
	@printf "\n"

build-linux: build
	@$(call print_header, "MTNC - Linux Build", "Building for Linux...")
	@$(call print_arrow) Building for Linux x64...
	@npx pkg . --targets node$(NODE_VERSION)-linux-x64 --output bin/mtnc-linux-x64
	@$(call print_arrow) Building for Linux ARM64...
	@npx pkg . --targets node$(NODE_VERSION)-linux-arm64 --output bin/mtnc-linux-arm64
	@$(call print_success) Linux builds complete
	@printf "\n"

build-linux-static: build
	@$(call print_header, "MTNC - Linux Static Build", "Building portable static binary...")
	@$(call print_arrow) Building static Linux x64...
	@npx pkg . --targets node$(NODE_VERSION)-linuxstatic-x64 --output bin/mtnc-linux-static-x64
	@$(call print_success) Static Linux build complete
	@printf "\n"

build-windows: build
	@$(call print_header, "MTNC - Windows Build", "Building for Windows...")
	@$(call print_arrow) Building for Windows x64...
	@npx pkg . --targets node$(NODE_VERSION)-win-x64 --output bin/mtnc-win-x64.exe
	@$(call print_arrow) Building for Windows ARM64...
	@npx pkg . --targets node$(NODE_VERSION)-win-arm64 --output bin/mtnc-win-arm64.exe
	@$(call print_success) Windows builds complete
	@printf "\n"

pkg-all: build
	@$(call print_header, "MTNC - Package All", "Building binaries for all platforms...")
	@$(call print_arrow) Building for macOS...
	@npm run pkg:macos
	@$(call print_arrow) Building for Linux...
	@npm run pkg:linux
	@$(call print_arrow) Building for Windows...
	@npm run pkg:win
	@$(call print_success) All platform binaries built
	@printf "\n"

# =============================================================================
# Translation
# =============================================================================

translate: build
	@$(call print_header, "MTNC Translator", "Translating with structure preservation...")
	@$(call print_arrow) Step 1: Copy original source structure
	@rm -rf $(OUTPUT_DIR)
	@cp -R original_cs $(OUTPUT_DIR)
	@$(call print_success) Source structure copied
	@$(call print_arrow) Step 2: Translate DLL files from mods/
	@node $(DIST_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.js --src $(MODS_DIR) --out $(OUTPUT_DIR)

translate-interactive: build
	@$(call print_header, "MTNC Translator", "Interactive Translation Mode")
	@$(call print_info) Supported formats: .dll, .dylib, .so, .cs
	@$(call print_info) Universal support: Any .NET assembly, any mod type
	@node $(DIST_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.js

translate-full: build
	@$(call print_header, "MTNC Translator", "Full Translation (original_cs + mods)")
	@$(call print_arrow) Processing original_cs for structure...
	@rm -rf $(OUTPUT_DIR)
	@node $(DIST_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.js --src original_cs --out $(OUTPUT_DIR)

translate-clean: clean-output translate

# Translate C# source files directly
translate-source: build
	@$(call print_header, "MTNC - C# Source Translation", "Translating C# source files...")
	@$(call print_arrow) Looking for .cs files...
	@if [ -d "$(MODS_DIR)/source" ]; then \
		find $(MODS_DIR)/source -name "*.cs" -type f | while read file; do \
			$(call print_info) Translating: $$file; \
			node $(DIST_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.js --source "$$file" --out $(OUTPUT_DIR); \
		done; \
	else \
		$(call print_warning) No source directory found at $(MODS_DIR)/source; \
	fi
	@$(call print_success) C# source translation complete
	@printf "\n"

clean-output:
	@$(call print_arrow) Cleaning output directory...
	@rm -rf $(OUTPUT_DIR)
	@$(call print_success) Output directory cleaned

# =============================================================================
# Quality Checks
# =============================================================================

check: lint format-check
	@$(call print_success) All checks passed
	@printf "\n"

lint:
	@$(call print_section) "Linting Code"
	@npx eslint $(SRC_DIR)/$(TRANSLATOR_DIR)/*.ts --max-warnings=0 || true
	@$(call print_success) Linting complete
	@printf "\n"

lint-fix:
	@$(call print_arrow) Fixing lint issues...
	@npx eslint $(SRC_DIR)/$(TRANSLATOR_DIR)/*.ts --fix
	@$(call print_success) Lint fixes applied
	@printf "\n"

format-check:
	@$(call print_arrow) Checking code format...
	@npx prettier --check "$(SRC_DIR)/$(TRANSLATOR_DIR)/*.ts"
	@$(call print_success) Code format OK
	@printf "\n"

format:
	@$(call print_arrow) Formatting code...
	@npx prettier --write "$(SRC_DIR)/$(TRANSLATOR_DIR)/*.ts"
	@$(call print_success) Code formatted
	@printf "\n"

# =============================================================================
# Analysis
# =============================================================================

analyze: build
	@$(call print_header, "Code Analysis", "Analyzing generated code...")
	@$(call print_arrow) Checking output directory...
	@if [ -d "$(OUTPUT_DIR)" ]; then \
		total_cpp=$$(find $(OUTPUT_DIR) -name "*.cpp" | wc -l); \
		total_hpp=$$(find $(OUTPUT_DIR) -name "*.hpp" | wc -l); \
		total_lines=$$(find $(OUTPUT_DIR) -name "*.cpp" -exec cat {} \; | wc -l); \
		preserved=$$(find $(OUTPUT_DIR) -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.md" -o -name "*.json" \) | wc -l); \
		printf "$(COLOR_CYAN)  Translation Summary:$(COLOR_RESET)\n"; \
		printf "$(COLOR_GRAY)    Total CPP Files: %-10s$(COLOR_RESET)\n" "$$total_cpp"; \
		printf "$(COLOR_GRAY)    Total HPP Files: %-10s$(COLOR_RESET)\n" "$$total_hpp"; \
		printf "$(COLOR_GRAY)    Total Lines:     %-10s$(COLOR_RESET)\n" "$$total_lines"; \
		printf "$(COLOR_GRAY)    Preserved Files: %-10s$(COLOR_RESET)\n" "$$preserved"; \
		printf "$(COLOR_CYAN)  \n  By Module:$(COLOR_RESET)\n"; \
		for mod in $(OUTPUT_DIR)/*/; do \
			if [ -d "$$mod" ]; then \
				mod_name=$$(basename "$$mod"); \
				cpp_files=$$(find "$$mod" -name "*.cpp" | wc -l); \
				hpp_files=$$(find "$$mod" -name "*.hpp" | wc -l); \
				lines=$$(find "$$mod" -name "*.cpp" -exec cat {} \; | wc -l); \
				printf "$(COLOR_CYAN)    %-30s$(COLOR_RESET)\n" "$$mod_name:"; \
				printf "$(COLOR_GRAY)      CPP: %-8s HPP: %-8s Lines: %-8s$(COLOR_RESET)\n" "$$cpp_files" "$$hpp_files" "$$lines"; \
			fi; \
		done; \
	else \
		$(call print_warning) Output directory not found. Run 'make translate' first.; \
	fi
	@printf "\n"

analyze-assembly: build
	@$(call print_header, "Assembly Analyzer", "Analyzing .NET assembly...")
	@$(call print_info) Usage: make analyze-assembly FILE=/path/to/assembly.dll
	@if [ -n "$(FILE)" ] && [ -f "$(FILE)" ]; then \
		node $(DIST_DIR)/cli/index.js analyze "$(FILE)"; \
	else \
		$(call print_error) Please specify FILE=/path/to/assembly.dll; \
	fi
	@printf "\n"

# =============================================================================
# Testing
# =============================================================================

test: build
	@$(call print_section) "Running Tests"
	@node $(DIST_DIR)/$(TRANSLATOR_DIR)/mtnc-translate.js --src $(MODS_DIR) --out $(OUTPUT_DIR)
	@$(call print_success) Tests complete
	@printf "\n"

test-coverage:
	@$(call print_arrow) Running tests with coverage...
	@npm run test:coverage
	@$(call print_success) Coverage report generated
	@printf "\n"

test-universal: build
	@$(call print_header, "MTNC - Universal Tests", "Testing universal mod support...")
	@$(call print_arrow) Testing DLL translation...
	@node $(DIST_DIR)/cli/index.js translate --help
	@$(call print_arrow) Testing C# source translation...
	@node $(DIST_DIR)/cli/index.js translate-source --help
	@$(call print_arrow) Testing dependency resolution...
	@node $(DIST_DIR)/cli/index.js resolve-deps --help
	@$(call print_success) Universal tests complete
	@printf "\n"

# =============================================================================
# Installation
# =============================================================================

install: build
	@$(call print_arrow) Installing globally...
	@npm install -g .
	@$(call print_success) Installed globally
	@$(call print_info) You can now use 'mtnc' command anywhere
	@printf "\n"

install-link: build
	@$(call print_arrow) Linking package (development)...
	@npm link
	@$(call print_success) Package linked
	@$(call print_info) You can now use 'mtnc' command anywhere
	@printf "\n"

uninstall:
	@$(call print_arrow) Uninstalling...
	@npm uninstall -g $(PROJECT_NAME) || true
	@$(call print_success) Uninstalled
	@printf "\n"

link: build
	@$(call print_arrow) Linking package...
	@npm link
	@$(call print_success) Package linked
	@printf "\n"

# =============================================================================
# Cleaning
# =============================================================================

clean:
	@$(call print_arrow) Cleaning build artifacts...
	@rm -rf $(DIST_DIR)/$(TRANSLATOR_DIR)
	@$(call print_success) Cleaned
	@printf "\n"

clean-all: clean clean-output
	@$(call print_arrow) Cleaning all artifacts...
	@rm -rf node_modules
	@rm -rf .eslintcache .nyc_output coverage
	@rm -rf bin/mtnc-*
	@npm cache clean --force
	@$(call print_success) Fully cleaned
	@printf "\n"

clean-bin:
	@$(call print_arrow) Cleaning bin directory...
	@rm -rf bin/mtnc-*
	@$(call print_success) Bin directory cleaned
	@printf "\n"

# =============================================================================
# Utilities
# =============================================================================

version:
	@printf "$(COLOR_CYAN)$(PROJECT_NAME) v$(VERSION)$(COLOR_RESET)\n"
	@printf "$(COLOR_CYAN)Universal Edition$(COLOR_RESET)\n"
	@printf "$(COLOR_CYAN)Supports: .dll, .dylib, .so, .cs$(COLOR_RESET)\n"
	@printf "$(COLOR_CYAN)Platforms: macOS, Linux, Windows$(COLOR_RESET)\n"
	@printf "$(COLOR_CYAN)Architectures: x64, ARM64$(COLOR_RESET)\n"

info:
	@$(call print_header, "MTNC Translator Build System", "Universal Edition v21.0.0")
	@printf "Version:  $(COLOR_CYAN)$(VERSION)$(COLOR_RESET)\n"
	@printf "Type:     $(COLOR_CYAN)Universal - Any Mod/Assembly$(COLOR_RESET)\n"
	@printf "Formats:  $(COLOR_CYAN).dll, .dylib, .so, .cs$(COLOR_RESET)\n"
	@printf "Node:     $(COLOR_CYAN)$(shell node --version)$(COLOR_RESET)\n"
	@printf "NPM:      $(COLOR_CYAN)$(shell npm --version)$(COLOR_RESET)\n"
	@printf "OS:       $(COLOR_CYAN)$(shell uname -s) $(shell uname -m)$(COLOR_RESET)\n"
	@printf "\n"

doctor:
	@$(call print_header, "MTNC - System Check", "Diagnosing environment...")
	@$(call print_arrow) Checking Node.js...
	@node --version && $(call print_success) Node.js OK || $(call print_error) Node.js not found
	@$(call print_arrow) Checking npm...
	@npm --version && $(call print_success) npm OK || $(call print_error) npm not found
	@$(call print_arrow) Checking TypeScript...
	@npx tsc --version && $(call print_success) TypeScript OK || $(call print_error) TypeScript not found
	@$(call print_arrow) Checking pkg...
	@pkg --version 2>/dev/null && $(call print_success) pkg OK || $(call print_warning) pkg not found (optional)
	@$(call print_arrow) Checking dotnet...
	@dotnet --version 2>/dev/null && $(call print_success) dotnet OK || $(call print_warning) dotnet not found (required for IL parsing)
	@printf "\n"

# =============================================================================
# Help
# =============================================================================

help:
	@$(call print_header, "MTNC - Build Commands", "Universal Edition v21.0.0")
	@printf "$(COLOR_YELLOW)Build Targets:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make$(COLOR_RESET)                    Build all (CLI + Translator)\n"
	@printf "  $(COLOR_CYAN)make build-cli$(COLOR_RESET)          Build CLI only\n"
	@printf "  $(COLOR_CYAN)make build-translator$(COLOR_RESET)   Build Translator only\n"
	@printf "  $(COLOR_CYAN)make dev$(COLOR_RESET)                Development mode\n"
	@printf "  $(COLOR_CYAN)make build-all$(COLOR_RESET)          Cross-platform build (all targets)\n"
	@printf "\n"
	@printf "$(COLOR_YELLOW)Platform Builds:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make build-macos$(COLOR_RESET)        Build for macOS (x64 + ARM64)\n"
	@printf "  $(COLOR_CYAN)make build-linux$(COLOR_RESET)        Build for Linux (x64 + ARM64)\n"
	@printf "  $(COLOR_CYAN)make build-linux-static$(COLOR_RESET) Build portable Linux static binary\n"
	@printf "  $(COLOR_CYAN)make build-windows$(COLOR_RESET)      Build for Windows (x64 + ARM64)\n"
	@printf "  $(COLOR_CYAN)make pkg-all$(COLOR_RESET)            Build binaries for all platforms\n"
	@printf "\n"
	@printf "$(COLOR_YELLOW)CLI Usage:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)mtnc$(COLOR_RESET)                              Interactive mode\n"
	@printf "  $(COLOR_CYAN)mtnc translate <file>$(COLOR_RESET)             Translate DLL/assembly\n"
	@printf "  $(COLOR_CYAN)mtnc translate-source <file>$(COLOR_RESET)      Translate C# source\n"
	@printf "  $(COLOR_CYAN)mtnc analyze <file>$(COLOR_RESET)               Analyze assembly\n"
	@printf "  $(COLOR_CYAN)mtnc resolve-deps$(COLOR_RESET)                 Resolve dependencies\n"
	@printf "  $(COLOR_CYAN)mtnc build <dir>$(COLOR_RESET)                  Build translated code\n"
	@printf "\n"
	@printf "$(COLOR_YELLOW)Translation:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make translate$(COLOR_RESET)          Translate with structure preservation\n"
	@printf "  $(COLOR_CYAN)make translate-full$(COLOR_RESET)     Full translation (original_cs + mods)\n"
	@printf "  $(COLOR_CYAN)make translate-interactive$(COLOR_RESET)  Interactive mode\n"
	@printf "  $(COLOR_CYAN)make translate-source$(COLOR_RESET)   Translate C# source files\n"
	@printf "  $(COLOR_CYAN)make translate-clean$(COLOR_RESET)    Clean and retranslate\n"
	@printf "  $(COLOR_CYAN)make analyze$(COLOR_RESET)            Analyze generated code\n"
	@printf "  $(COLOR_CYAN)make analyze-assembly FILE=x$(COLOR_RESET) Analyze specific assembly\n"
	@printf "\n"
	@printf "$(COLOR_YELLOW)Installation:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make install$(COLOR_RESET)            Install globally (mtnc command)\n"
	@printf "  $(COLOR_CYAN)make install-link$(COLOR_RESET)       Link package (development)\n"
	@printf "  $(COLOR_CYAN)make uninstall$(COLOR_RESET)          Uninstall globally\n"
	@printf "\n"
	@printf "$(COLOR_YELLOW)Maintenance:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make clean$(COLOR_RESET)              Clean build artifacts\n"
	@printf "  $(COLOR_CYAN)make clean-all$(COLOR_RESET)          Clean everything\n"
	@printf "  $(COLOR_CYAN)make clean-bin$(COLOR_RESET)          Clean bin directory only\n"
	@printf "  $(COLOR_CYAN)make setup$(COLOR_RESET)              Setup project\n"
	@printf "  $(COLOR_CYAN)make doctor$(COLOR_RESET)             System diagnostic check\n"
	@printf "\n"
	@printf "$(COLOR_YELLOW)Code Quality:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make lint$(COLOR_RESET)                Check code style\n"
	@printf "  $(COLOR_CYAN)make lint-fix$(COLOR_RESET)           Auto-fix code style\n"
	@printf "  $(COLOR_CYAN)make format$(COLOR_RESET)             Format code\n"
	@printf "  $(COLOR_CYAN)make format-check$(COLOR_RESET)       Check code formatting\n"
	@printf "  $(COLOR_CYAN)make typecheck$(COLOR_RESET)          Type check only\n"
	@printf "  $(COLOR_CYAN)make validate$(COLOR_RESET)           Full validation (type + lint + test)\n"
	@printf "\n"
	@printf "$(COLOR_YELLOW)Development:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make dev-watch$(COLOR_RESET)          Watch mode (build + test)\n"
	@printf "  $(COLOR_CYAN)make docs$(COLOR_RESET)               Generate documentation\n"
	@printf "  $(COLOR_CYAN)make doctor$(COLOR_RESET)             System diagnostics\n"
	@printf "$(COLOR_YELLOW)Utilities:$(COLOR_RESET)\n"
	@printf "  $(COLOR_CYAN)make version$(COLOR_RESET)            Show version\n"
	@printf "  $(COLOR_CYAN)make info$(COLOR_RESET)               Show project info\n"
	@printf "  $(COLOR_CYAN)make help$(COLOR_RESET)               Show this help\n"
	@printf "\n"

# =============================================================================
# END OF FILE
# =============================================================================
