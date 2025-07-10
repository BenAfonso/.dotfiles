local M = {
  "code-biscuits/nvim-biscuits",
  enabled = false,
  config = function()
    require("nvim-biscuits").setup({
      cursor_line_only = true,
      show_on_start = true
    })
  end
}

return M
