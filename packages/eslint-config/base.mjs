import js from '@eslint/js';
import eslintConfigPrettier from 'eslint-config-prettier';
import tseslint from 'typescript-eslint';

const baseConfig = tseslint.config(
  {
    ignores: [
      'dist/**',
      '.test-dist/**',
      'coverage/**',
      'node_modules/**',
    ],
  },

  js.configs.recommended,

  ...tseslint.configs.recommendedTypeChecked,

  eslintConfigPrettier,

  {
    files: ['**/*.ts'],

    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: process.cwd(),
      },
    },

    rules: {
      '@typescript-eslint/consistent-type-imports': [
        'error',
        {
          prefer: 'type-imports',
          fixStyle: 'inline-type-imports',
        },
      ],

      '@typescript-eslint/no-floating-promises': [
        'error',
        {
          allowForKnownSafeCalls: [
            {
              from: 'package',
              name: [
                'test',
                'it',
                'describe',
                'suite',
              ],
              package: 'node:test',
            },
          ],
        },
      ],

      '@typescript-eslint/no-misused-promises': 'error',

      '@typescript-eslint/switch-exhaustiveness-check': 'error',
    },
  },
);

export default baseConfig;
