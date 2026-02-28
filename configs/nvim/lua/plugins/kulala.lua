local M =
{
  "mistweaverco/kulala.nvim",
  keys =
  {
    { "<leader>Ks", desc = "Send request" },
    { "<leader>Ka", desc = "Send all requests" },
    { "<leader>Kb", desc = "Open scratchpad" },
  },
  ft = { "http", "rest" },
  opts =
  {
    --your configuration comes here global_keymaps = true,
  },
}

return M
