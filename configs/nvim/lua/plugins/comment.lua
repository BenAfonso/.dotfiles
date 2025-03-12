-- "gc" to comment visual regions/lines
local M = {
  -- { "numToStr/Comment.nvim", opts = {} },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  }
}

return M
