#!/usr/bin/env node

/**
 * Copy ONLY essential files to github folder for GitHub upload
 * Excludes: node_modules, dist, docs (outdated), test-assets, build artifacts
 */

import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SOURCE_DIR = path.resolve(__dirname);
const DEST_DIR = path.join(SOURCE_DIR, 'github');

// Patterns to EXCLUDE (not copied)
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
  'github',
  'test-input',
  'docs',  // Outdated docs - will be recreated
  'assets/test-assets',  // Test assets not needed
];

console.log('╔══════════════════════════════════════════════════════════╗');
console.log('║  MTNC Translator - Preparing GitHub Upload              ║');
console.log('║  Version: 0.0.1-pre-alpha                               ║');
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
      const regex = new RegExp(pattern.replace(/\*\*/g, '.*').replace(/\*/g, '[^/]*'));
      if (regex.test(relativePath)) return true;
    } else if (pattern.includes('*')) {
      const regex = new RegExp(pattern.replace(/\*/g, '.*'));
      if (regex.test(relativePath) || regex.test(path.basename(filePath))) return true;
    } else {
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
    console.error(`  ✗ Failed: ${path.relative(SOURCE_DIR, src)}`);
    return false;
  }
}

function copyDirectory(srcDir, destDir) {
  let fileCount = 0;
  if (!fs.existsSync(srcDir)) return fileCount;
  
  const entries = fs.readdirSync(srcDir, { withFileTypes: true });
  
  for (const entry of entries) {
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(destDir, entry.name);
    
    if (shouldExclude(srcPath)) continue;
    
    if (entry.isDirectory()) {
      fs.ensureDirSync(destPath);
      fileCount += copyDirectory(srcPath, destPath);
    } else {
      if (copyFile(srcPath, destPath)) fileCount++;
    }
  }
  
  return fileCount;
}

// Copy root level files
console.log('📋 Copying essential files...');
let totalFiles = 0;

const rootEntries = fs.readdirSync(SOURCE_DIR, { withFileTypes: true });
for (const entry of rootEntries) {
  if (shouldExclude(path.join(SOURCE_DIR, entry.name))) continue;
  
  const srcPath = path.join(SOURCE_DIR, entry.name);
  const destPath = path.join(DEST_DIR, entry.name);
  
  if (entry.isDirectory()) {
    fs.ensureDirSync(destPath);
    totalFiles += copyDirectory(srcPath, destPath);
    console.log(`  ✓ ${entry.name}/`);
  } else {
    if (copyFile(srcPath, destPath)) {
      totalFiles++;
    }
  }
}

console.log('');
console.log(`✅ Copy complete: ${totalFiles} files`);
console.log('');

// Verify critical files
console.log('🔍 Verifying critical files...');
const CRITICAL_FILES = [
  'package.json',
  'tsconfig.json',
  'README.md',
  'LICENSE',
  'src/index.ts',
  'src/cli/index.ts',
  'src/translator/mtnc-translate.ts',
  'setup-build.sh',
  'setup-build.ps1',
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

if (!allPresent) {
  console.log('❌ Some critical files are missing!');
  process.exit(1);
}

console.log('╔══════════════════════════════════════════════════════════╗');
console.log('║  ✓ GitHub folder ready!                                 ║');
console.log(`║  Location: ${DEST_DIR}`);
console.log('╚══════════════════════════════════════════════════════════╝');
