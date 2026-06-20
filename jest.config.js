export default {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  moduleFileExtensions: ['ts', 'js', 'json'],
  collectCoverageFrom: ['src/**/*.ts', '!src/**/*.d.ts', '!src/**/*.test.ts', '!src/demo.ts', '!src/index.ts'],
  coverageThreshold: {
    global: {
      branches: 60,
      functions: 60,
      lines: 60,
      statements: 60,
    },
  },
  moduleNameMapper: {
    '^(.*)\\.js$': '$1',
    '^@translator/(.*)$': '<rootDir>/src/translator/$1',
    '^@cli/(.*)$': '<rootDir>/src/cli/$1',
    '^@cmds/(.*)$': '<rootDir>/src/cmds/$1',
    '^@config/(.*)$': '<rootDir>/src/config/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  testTimeout: 120000,
  verbose: true,
  coverageReporters: ['text', 'text-summary', 'html', 'lcov'],
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      useESM: true,
      tsconfig: {
        target: 'ES2022',
        module: 'ES2022',
        esModuleInterop: true,
        allowSyntheticDefaultImports: true,
      },
    }],
  },
  transformIgnorePatterns: [
    'node_modules/(?!(chalk|cli-progress|cli-cursor)/)',
  ],
};
