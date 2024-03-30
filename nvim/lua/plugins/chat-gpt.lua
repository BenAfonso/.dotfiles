local M = {
  {
    enabled = true,
    'jackMort/ChatGPT.nvim',
    event = 'VeryLazy',
    config = function()
      local home = vim.fn.expand '$HOME'
      local path = os.getenv 'KEEPASS_FOLDER'
      require('chatgpt').setup {
        -- api_host_cmd = "echo http://127.0.0.1:4000",
        -- api_key_cmd = "echo DUMMY",
        api_key_cmd = 'keepassxc-cli show ' .. path .. '/terminal-secrets.kdbx gpt-neovim2 -a Password --no-password -k ' .. home .. '/kp.keyx -s',
      }
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
}

return M
