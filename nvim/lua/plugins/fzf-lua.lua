local M = {
  "ibhagwan/fzf-lua",
  enabled = false,
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- calling `setup` is optional for customization
    local fzf = require("fzf-lua")
    fzf.setup({})
    vim.keymap.set("n", "<C-\\>", function()
      require("fzf-lua").buffers()
    end)
  end,
}
return M
