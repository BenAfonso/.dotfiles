local M = {
  {
    enabled = false,
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      local home = vim.fn.expand("$HOME")
      -- local cmd = "echo $(pass show keepass-noha | keepassxc-cli show "
      --   .. home
      --   .. "/.keepass/keepass-noha.kdbx gpt-neovim2 -a Password -s -q)"

      require("chatgpt").setup({
        -- api_host_cmd = "echo http://127.0.0.1:4000",
        -- api_key_cmd = "echo DUMMY",
        api_key_cmd = "gpt-key",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}

return M
