return {
  enabled = true,
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      search = {
        enabled = true,
        highlight = {
          backdrop = true,
        },
      },
      char = {
        enabled = true,
      },
    },
  },
  keys = {
    -- { 's', mode = { 'n' }, false },
    -- { 'S', mode = { 'n', 'x', 'o' }, false },
    -- { 'f', mode = { 'n', 'x', 'o' }, false },
    -- { ';', mode = { 'n' }, false },
  },
}
