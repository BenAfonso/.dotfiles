return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })

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

      opts.presets.lsp_doc_border = true
    end,
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
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        -- globalstatus = false,
        theme = "night-owl",
      },
    },
  },
  {
    "b0o/incline.nvim",
    dependencies = { "oxfist/night-owl.nvim" },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local colors = require("night-owl.palette")
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = colors.tab_active_bg, guifg = colors.title },
            InclineNormalNC = { guibg = colors.tab_inactive_bg, guifg = colors.dark_white },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = {
          cursorline = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end

          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },
}
