local M = {
  {
    "oxfist/night-owl.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("night-owl")

      local colors = require("night-owl.palette")

      -- vim.cmd.hi("Substitute guibg=#ff2c83 guifg=#000000")
      vim.cmd.hi("Substitute guibg=" .. colors.yellow2 .. " guifg=#000000")

      -- vim.cmd.hi("Substitute guibg=#ffffff" guifg="")

      vim.cmd.hi("DiffAdd guifg=", "0", "guibg=#203832")
      vim.cmd.hi("DiffDelete guifg=#a3383a guibg=#58232a")
      vim.cmd.hi("DiffChange guifg=#668052 guibg=#314a3b")
      vim.cmd.hi("DiffText guifg=0 guibg=#314a3b")
    end,
  },
}

return M
