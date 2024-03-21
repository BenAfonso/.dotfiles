local M = {
  {
    enabled = true,
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      local home = vim.fn.expand("$HOME")
      local path = os.getenv("KEEPASS_FOLDER")
      require("chatgpt").setup({
        -- api_host_cmd = "echo http://127.0.0.1:4000",
        -- api_key_cmd = "echo DUMMY",
        api_key_cmd = "keepassxc-cli show "
          .. path
          .. "/terminal-secrets.kdbx gpt-neovim2 -a Password --no-password -k "
          .. home
          .. "/kp.keyx -s",
        -- api_host_cmd = "echo http://localhost:11434",
        -- api_key_cmd = "echo ''",
        -- openai_params = {
        --   model = "mistral",
        --   frequency_penalty = 0,
        --   presence_penalty = 0,
        --   max_tokens = 300,
        --   temperature = 0,
        --   top_p = 1,
        --   n = 1,
        -- },
        -- openai_edit_params = {
        --   model = "mistral",
        --   frequency_penalty = 0,
        --   presence_penalty = 0,
        --   temperature = 0,
        --   top_p = 1,
        --   n = 1,
        -- },
      })
      -- require("chatgpt").setup({
      --   api_key_cmd = "keepassxc-cli show "
      --     .. path
      --     .. "/terminal-secrets.kdbx gpt-baptiste -a Password --no-password -k "
      --     .. home
      --     .. "/kp.keyx -s",
      -- })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}

return M
