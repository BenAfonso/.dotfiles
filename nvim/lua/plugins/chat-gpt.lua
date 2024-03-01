local M = {
  {
    enabled = true,
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      local home = vim.fn.expand("$HOME")
      local path = os.getenv("KEEPASS_FOLDER")
      require("chatgpt").setup({
        api_key_cmd = "keepassxc-cli show "
          .. path
          .. "/terminal-secrets.kdbx gpt-baptiste -a Password --no-password -k "
          .. home
          .. "/kp.keyx -s",
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
