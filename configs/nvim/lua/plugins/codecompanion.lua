-- This file has been commented by an AI tool
-- This file configures the 'codecompanion.nvim' plugin for Neovim,
-- allowing integration with OpenAI's API for chat and inline functionalities.

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
        adapter = "openai", -- Specify using OpenAI API
      },
      -- Define a strategy for inline commands
      inline = {
        adapter = "openai", -- Specify using OpenAI API
      },
    },
    adapters = {
      -- Adapter setup for OpenAI integration
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          schema = {
            model = {
              default = "gpt-4o-mini",
            },
          },
          env = {
            api_key = "cmd:gpt-key", -- API key retrieval command
          },
        })
      end,
    },
  },
}
