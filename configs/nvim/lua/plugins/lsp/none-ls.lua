return {
  "nvimtools/none-ls.nvim",
  opts = {},
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.completion.spell,
        -- require("none-ls.diagnostics.eslint"), -- requires none-ls-extras.nvim
      },
    })

    local ts_actions = {
      method = null_ls.methods.CODE_ACTION,
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      generator = {
        fn = function()
          return {
            {
              title = "Fix all",
              action = vim.cmd.TSToolsFixAll,
            },
            {
              title = "Remove unused imports",
              action = vim.cmd.TSToolsRemoveUnusedImports,
            },
            {
              title = "Organize imports",
              action = vim.cmd.TSToolsOrganizeImports,
            },
            {
              title = "Add Missing Imports",
              action = vim.cmd.TSToolsAddMissingImports,
            },
          }
        end,
      },
    }

    local no_really = {
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = { "markdown", "text" },
      generator = {
        fn = function(params)
          local diagnostics = {}
          -- sources have access to a params object
          -- containing info about the current file and editor state
          for i, line in ipairs(params.content) do
            local col, end_col = line:find("really")
            if col and end_col then
              -- null-ls fills in undefined positions
              -- and converts source diagnostics into the required format
              table.insert(diagnostics, {
                row = i,
                col = col,
                end_col = end_col + 1,
                source = "no-really",
                message = "Don't use 'really!'",
                severity = vim.diagnostic.severity.WARN,
              })
            end
          end
          return diagnostics
        end,
      },
    }

    null_ls.register(no_really)
    null_ls.register(ts_actions)
  end,
}
