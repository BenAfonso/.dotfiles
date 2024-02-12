local M = {
  -- tools
  {
    "folke/lsp-colors.nvim",
    config = function()
      require("lsp-colors").setup()
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "gopls",
        "eslint-lsp",
        -- "quick-lint-js",
      })
    end,
  },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      servers = {
        cssls = {},
        gopls = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        eslint = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
        -- quick_lint_js = {
        --   filetypes = {
        --     "javascript",
        --     "javascriptreact",
        --     "typescript",
        --     "typescriptreact",
        --   },
        --   root_pattern = { ".git" },
        -- },
        tsserver = {
          commands = {
            RenameFile = {
              require("utils.ts-rename"),
              description = "Rename File",
            },
          },
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          single_file_support = true,
          settings = {
            --   typescript = {
            --     inlayHints = {
            --       includeInlayParameterNameHints = "literal",
            --       includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            --       includeInlayFunctionParameterTypeHints = true,
            --       includeInlayVariableTypeHints = false,
            --       includeInlayPropertyDeclarationTypeHints = true,
            --       includeInlayFunctionLikeReturnTypeHints = true,
            --       includeInlayEnumMemberValueHints = true,
            --     },
            --   },
            --   javascript = {
            --     inlayHints = {
            --       includeInlayParameterNameHints = "all",
            --       includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            --       includeInlayFunctionParameterTypeHints = true,
            --       includeInlayVariableTypeHints = true,
            --       includeInlayPropertyDeclarationTypeHints = true,
            --       includeInlayFunctionLikeReturnTypeHints = true,
            --       includeInlayEnumMemberValueHints = true,
            --     },
            --   },
          },
        },
        html = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        lua_ls = {
          -- enabled = false,
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      setup = {},
    },
  },
}

return M
