return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },

  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup()

    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",
        "cssls",
        "marksman",
      },
      automatic_installation = false,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        { "shellcheck" },
        { "shfmt" },
        -- Lua
        { "stylua" },
        -- Go
        { "gopls" },
        -- Web
        { "prettier" },
        { "eslint_d" },
        -- { "vtsls" },
        { "typescript-language-server" },
        { "tailwindcss-language-server" },
        { "css-lsp" },
        { "svelte-language-server" },
        { "astro-language-server" },
      },
      automatic_installation = false,
      auto_update = true,
      run_on_start = true,
      start_delay = 3000, -- 3 second delay
      debounce_hours = 5, -- at least 5 hours between attempts to install/update
    })
  end,
}
