return {
  cmd = { "astro-ls", "--stdio" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  filetypes = {
    'astro',
  },
  init_options = {
    typescript = {
      tsdk = "node_modules/typescript/lib",
    }
  }
}
