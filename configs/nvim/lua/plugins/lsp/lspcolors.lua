return {
  "folke/lsp-colors.nvim",
  opts = {},
  config = function(_, opts)
    require("lsp-colors").setup(opts)
  end,
}
