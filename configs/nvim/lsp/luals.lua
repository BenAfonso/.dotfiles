---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc' },
  settings = {
    Lua = {
      diagnostics = {
        disable = {
          'missing-parameter', -- disable diagnostics about whether all fields are filled
          'missing-fields',
          'unused-function',
        },
        globals = { 'vim', 'Snacks' }, -- recognize 'vim' global to language server
        undefined_global = false,
      },
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          vim.api.nvim_get_runtime_file('lua', true),
          "${3rd}/luv/library",
        }
      }
    },
  }
}
