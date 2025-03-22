local Catppuccin = {
  "catppuccin/nvim",
  lazy = false,
  priority = 1000,
  lualine_key = "catppuccin",
  config = function()
    local palette = require("catppuccin.palettes").get_palette("mocha")

    require("catppuccin").setup({
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      -- flavour = "auto" -- will respect terminal's background
      background = {     -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
      term_colors = false,            -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = false,              -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15,            -- percentage of the shade to apply to the inactive window
      },
      no_italic = false,              -- Force no italic
      no_bold = false,                -- Force no bold
      no_underline = false,           -- Force no underline
      styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" },      -- Change the style of comments
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
      custom_highlights = {
        CmdBlue = { bg = "NONE", fg = palette.blue },
        CmdText = { bg = palette.blue, fg = "#000000" },
        CmdYellow = { bg = "NONE", fg = palette.yellow },
        SearchDownText = { fg = "#000000", bg = palette.yellow },
        CmdOrange = { bg = "NONE", fg = palette.peach },
        SearchUpText = { fg = "#000000", bg = palette.peach },
        CmdViolet = { bg = "NONE", fg = palette.mauve },
        LuaText = { bg = palette.mauve, fg = "#000000" },
        CmdGreen = { bg = "NONE", fg = palette.green },
        CalculateText = { fg = "#000000", bg = palette.green },
        DiffviewDiffDelete = { link = "NeogitDiffDeleteHighlight" },
        TelescopeBorder = { fg = "#ff33b8" },
        TelescopeMatching = { fg = "#ff33b8", bold = true },
        TelescopeSelection = { bg = "#361e3f" },
        TelescopeSelectionCaret = { bg = "#361e3f", fg = "#ff33b8" },
        TelescopeMultiSelection = { fg = "#ff33b8" },
        TelescopeMultiIcon = { fg = "#ff33b8" },
        SnacksPickerBorder = { fg = "#ff33b8" },
        SnacksPickerMatching = { fg = "#ff33b8", bold = true },
        SnacksPickerSelection = { bg = "#361e3f" },
        SnacksPickerSelectionCaret = { bg = "#361e3f", fg = "#ff33b8" },
        SnacksPickerMultiSelection = { fg = "#ff33b8" },
        SnacksPickerMultiIcon = { fg = "#ff33b8" },
      },
      default_integrations = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        neogit = true,
        diffview = true,
        nvimtree = true,
        treesitter = true,
        neotree = true,
        neotest = true,
        harpoon = true,
        telescope = {
          enabled = true,
          -- style = "nvchad",
        },
        -- lsp_trouble = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
      },
    })

    -- vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "#ff33b8", bold = true })

    -- vim.cmd.hi("Substitute guibg=" .. colors.yellow2 .. " guifg=#000000")

    -- setup must be called before loading
    vim.cmd.colorscheme("catppuccin")

    -- Diffview

    -- vim.cmd.hi("TreesitterContextLineNumber guibg=" .. "#0b253a")
    -- vim.cmd.hi("TreesitterContext guibg=" .. "#0b253a")
  end,
}

local TokyoNight = {
  "folke/tokyonight.nvim",
  enabled = true,
  lazy = false,    -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  opts = {
    on_highlights = function(hl, c)
      hl.TelescopeBorder = { fg = "#ff33b8" }
      hl.TelescopeBorder = { fg = "#ff33b8" }
      hl.TelescopeMatching = { fg = "#ff33b8", bold = true }
      hl.TelescopeSelection = { bg = "#361e3f" }
      hl.TelescopeSelectionCaret = { bg = "#361e3f", fg = "#ff33b8" }
      hl.TelescopeMultiSelection = { fg = "#ff33b8" }
      hl.TelescopeMultiIcon = { fg = "#ff33b8" }
    end,
  },
  -- config = function(_, opts)
  --   -- Load the colorscheme here
  --   vim.cmd.colorscheme("tokyonight-night")
  --
  --
  --
  --
  --   -- You can configure highlights by doing something like
  --   vim.cmd.hi("Comment gui=none")
  -- end,
}

-- local Eldritch = {
--   "eldritch-theme/eldritch.nvim",
--   enabled = true,
--   lazy = false, -- make sure we load this during startup if it is your main colorscheme
--   priority = 1000, -- make sure to load this before all the other start plugins
--   opts = {},
-- }

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

      vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#ff33b8" })
      vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "#ff33b8", bold = true })
      vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#361e3f" })
      vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { bg = "#361e3f", fg = "#ff33b8" })
      vim.api.nvim_set_hl(0, "TelescopeMultiSelection", { fg = "#ff33b8" })
      vim.api.nvim_set_hl(0, "TelescopeMultiIcon", { fg = "#ff33b8" })

      vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = "#ff33b8" })
      vim.api.nvim_set_hl(0, "SnacksPickerMatching", { fg = "#ff33b8", bold = true })
      vim.api.nvim_set_hl(0, "SnacksPickerSelection", { bg = "#361e3f" })
      vim.api.nvim_set_hl(0, "SnacksPickerSelectionCaret", { bg = "#361e3f", fg = "#ff33b8" })
      vim.api.nvim_set_hl(0, "SnacksPickerMultiSelection", { fg = "#ff33b8" })
      vim.api.nvim_set_hl(0, "SnacksPickerMultiIcon", { fg = "#ff33b8" })

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

local Kanagawa = {
  "rebelot/kanagawa.nvim",
  opts = {
    compile = false,  -- enable compiling the colorscheme
    undercurl = true, -- enable undercurls
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true },
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,   -- do not set background color
    dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
    terminalColors = true, -- define vim.g.terminal_color_{0,17}
    colors = {             -- add/modify theme and palette colors
      palette = {},
      theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors) -- add/modify highlights
      return {}
    end,
    theme = "wave",  -- Load "wave" theme when 'background' option is not set
    background = {   -- map the value of 'background' option to a theme
      dark = "wave", -- try "dragon" !
      light = "lotus",
    },
  },
}

local themes = {
  -- Kanagawa,
  -- NightOwl,
  Catppuccin,
  -- TokyoNight,
}

return themes
