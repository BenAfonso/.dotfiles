local M = {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-jest",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest")({
            jestCommand = "npm test --",
            jestConfigFile = "custom.jest.config.ts",
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
        },
      })

      local neotest = require("neotest")

      vim.keymap.set("n", "<leader>ts", "<Cmd>Neotest summary<CR>", { desc = "[T]est [S]ummary" })

      vim.keymap.set("n", "<leader>tt", neotest.run.run, { desc = "[T]est nearest" })
      vim.keymap.set("n", "<leader>tf", function()
        neotest.run.run(vim.fn.expand("%"))
      end, { desc = "[T]est [F]ile" })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug Nearest",
      },
    },
  },
}

return M
