return {
  cmd = { "tailwindcss-language-server" },
  filetypes = {
    "html",
    "svelte",
    'typescriptreact',
    'javascriptreact',
    'astro',
  },
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#tailwindcss
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "tw" }
    }
  },
}
