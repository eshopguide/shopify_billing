import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// // https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    lib: {
      entry: "src/index.js", // Entry file for your library
      name: "shopify-billing", // The name of the library
      fileName: (format) => `shopify-billing.${format}.js`, // Output file name pattern
    },
    rollupOptions: {
      external: ["react", "react-dom", "react/jsx-runtime", "react-i18next"],
      output: {
        globals: {
          react: "React",
          "react-dom": "ReactDOM",
        },
      },
    },
  },
});
