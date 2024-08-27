return {
  "folke/lazydev.nvim",
  dependencies = {
    { "Bilal2453/luvit-meta", lazy = true },
  },
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      "${3rd}/luv/library",
      { path = "LazyVim", words = { "LazyVim" } },
      -- vim.env.VIMRUNTIME,
      "~/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
      -- { path = "luvit-meta/library", words = { "vim%.uv" } },
    },
  },
}
