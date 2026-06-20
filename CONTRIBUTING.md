# Contributing to MTNC Translator

Thank you for your interest in contributing to MTNC Translator! This document provides guidelines and instructions for contributing.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Questions?](#questions)

---

## 🤝 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Keep discussions professional and on-topic

---

## 🚀 Getting Started

### 1. Fork the Repository

```bash
# Click "Fork" on GitHub to create your own copy
```

### 2. Clone Your Fork

```bash
git clone https://github.com/YOUR_USERNAME/mtnc.git
cd mtnc
```

### 3. Set Up Development Environment

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Run tests
npm test
```

---

## 💻 Development Setup

### Prerequisites

- Node.js 20.0.0 or higher
- npm 9.0.0 or higher
- Git
- Code editor (VS Code recommended)

### Recommended Extensions

- ESLint
- Prettier
- TypeScript
- GitLens

---

## 🔧 Making Changes

### 1. Create a Branch

```bash
# Always branch from main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Follow coding standards (see below)
- Write tests for new features
- Update documentation as needed
- Keep commits focused and atomic

### 3. Commit Changes

```bash
# Stage changes
git add .

# Commit with clear message
git commit -m "feat: add new feature description"
```

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build/config changes

**Examples:**
```
feat(translator): add enhanced type mapping
fix(cli): resolve dependency resolution issue
docs(readme): update installation instructions
refactor(core): improve error handling
test(unit): add tests for type mapper
```

---

## 📤 Pull Request Process

### 1. Update Your Branch

```bash
git fetch origin
git rebase origin/main
```

### 2. Run Tests

```bash
# Run all tests
npm test

# Run linting
npm run lint

# Optional: enable strict no-unsafe-* checks
npm run lint:strict

# Build project
npm run build
```

### 3. Create Pull Request

1. Push your branch: `git push origin feature/your-feature-name`
2. Go to GitHub and create PR
3. Fill out PR template
4. Wait for review

### PR Requirements

- ✅ All tests pass
- ✅ Default linting passes (`npm run lint`)
- ✅ Build succeeds
- ✅ Code follows standards
- ✅ Documentation updated
- ✅ Tests added for new features

---

## 📝 Coding Standards

### TypeScript

```typescript
// Use meaningful variable names
const translationResult = await translator.translate(dllPath);

// Use type annotations
function translateType(typeName: string): TypeMappingResult {
  // Implementation
}

// Handle errors properly
try {
  await translateFile(path);
} catch (error) {
  logger.error(`Failed to translate: ${error.message}`);
  throw error;
}

// Use async/await
async function processTranslation(): Promise<void> {
  const result = await translator.translate('file.dll');
  // Process result
}
```

### Code Organization

```typescript
// 1. Imports (grouped)
import fs from 'fs-extra';
import * as path from 'path';

// 2. Interfaces/Types
export interface TranslationOptions {
  outputDir: string;
  verbose?: boolean;
}

// 3. Constants
const DEFAULT_OUTPUT_DIR = './output';

// 4. Classes
export class Translator {
  // Implementation
}

// 5. Functions
export function translateFile(path: string): void {
  // Implementation
}
```

### Error Handling

```typescript
// Use enhanced error handler
import { errorHandler, ErrorCodes } from './error-handler.js';

try {
  // Translation code
} catch (error) {
  errorHandler.error(
    ErrorCodes.T001,
    error.message,
    { file: path, line: lineNumber }
  );
  throw error;
}
```

### Type Mapping

```typescript
// Use enhanced type mapping
import { enhancedTypeMapping } from './enhanced-type-mapping.js';

const mapping = enhancedTypeMapping.getTypeMapping('System.String');
console.log(mapping.cppType); // Il2CppString*
```

---

## 🧪 Testing

### Running Tests

```bash
# All tests
npm test

# Specific test file
npm test -- tests/unit/type-mapper.test.ts

# With coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

### Writing Tests

```typescript
import { enhancedTypeMapping } from '../../src/translator/enhanced-type-mapping.js';

describe('EnhancedTypeMapping', () => {
  describe('getTypeMapping', () => {
    it('should map primitive types correctly', () => {
      const result = enhancedTypeMapping.getTypeMapping('System.Int32');
      expect(result.cppType).toBe('int32_t');
      expect(result.confidence).toBe('exact');
    });

    it('should map Unity types correctly', () => {
      const result = enhancedTypeMapping.getTypeMapping('UnityEngine.Vector3');
      expect(result.cppType).toBe('UnityEngine::Vector3');
      expect(result.includes).toContain('unity-helpers.hpp');
    });
  });
});
```

### Test Coverage Goals

- Unit Tests: >80% coverage
- Integration Tests: Critical paths covered
- E2E Tests: Main workflows covered

---

## 📚 Documentation

### Updating Documentation

- Update README.md for user-facing changes
- Update docs/ for detailed guides
- Add JSDoc comments for public APIs
- Include examples where helpful

### Documentation Standards

```markdown
# Clear Title

Brief description of what this is.

## Usage

```typescript
// Code example
const result = await translator.translate('file.dll');
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `verbose` | boolean | `false` | Enable verbose logging |

## Examples

### Basic Example

```typescript
// Example code
```

### Advanced Example

```typescript
// More complex example
```
```

---

## ❓ Questions?

### Getting Help

- **Documentation**: Check [docs/](docs/)
- **Issues**: Search [GitHub Issues](https://github.com/mtnc-translator/mtnc/issues)
- **Discussions**: Ask in [GitHub Discussions](https://github.com/mtnc-translator/mtnc/discussions)
- **Email**: dev@mtnc.dev

### Common Issues

**Build fails:**
```bash
npm run clean
npm install
npm run build
```

**Tests fail:**
```bash
rm -rf node_modules
npm install
npm test
```

**Lint errors:**
```bash
npm run lint:fix
npm run format
```

---

## 🎯 Areas for Contribution

### High Priority

1. **Type Safety** - Reduce `any` types
2. **Test Coverage** - Add more tests
3. **Performance** - Optimize translation speed
4. **Documentation** - Improve guides

### Medium Priority

5. **Error Messages** - Make more helpful
6. **Type Mappings** - Add more types
7. **Build System** - Improve CMake/Make
8. **Examples** - Add more examples

### Low Priority

9. **Code Cleanup** - Refactor old code
10. **CI/CD** - Improve pipelines
11. **Plugins** - Add plugin system
12. **Tools** - Add developer tools

---

## 🏆 Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- Annual contributor highlights

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to MTNC Translator!** 🎉

**Made with ❤️ by the MTNC Development Team**
