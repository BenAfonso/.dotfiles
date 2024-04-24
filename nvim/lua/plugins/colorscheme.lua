local Catppuccin = {
  "catppuccin/nvim",
  lazy = false,
  priority = 1000,
  lualine_key = "catppuccin",
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      -- flavour = "auto" -- will respect terminal's background
      background = { -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
      term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
      },
      no_italic = false, -- Force no italic
      no_bold = false, -- Force no bold
      no_underline = false, -- Force no underline
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      color_overrides = {},
      custom_highlights = {},
      default_integrations = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        neotree = true,
        neotest = true,
        harpoon = true,
        telescope = {
          enabled = true,
        },
        lsp_trouble = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
      },
    })

    -- vim.cmd.hi("Substitute guibg=" .. colors.yellow2 .. " guifg=#000000")

    -- setup must be called before loading
    vim.cmd.colorscheme("catppuccin")

    -- vim.cmd.hi("TreesitterContextLineNumber guibg=" .. "#0b253a")
    -- vim.cmd.hi("TreesitterContext guibg=" .. "#0b253a")
    -- vim.cmd.hi("TelescopeMatching guifg=" .. "#ff33b8")
  end,
}

local TokyoNight = {
  "folke/tokyonight.nvim",
  enabled = false,
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- Load the colorscheme here
    vim.cmd.colorscheme("tokyonight-night")

    -- You can configure highlights by doing something like
    vim.cmd.hi("Comment gui=none")
  end,
}

local NightOwl = {
  {
    "oxfist/night-owl.nvim",
    lualine_key = "night-owl",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("night-owl")

      local colors = require("night-owl.palette")

      -- vim.cmd.hi("Substitute guibg=#ff2c83 guifg=#000000")

      -- vim.cmd.hi("TreesitterContextBottom gui=underline guisp=Grey")
      vim.cmd.hi("Substitute guibg=" .. colors.yellow2 .. " guifg=#000000")
      vim.cmd.hi("TreesitterContextLineNumber guibg=" .. "#0b253a")
      vim.cmd.hi("TreesitterContext guibg=" .. "#0b253a")
      vim.cmd.hi("TelescopeMatching guifg=" .. "#ff33b8")

      -- Enable transparent background
      -- vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
      -- vim.api.nvim_set_hl(0, "NonText", { bg = "NONE", ctermbg = "NONE" })

      -- vim.api.nvim_set_hl(0, "@variable.object", { fg = "#ffffff", bg = "NONE" })
      -- vim.api.nvim_set_hl(0, "@field", { fg = "#ffffff", bg = "#ff0000" })
      -- vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = colors.cyan2, bg = "NONE" })
      -- vim.api.nvim_set_hl(0, "@property", { fg = colors.cyan2, bg = "NONE" })

      -- vim.cmd.hi("Substitute guibg=#ffffff" guifg="")

      vim.cmd.hi("DiffAdd guifg=", "0", "guibg=#203832")
      vim.cmd.hi("DiffDelete guifg=#a3383a guibg=#58232a")
      vim.cmd.hi("DiffChange guifg=#668052 guibg=#314a3b")
      vim.cmd.hi("DiffText guifg=0 guibg=#314a3b")
    end,
  },
}

local Theme = Catppuccin

return {
  Theme,
}
