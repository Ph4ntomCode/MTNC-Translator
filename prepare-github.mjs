#!/usr/bin/env node

/**
 * Copy project files to github folder for clean upload
 * Excludes: node_modules, dist, build artifacts, temporary files
 */

import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SOURCE_DIR = path.resolve(__dirname);
const DEST_DIR = path.join(SOURCE_DIR, 'github');

// Patterns to exclude
const EXCLUDE_PATTERNS = [
  'node_modules',
  'dist',
  'mtnc-output',
  'bin',
  '.qwen',
  '.qodo',
  'coverage',
  '.git',
  '.github/workflows',
  '*.log',
  '*.tmp',
  '*.bak',
  '.DS_Store',
  '*.zip',
  'Json130r4',
  'Json130r4.zip',
  'github', // Don't copy github folder into itself
];

// Files/dirs to explicitly include
const INCLUDE_PATTERNS = [
  'src/**/*',
  'scripts/**/*',
  'mods/**/*',
  'framework/**/*',
  'config/**/*',
  'docs/**/*',
  'examples/**/*',
  'tests/**/*',
  'plugins/**/*',
  'assets/**/*',
  '.vscode/**/*',
  'package.json',
  'package-lock.json',
  'tsconfig.json',
  '*.md',
  '*.sh',
  '*.js',
  '*.mjs',
  '*.json',
  '*.ts',
  '*.hpp',
  '*.h',
  '*.cpp',
  '.editorconfig',
  '.eslintrc.json',
  '.gitattributes',
  '.gitignore',
  '.prettierrc',
  '.prettierrc.json',
  'eslint.config.mjs',
  'eslint.strict.config.mjs',
  'jest.config.js',
  'LICENSE',
  'mtnc-config.example.json',
  'prism_mod_api.hpp',
];

console.log('╔══════════════════════════════════════════════════════════╗');
console.log('║  MTNC Translator - Preparing GitHub Upload              ║');
console.log('║  Copying files with verification...                     ║');
console.log('╚══════════════════════════════════════════════════════════╝');
console.log('');

// Create destination
console.log('📁 Creating destination directory...');
if (fs.existsSync(DEST_DIR)) {
  fs.removeSync(DEST_DIR);
}
fs.ensureDirSync(DEST_DIR);

// Copy function with filtering
function shouldExclude(filePath) {
  const relativePath = path.relative(SOURCE_DIR, filePath);
  
  for (const pattern of EXCLUDE_PATTERNS) {
    if (pattern.includes('**')) {
      // Glob pattern
      const regex = new RegExp(pattern.replace(/\*\*/g, '.*').replace(/\*/g, '[^/]*'));
      if (regex.test(relativePath)) {
        return true;
      }
    } else if (pattern.includes('*')) {
      // Simple wildcard
      const regex = new RegExp(pattern.replace(/\*/g, '.*'));
      if (regex.test(relativePath) || regex.test(path.basename(filePath))) {
        return true;
      }
    } else {
      // Exact match or directory
      if (relativePath === pattern || relativePath.startsWith(pattern + '/') || path.basename(filePath) === pattern) {
        return true;
      }
    }
  }
  return false;
}

function copyFile(src, dest) {
  try {
    fs.copySync(src, dest);
    return true;
  } catch (error) {
    console.error(`  ✗ Failed to copy: ${path.relative(SOURCE_DIR, src)}`);
    return false;
  }
}

function copyDirectory(srcDir, destDir) {
  let fileCount = 0;
  
  if (!fs.existsSync(srcDir)) {
    return fileCount;
  }
  
  const entries = fs.readdirSync(srcDir, { withFileTypes: true });
  
  for (const entry of entries) {
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(destDir, entry.name);
    
    // Skip excluded paths
    if (shouldExclude(srcPath)) {
      continue;
    }
    
    if (entry.isDirectory()) {
      fs.ensureDirSync(destPath);
      fileCount += copyDirectory(srcPath, destPath);
    } else {
      if (copyFile(srcPath, destPath)) {
        fileCount++;
      }
    }
  }
  
  return fileCount;
}

// Copy root level files first
console.log('📋 Copying root level files...');
let totalFiles = 0;

const rootEntries = fs.readdirSync(SOURCE_DIR, { withFileTypes: true });
for (const entry of rootEntries) {
  if (shouldExclude(path.join(SOURCE_DIR, entry.name))) {
    continue;
  }
  
  const srcPath = path.join(SOURCE_DIR, entry.name);
  const destPath = path.join(DEST_DIR, entry.name);
  
  if (entry.isDirectory()) {
    fs.ensureDirSync(destPath);
    totalFiles += copyDirectory(srcPath, destPath);
    console.log(`  ✓ Directory: ${entry.name}`);
  } else {
    if (copyFile(srcPath, destPath)) {
      totalFiles++;
      console.log(`  ✓ File: ${entry.name}`);
    }
  }
}

// Also copy specific directories
const dirsToCopy = ['src', 'scripts', 'mods', 'framework', 'config', 'docs', 'examples', 'tests', 'plugins', 'assets', '.vscode'];
for (const dir of dirsToCopy) {
  const srcPath = path.join(SOURCE_DIR, dir);
  const destPath = path.join(DEST_DIR, dir);
  
  if (fs.existsSync(srcPath) && !fs.existsSync(destPath)) {
    fs.ensureDirSync(destPath);
    totalFiles += copyDirectory(srcPath, destPath);
    console.log(`  ✓ Directory: ${dir}`);
  }
}

console.log('');
console.log(`✅ Copy complete! Total files: ${totalFiles}`);
console.log('');

// Verify copied files
console.log('🔍 Verifying copied files...');
console.log('');

const stats = fs.statSync(DEST_DIR);
const dirCount = fs.readdirSync(DEST_DIR, { withFileTypes: true }).filter(e => e.isDirectory()).length;
const fileCount = fs.readdirSync(DEST_DIR, { withFileTypes: true }).filter(e => e.isFile()).length;

console.log('📊 Statistics:');
console.log(`  - Files copied: ${totalFiles}`);
console.log(`  - Top-level directories: ${dirCount}`);
console.log(`  - Top-level files: ${fileCount}`);
console.log('');

// Verify critical files exist
console.log('🔍 Verifying critical files...');
const CRITICAL_FILES = [
  'package.json',
  'tsconfig.json',
  'README.md',
  'src/index.ts',
  'src/translator/mtnc-translate.ts',
  'src/utils/file-utils.ts',
  'src/utils/graceful-shutdown.ts',
  'src/utils/input-validation.ts',
  'src/translator/type-guards.ts',
  'src/translator/cache.ts',
  'scripts/download-dependencies.js',
  'mods/build-all.sh',
  'mods/test-all-mods.sh',
];

let allPresent = true;
for (const file of CRITICAL_FILES) {
  const filePath = path.join(DEST_DIR, file);
  if (fs.existsSync(filePath)) {
    console.log(`  ✓ ${file}`);
  } else {
    console.log(`  ✗ ${file} MISSING!`);
    allPresent = false;
  }
}

console.log('');

if (allPresent) {
  console.log('✅ All critical files verified!');
} else {
  console.log('❌ Some critical files are missing!');
  process.exit(1);
}

console.log('');
console.log('╔══════════════════════════════════════════════════════════╗');
console.log('║  ✓ GitHub folder ready for upload!                      ║');
console.log('║                                                          ║');
console.log(`║  Location: ${DEST_DIR}`);
console.log('╚══════════════════════════════════════════════════════════╝');
