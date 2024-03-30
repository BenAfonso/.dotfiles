return {
  "folke/trouble.nvim",
  branch = "dev",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>xe",
      "<cmd>Trouble diagnostics toggle filter.buf=0 filter.severity=vim.diagnostic.severity.ERROR<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>xE",
      "<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>xs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>xl",
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
    {
      "gR",
      function()
        require("trouble").toggle("lsp_references")
      end,
      { desc = "LSP [R]eferences" },
    },
    {
      "[q",
      function()
        if require("trouble").is_open() then
          require("trouble").previous({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      { desc = "Previous trouble/quickfix item" },
    },
    {
      "]q",
      function()
        if require("trouble").is_open() then
          require("trouble").next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      { desc = "Next trouble/quickfix item" },
    },
  },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
