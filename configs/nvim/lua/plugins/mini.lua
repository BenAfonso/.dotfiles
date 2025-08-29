-- Collection of various small independent plugins/modules
local M = {
  {
    "echasnovski/mini.icons",
  },
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.diff").setup()
      require("mini.icons").setup()
      -- require('mini.surround').setup()
    end,
  }
}

return M
