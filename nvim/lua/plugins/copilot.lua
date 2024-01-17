local M = {
  -- {
  --   "github/copilot.vim",
  --   config = function(opts)
  --     vim.g.copilot_assume_mapped = true
  --   end,
  -- },
  { -- Sets up copilot.lua
    "zbirenbaum/copilot.lua",
    enabled = true,
    opts = {
      branch = "main",
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      copilot_node_command = vim.fn.expand("$HOME") .. "/.nvm/versions/node/v18.19.0/bin/node", -- Node.js version must be > 18.x
    },
  },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   enabled = false,
  --   dependencies = "copilot.lua",
  --   opts = {},
  --   config = function(_, opts)
  --     local copilot_cmp = require("copilot_cmp")
  --     copilot_cmp.setup(opts)
  --     -- attach cmp source whenever copilot attaches
  --     -- fixes lazy-loading issues with the copilot cmp source
  --     require("lazyvim.util").lsp.on_attach(function(client)
  --       if client.name == "copilot" then
  --         copilot_cmp._on_insert_enter({})
  --       end
  --     end)
  --   end,
  -- },
}

return M
