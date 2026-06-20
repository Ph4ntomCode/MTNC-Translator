import pluginJs from '@eslint/js';
import tsPlugin from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';
import pluginJest from 'eslint-plugin-jest';
import pluginPrettierRecommended from 'eslint-plugin-prettier/recommended';
import globals from 'globals';

const tsFiles = ['**/*.ts'];
const testFiles = ['**/*.test.ts', 'tests/**/*.ts'];
const sourceFiles = ['**/*.{js,mjs,cjs}', ...tsFiles];
const unsafeRules = {
  '@typescript-eslint/no-unsafe-argument': 'warn',
  '@typescript-eslint/no-unsafe-assignment': 'warn',
  '@typescript-eslint/no-unsafe-call': 'warn',
  '@typescript-eslint/no-unsafe-member-access': 'warn',
  '@typescript-eslint/no-unsafe-return': 'warn'
};

export const createConfig = ({ strictUnsafe = false } = {}) => [
  {
    ignores: ['dist/', 'coverage/', 'node_modules/']
  },
  pluginJs.configs.recommended,
  {
    files: sourceFiles,
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.jest
      },
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module'
      }
    }
  },
  {
    files: tsFiles,
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: './tsconfig.json'
      }
    },
    plugins: {
      '@typescript-eslint': tsPlugin
    },
    rules: {
      ...tsPlugin.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
      'no-undef': 'off',
      'no-case-declarations': 'warn',
      'no-fallthrough': 'warn',
      'no-useless-escape': 'warn',
      'no-constant-condition': 'off',
      '@typescript-eslint/prefer-ts-expect-error': 'warn',
      ...(strictUnsafe
        ? unsafeRules
        : Object.fromEntries(Object.keys(unsafeRules).map((rule) => [rule, 'off'])))
    }
  },
  {
    files: testFiles,
    plugins: {
      jest: pluginJest
    },
    rules: {
      ...pluginJest.configs.recommended.rules
    }
  },
  pluginPrettierRecommended
];

export default createConfig();
