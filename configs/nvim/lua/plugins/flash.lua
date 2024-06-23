return {
  enabled = true,
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    { 's', mode = { 'n' }, false },
    { 'S', mode = { 'n', 'x', 'o' }, false },
    { 'f', mode = { 'n', 'x', 'o' }, false },
    { ';', mode = { 'n' }, false },
  },
}
