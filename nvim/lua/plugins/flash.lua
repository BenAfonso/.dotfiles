return {
  enabled = true,
  "folke/flash.nvim",
  ---@type Flash.Config
  opts = {},
  keys = {
    { "s", mode = { "n" }, false },
    { "S", mode = { "n", "x", "o" }, false },
    { "f", mode = { "n", "x", "o" }, false },
    { ";", mode = { "n" }, false },
  },
}
