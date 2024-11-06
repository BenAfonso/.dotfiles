return {
  "danymat/neogen",
  version = "*",
  config = function(opts)
    require("neogen").setup({
      snippet_engine = "luasnip",
      languages = {
        typescript = {
          template = {
            annotation_convention = "jsdoc",
          },
        },
      },
    })

    vim.keymap.set(
      "n",
      "<leader>cg",
      ":lua require('neogen').generate()<CR>",
      { noremap = true, silent = true, desc = "Generate comment" }
    )
  end,
}
