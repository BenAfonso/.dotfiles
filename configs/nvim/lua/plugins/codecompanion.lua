return {
  -- Define the main plugin to be loaded
  "olimorris/codecompanion.nvim",
  dependencies = {
    -- Essential dependency for many Neovim plugins
    "nvim-lua/plenary.nvim",

    -- Treesitter for syntax parsing and highlighting
    "nvim-treesitter/nvim-treesitter",

    -- Optional: Provides command-line completion capabilities
    "hrsh7th/nvim-cmp",

    -- Optional: Integrates with Telescope for enhanced searching
    "nvim-telescope/telescope.nvim",
    -- Optional: Enhances 'vim.ui.select' with a better UI
    { "stevearc/dressing.nvim", opts = {} },
  },
  event = "VeryLazy",
  -- Configuration options for the plugin
  opts = {
    display = {
      diff = {
        provider = "mini_diff",
      },
    },
    strategies = {
      -- Define a strategy for chat-based interactions
      chat = {
        adapter = "gemini",
      },
      -- Define a strategy for inline commands
      inline = {
        adapter = "gemini",
        keymaps = {
          accept_change = {
            modes = { n = "ga" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "gr" },
            description = "Reject the suggested change",
          },
        },
      },
    },
    adapters = {
      http = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-2.5-flash",
              },
            },
            env = {
              api_key =
              "cmd:gemini-key"
            },
          })
        end,
      }
    },
  },
}
