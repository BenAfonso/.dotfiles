-- Highlight todo, notes, etc in comments
local M = {
  "folke/todo-comments.nvim",
  event = "VimEnter",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = { signs = false },
  config = function(_, opts)
    require("todo-comments").setup(opts)

    vim.api.nvim_create_user_command("Todo", "Trouble todo filter = { tag = { TODO } }", {})
  end
}

return M
