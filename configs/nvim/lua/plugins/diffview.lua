local M = {
  "sindrets/diffview.nvim",
  dependencies = {},
  opts = {
    keymaps = {
      view = {
        ["<tab>"] = false,
        ["<s-tab>"] = false,
      },
      file_panel = {
        ["<tab>"] = false,
        ["<s-tab>"] = false,
      },
      file_history_panel = {
        ["<tab>"] = false,
        ["<s-tab>"] = false,
      },
    },
  },
  config = function(_, opts)
    require("diffview").setup(opts)
    vim.opt.fillchars = vim.opt.fillchars + "diff:╱"
  end,
}

return M
