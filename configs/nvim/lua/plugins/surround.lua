return {
  "kylechui/nvim-surround",
  enabled = true,
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      highlight = {},
      aliases = {},
      surrounds = {},
      move_cursor = "end",
      indent_lines = false,
    })
  end,
}
