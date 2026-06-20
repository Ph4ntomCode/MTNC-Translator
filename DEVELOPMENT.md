# Development Guide

## Getting Started

### Prerequisites

- Node.js 20+
- TypeScript 5.x
- .NET SDK 7.0+ (for ILParser)

### Installation

```bash
npm install
npm run build
```

### Development Workflow

#### Building

```bash
npm run build         # Build once
npm run build:watch   # Watch mode (automatic rebuild)
npm run typecheck     # Type check without emitting
```

#### Testing

```bash
npm test              # Run all tests
npm test:watch        # Watch mode
npm test:coverage     # Generate coverage report
```

#### Linting & Formatting

```bash
npm run lint          # Check for linting issues
npm run lint:fix      # Auto-fix linting issues
npm run format        # Auto-format code
npm run format:check  # Check formatting without changes
```

#### Validation

```bash
npm run validate      # Run type check + lint + tests (pre-commit)
```

## Project Structure

```
src/
├── cli/              # Command-line interface
├── cmds/             # Individual CLI commands
├── config/           # Configuration management
├── translator/       # Core translation logic
├── ui/               # User interface utilities
├── utils/            # Shared utilities
└── tools/            # External tools (ILParser, etc.)

tests/                # Test files
dist/                 # Compiled output
```

## Code Quality Standards

### Type Safety

- **Strict Mode Enabled**: All TypeScript strict options are enabled
- **No Implicit Any**: Use explicit types for all variables
- **Null Checks**: Always check for null/undefined before use

### Error Handling

```typescript
// ✅ Good - Proper error handling with type narrowing
try {
  const result = await translator.translate(path);
  if (result.success) {
    console.log(result.stats);
  } else {
    console.error(`Translation failed: ${result.error}`);
  }
} catch (error) {
  if (error instanceof Error) {
    console.error(error.message);
  } else {
    console.error('Unknown error occurred');
  }
}

// ❌ Bad - Unsafe error handling
try {
  const result = await translator.translate(path);
  console.log(result.stats); // result might not have stats!
} catch (e: any) {
  // Don't use 'any'
  console.error(e);
}
```

### Documentation

All public APIs must have JSDoc comments:

````typescript
/**
 * Translates a C# assembly to C++ IL2CPP code
 *
 * @param assemblyPath - Path to the .NET assembly file
 * @param options - Translation options
 * @returns Translation result with either success or failure details
 *
 * @example
 * ```typescript
 * const result = await translator.translate('./MyAssembly.dll', {
 *   outputDir: './output',
 *   optimize: true
 * });
 * ```
 */
export async function translate(assemblyPath: string, options?: TranslationOptions): Promise<TranslationResult>;
````

## Common Tasks

### Adding a New Feature

1. Create feature branch: `git checkout -b feature/my-feature`
2. Write tests first (TDD approach)
3. Implement feature with proper types
4. Run validation: `npm run validate`
5. Create pull request

### Debugging

```bash
# Enable verbose logging
node dist/cli/index.js translate --verbose

# Use Node debugger
node --inspect-brk dist/cli/index.js translate path/to/assembly.dll
# Then open chrome://inspect in Chrome
```

### Performance Profiling

```bash
# Generate flame graph
node --prof dist/cli/index.js translate path/to/assembly.dll
node --prof-process isolate-0x...-.log > processed.txt
```

## Tips & Tricks

### Fast Builds

- Use `npm run build:watch` during development
- TypeScript will cache compilation results
- Only changed files are recompiled

### Faster Tests

- Run specific test: `npm test -- filename.test.ts`
- Use test.only() for focused testing
- Increase timeout for slow tests: `jest.setTimeout(10000)`

### VS Code Integration

Add to `.vscode/settings.json`:

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

## Troubleshooting

### "Cannot find module" errors

```bash
npm install
npm run build
```

### Port already in use

Find and kill the process:

```bash
lsof -i :3000  # Replace with your port
kill -9 <PID>
```

### Out of memory during build

Increase Node heap size:

```bash
NODE_OPTIONS="--max-old-space-size=4096" npm run build
```

## CI/CD Pipeline

The repository uses GitHub Actions for:

- Automated testing on every push
- Linting checks
- Type checking
- Code coverage reporting
- Multi-platform binary builds

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [ESLint Documentation](https://eslint.org/docs/)
- [Jest Testing Guide](https://jestjs.io/docs/getting-started)
- [MTNC Translator Docs](./docs/)
