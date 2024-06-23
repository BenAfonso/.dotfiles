local M = {
  "smjonas/inc-rename.nvim",
  opts = {},
  config = function(_, opts)
    require("inc_rename").setup(opts)

    vim.keymap.set("n", "<leader>cr", function()
      return ":IncRename " .. vim.fn.expand("<cword>")
    end, { desc = "Rename", expr = true })
  end,
}

return M
