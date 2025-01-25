-- TODO:  HELLO
local M = {
  "folke/zen-mode.nvim",
  dependencies = {
    "folke/twilight.nvim",
  },
  opts = {
    -- backdrop = 0.95,
    width = 100,
    plugins = {
      twilight = { enabled = false },
      tmux = { enabled = true },
    },
    wezterm = {
      enabled = true,
      font = 20,
    },
  },
}

return M
