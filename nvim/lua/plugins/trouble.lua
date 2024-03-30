return {
  "folke/trouble.nvim",
  branch = "dev",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- vim.keymap.set("n", "<leader>xa", function()
    --   require("trouble").toggle()
    -- end)
    -- vim.keymap.set("n", "<leader>xw", function()
    --   require("trouble").toggle("workspace_diagnostics")
    -- end)
    -- vim.keymap.set("n", "<leader>xd", function()
    --   require("trouble").toggle("document_diagnostics")
    -- end)
    -- vim.keymap.set("n", "<leader>xq", function()
    --   require("trouble").toggle("quickfix")
    -- end)
    -- vim.keymap.set("n", "<leader>xl", function()
    --   require("trouble").toggle("loclist")
    -- end)
    -- vim.keymap.set("n", "gR", function()
    --   require("trouble").toggle("lsp_references")
    -- end)
    --
    -- -- Keymaps.lua
    -- vim.keymap.set("n", "<leader>xx", function()
    --   require("trouble").toggle("dia")
    -- end)
    -- vim.keymap.set("n", "<leader>xw", function()
    --   require("trouble").toggle("workspace_diagnostics")
    -- end)
    -- vim.keymap.set("n", "<leader>xs", function()
    --   require("trouble").toggle("symbols")
    -- end)
    -- vim.keymap.set("n", "<leader>xd", function()
    --   require("trouble").toggle("document_diagnostics")
    -- end)
    -- vim.keymap.set("n", "<leader>xq", function()
    --   require("trouble").toggle("quickfix")
    -- end)
    -- vim.keymap.set("n", "<leader>xl", function()
    --   require("trouble").toggle("loclist")
    -- end)
    -- vim.keymap.set("n", "gR", function()
    --   require("trouble").toggle("lsp_references")
    -- end)
  end,
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>xs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "gR",
      -- "<leader>xl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
