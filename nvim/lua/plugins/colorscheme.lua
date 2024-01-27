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

      -- vim.cmd.hi("TreesitterContextBottom gui=underline guisp=Grey")
      vim.cmd.hi("TreesitterContextLineNumber guibg=" .. "#0b253a")
      vim.cmd.hi("TreesitterContext guibg=" .. "#0b253a")
      -- vim.api.nvim_set_hl(0, "@variable.object", { fg = "#ffffff", bg = "NONE" })
      -- vim.api.nvim_set_hl(0, "@field", { fg = "#ffffff", bg = "#ff0000" })
      -- vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = colors.cyan2, bg = "NONE" })
      -- vim.api.nvim_set_hl(0, "@property", { fg = colors.cyan2, bg = "NONE" })

      -- vim.cmd.hi("Substitute guibg=#ffffff" guifg="")

      vim.cmd.hi("DiffAdd guifg=", "0", "guibg=#203832")
      vim.cmd.hi("DiffDelete guifg=#a3383a guibg=#58232a")
      vim.cmd.hi("DiffChange guifg=#668052 guibg=#314a3b")
      vim.cmd.hi("DiffText guifg=0 guibg=#314a3b")
    end,
  },
}

return M
