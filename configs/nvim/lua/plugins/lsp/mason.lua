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
      automatic_installation = true,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        { "stylua" },
        { "shellcheck" },
        { "shfmt" },
        -- { "vtsls" },
        { "typescript-language-server" },
        { "tailwindcss-language-server" },
        { "css-lsp" },
        { "gopls" },
        { "eslint_d" },
        { "prettier" },
        { "svelte-language-server" },
      },
      auto_update = true,
      run_on_start = true,
      start_delay = 3000, -- 3 second delay
      debounce_hours = 5, -- at least 5 hours between attempts to install/update
    })
  end,
}
