local M = {
  "nvim-pack/nvim-spectre",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function(opts)
    vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
      desc = "Toggle Spectre",
    })
    vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual({ select_word=true })<CR>', {
      desc = "[S]earch current [w]ord",
    })
    vim.keymap.set("n", "<leader>sr", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
      desc = "[S]earch (and [r]eplace) on current file",
    })
  end,
}

return M
