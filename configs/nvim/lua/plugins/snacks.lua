-- TODO: Configure
-- https://github.com/folke/snacks.nvim?tab=readme-ov-file
local M = {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- animate = { enabled = false },
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    -- lazygit = {
    --   configure = true,
    --   -- extra configuration for lazygit that will be merged with the default
    --   -- snacks does NOT have a full yaml parser, so if you need `"test"` to appear with the quotes
    --   -- you need to double quote it: `"\"test\""`
    --   config = {
    --     os = { editPreset = "nvim-remote" },
    --     gui = {
    --       -- set to an empty string "" to disable icons
    --       nerdFontsVersion = "3",
    --     },
    --   },
    -- },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      }
    }
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>go",      function() Snacks.lazygit() end,      desc = "Open Lazygit" },
  }
}

return M
