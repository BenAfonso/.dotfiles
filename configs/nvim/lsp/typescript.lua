---@type vim.lsp.Config
return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
  },
  settings = {
    -- init_options = {
    --   preferences = {
    --     -- importModuleSpecifierPreference = 'relative',
    --     -- importModuleSpecifierEnding = 'minimal',
    --   }
    -- }
  }
}
