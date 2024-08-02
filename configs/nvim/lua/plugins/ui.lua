local function count_items(qf_list)
  if #qf_list > 0 then
    local valid = 0
    for _, item in ipairs(qf_list) do
      if item.valid == 1 then
        valid = valid + 1
      end
    end
    if valid > 0 then
      return tostring(valid)
    end
  end
  return
end

local M = {
  {
    enabled = true,
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "folke/noice.nvim",
    },
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local colors = {
        blue = "#80a0ff",
        cyan = "#79dac8",
        black = "#080808",
        white = "#c6c6c6",
        red = "#ff5189",
        violet = "#d183e8",
        grey = "#303030",
      }

      local bubbles_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.violet, gui = "bold" },
          b = { fg = colors.white, bg = colors.grey, gui = "bold" },
          c = { fg = colors.white },
        },

        insert = { a = { fg = colors.black, bg = colors.blue, gui = "bold" } },
        visual = { a = { fg = colors.black, bg = colors.cyan, gui = "bold" } },
        replace = { a = { fg = colors.black, bg = colors.red, gui = "bold" } },

        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white },
        },
      }

      opts.options = {
        theme = bubbles_theme,
        component_separators = "",
        section_separators = { left = "", right = "" },
        -- fmt = string.lower,
      }
      opts.sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return str:sub(1, 1)
            end,
            separator = { left = "", right_padding = 2 },
          },
        },
        lualine_b = {
          { "branch" },
          {
            "diff",
            colored = true, -- Displays a colored diff status if set to true
            diff_color = {
              -- Same color values as the general color option can be used here.
              -- added = "GitSignsAdd",
              -- modified = "GitSignsChange",
              -- removed = "GitSignsDelete",
            },
            symbols = { added = "+", modified = "~", removed = "-" }, -- Changes the symbols used by the diff.
            source = nil,
          },
          {
            "diagnostics",

            -- Table of diagnostic sources, available sources are:
            --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
            sources = { "nvim_lsp", "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },

            -- diagnostics_color = {
            --   error = "DiagnosticError",
            --   warn = "DiagnosticWarn",
            --   info = "DiagnosticInfo",
            --   hint = "DiagnosticHint",
            -- },
            symbols = { error = "󰅙 ", warn = " ", info = " ", hint = "󰌵 " },
            colored = true, -- Displays diagnostics status in color if set to true.
            update_in_insert = false, -- Update diagnostics in insert mode.
            always_visible = false, -- Show diagnostics even if there are none.
          },
        },
        lualine_c = {
          {
            "quickfix",
          },
          {
            "filename",
            file_status = true, -- Displays file status (readonly status, modified status)
            newfile_status = true, -- Display new file status (new file means no write after created)
            path = 1,
            -- 0: Just the filename
            -- 1: Relative path
            -- 2: Absolute path
            -- 3: Absolute path, with tilde as the home directory
            -- 4: Filename and parent dir, with tilde as the home directory

            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
            -- for other components. (terrible name, any suggestions?)
            symbols = {
              modified = "[+]", -- Text to show when the file is modified.
              readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
              unnamed = "[No Name]", -- Text to show for unnamed buffers.
              newfile = "[New]", -- Text to show for newly created file before first write
            },
          },
        },
        lualine_x = {
          {
            require("noice").api.status.command.get,
            cond = require("noice").api.status.command.has,
            color = { fg = "#ff9e64" },
          },
          {
            function()
              local t = require("noice").api.status.mode.get()
              return t:gsub("recording ", "")
            end,
            cond = require("noice").api.status.mode.has,
            separator = { left = "", right_padding = 2 },
            color = { bg = "#ff9e64", fg = "#000000", gui = "bold" },
          },
          {
            require("noice").api.status.search.get,
            cond = require("noice").api.status.search.has,
            color = { fg = "#ff9e64" },
          },
        },
        lualine_y = {
          "filetype",
          "progress",
        },
        lualine_z = {
          { "location", separator = { right = "" }, left_padding = 2 },
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
