import { defineConfig } from 'vitest/config';
import { resolve } from 'path';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./test/setup.ts'],
    include: ['**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
    exclude: ['node_modules', 'dist', '.next'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'test/',
        'dist/',
        '.next/',
        '**/*.d.ts',
        '**/*.config.{js,ts}',
        '**/index.{js,ts}',
      ],
    },
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, '.'),
      '@/lib': resolve(__dirname, 'lib'),
      '@/components': resolve(__dirname, 'components'),
      '@/app': resolve(__dirname, 'app'),
    },
  },
});
