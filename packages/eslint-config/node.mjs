import globals from 'globals';
import baseConfig from './base.mjs';

const nodeConfig = [
  ...baseConfig,
  {
    files: ['**/*.ts'],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
  },
];

export default nodeConfig;
