---@type vim.lsp.Config
-- source.fixAll.ts - despite the name, fixes a couple of specific issues: unreachable code, await in non-async functions, incorrectly implemented interface
-- source.removeUnused.ts - removes declared but unused variables
-- source.addMissingImports.ts - adds imports for used but not imported symbols
-- source.removeUnusedImports.ts - removes unused imports
-- source.sortImports.ts - sorts imports
-- source.organizeImports.ts - organizes and removes unused imports

return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
  },
  on_attach = function()
    vim.api.nvim_create_user_command("TSOrganizeImports", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = {
            "source.organizeImports.ts",
          },
          diagnostics = {},
        },
      })
    end, {})
    vim.api.nvim_create_user_command("TSAddMissingImports", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = {
            "source.addMissingImports.ts",
          },
          diagnostics = {},
        },
      })
    end, {})
    vim.api.nvim_create_user_command("TSFixAll", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = {
            "source.fixAll.ts",
          },
          diagnostics = {},
        },
      })
    end, {})
    vim.api.nvim_create_user_command("TSRemoveUnused", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = {
            "source.removeUnused.ts",
          },
          diagnostics = {},
        },
      })
    end, {})
    vim.api.nvim_create_user_command("TSAddMissingImports", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = {
            "source.addMissingImports.ts",
          },
          diagnostics = {},
        },
      })
    end, {})
  end,
  settings = {
    init_options = {
      preferences = {
        completeFunctionCalls = false,
        -- importModuleSpecifierPreference = 'relative',
        -- importModuleSpecifierEnding = 'minimal',
      },
    },
  },
}
