local M = {
  "S1M0N38/love2d.nvim",
  cmd = "LoveRun",
  opts = {
    path_to_love_bin = os.getenv("LOVE2D_PATH"),
    restart_on_save = false,
    -- path_to_love_bin = "/home/ben/love/love-11.5-x86_64.AppImage",
  },
  keys = {
    { "<leader>v", desc = "LÖVE" },
    { "<leader>vv", "<cmd>LoveRun<cr>", desc = "Run LÖVE" },
    { "<leader>vs", "<cmd>LoveStop<cr>", desc = "Stop LÖVE" },
  },
}

return M
