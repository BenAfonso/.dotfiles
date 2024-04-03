local M = {
  {
    enabled = true,
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "folke/noice.nvim",
    },
    event = "VeryLazy",
    opts = {
    },
    config = function(_, opts)
      opts.options = {
        theme = require("plugins.colorscheme")[1].lualine_key
      }
      opts.sections = {
        lualine_x = {
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            color = { fg = "#ff9e64" },
          },
        },
      }
      require("lualine").setup(opts)
    end,
  },
  {
    "folke/noice.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)
      vim.diagnostic.config({
        signs = true,
        underline = true,
        virtual_text = false,
        virtual_lines = false,
        update_in_insert = true,
        float = {
          -- UI.
          header = false,
          border = "rounded",
          focusable = true,
        },
      })
    end,
    -- add any options here
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },

  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      max_height = 5,
      max_width = 50,
      background_colour = "#1e222a",
    },
    keys = {
      {
        "<Esc>",
        function()
          local notify = require("notify")
          notify.dismiss({})
        end,
        desc = "Clear notification",
      },
    },
  },
  -- buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
    },
    opts = {
      options = {
        mode = "tabs",
        -- separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },
}

return M
