import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { resolve } from 'path'
import { readFile } from 'fs/promises'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  esbuild: {
    include: /\.(tsx?|jsx?)$/,
    exclude: [],
    loader: 'tsx'
  },
  optimizeDeps: {
    esbuildOptions: {
      plugins: [
        {
          name: "load-js-files-as-jsx",
          setup(build) {
            build.onLoad({ filter: /.*\.js$/ }, async (args) => {
              return({
                loader: "jsx",
                contents: await readFile(args.path, { encoding: "utf8" }),
              });
            });
          },
        },
      ],
    },
  },
  resolve: {
    alias: {
      '@lib': resolve(__dirname, 'app/frontend/lib'),
      '@images': resolve(__dirname, 'app/frontend/images'),
      'components': resolve(__dirname, 'app/frontend/components'),
    },
  },
})
