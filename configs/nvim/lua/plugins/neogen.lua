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
  end,
}
