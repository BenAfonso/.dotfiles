local M = {
  {
    "catppuccin/nvim",
    lazy = false,
    enabled = true,
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
        transparent_background = true, -- disables setting the background color.
        show_end_of_buffer = false,    -- shows the '~' characters after the end of buffers
        term_colors = true,            -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = false,             -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15,           -- percentage of the shade to apply to the inactive window
        },
        no_italic = false,             -- Force no italic
        no_bold = false,               -- Force no bold
        no_underline = false,          -- Force no underline
        styles = {                     -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { "italic" },     -- Change the style of comments
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
          Dashboard = { fg = "#ff33b8", bold = true },
          TelescopeBorder = { fg = "#ff33b8" },
          TelescopeMatching = { fg = "#ff33b8", bold = true },
          TelescopeSelection = { bg = "#361e3f" },
          TelescopeSelectionCaret = { bg = "#361e3f", fg = "#ff33b8" },
          TelescopeMultiSelection = { fg = "#ff33b8" },
          TelescopeMultiIcon = { fg = "#ff33b8" },
          -- NormalFloat = { bg = palette.base, fg = palette.text },
          NormalFloat = { bg = "none", fg = palette.text },
          FidgetTitle = { bg = "#00ff00", fg = palette.text },
          FidgetTask = { bg = "#ff0000", fg = palette.text },
          FloatShadow = { bg = palette.base, blend = 100 },
          FloatShadowThrough = { bg = palette.base, blend = 100 },

          -- SnacksPickerBorder = { fg = "highlight_high", bg = "none" },
          SnacksNormal = { bg = "none" },
          SnacksPicker = { bg = "none" },
          SnacksPickerList = { bg = "none" },
          SnacksPickerInput = { bg = "none" },
          SnacksPickerBox = { bg = "none" },

          -- SnacksPickerBorder = { fg = "#ff33b8" },
          SnacksPickerMatching = { fg = "#ff33b8", bold = true },
          SnacksDashboardHeader = { fg = "#ff33b8", bold = true },
          -- SnacksPickerSelection = { bg = "#361e3f" },
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
          snacks = {
            enabled = true,
            indent_scope_color = "lavender",
          },
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
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = true,
    enabled = false,
    priority = 1000,
    opts = {
      variant = "default", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`
      -- Enable transparent background
      transparent = true,
      -- Reduce the overall saturation of colours for a more muted look
      saturation = 1, -- accepts a value between 0 and 1. 0 will be fully desaturated (greyscale) and 1 will be the full color (default)
      -- Enable italics comments
      italic_comments = true,
      -- Replace all fillchars with ' ' for the ultimate clean look
      hide_fillchars = false,
      -- Apply a modern borderless look to pickers like Telescope, Snacks Picker & Fzf-Lua
      borderless_pickers = false,
      -- Set terminal colors used in `:terminal`
      terminal_colors = true,
      -- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
      cache = true,
      -- Override highlight groups with your own colour values
      highlights = {
        -- See `:h highlight-groups` for a list of highlight groups or run `:hi` to see all groups and their current values
        -- Example:
        Comment = { fg = "#696969", bg = "NONE", italic = true },
        -- More examples can be found in `lua/cyberdream/extensions/*.lua`
      },
      -- Override a highlight group entirely using the built-in colour palette
      overrides = function(colors) -- NOTE: This function nullifies the `highlights` option
        -- Example:
        return {
          -- Comment = { fg = colors.green, bg = "NONE", italic = true },
          -- ["@property"] = { fg = colors.magenta, bold = true },
        }
      end,
      -- Override a color entirely
      colors = {
        -- For a list of colors see `lua/cyberdream/colours.lua`
        -- Example:
        -- bg = "#000000",
        -- green = "#00ff00",
        -- magenta = "#ff00ff",
      },
      -- Disable or enable colorscheme extensions
      extensions = {
        telescope = true,
        notify = true,
        mini = true,

      },
    },
    config = function(_, opts)
      require("cyberdream").setup(opts)

      vim.cmd.colorscheme("cyberdream")
    end
  },
  {
    "folke/tokyonight.nvim",
    enabled = true,
    lazy = true,     -- make sure we load this during startup if it is your main colorscheme
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
  },
  {
    "eldritch-theme/eldritch.nvim",
    enabled = true,
    lazy = true,     -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {},
  },
  {
    "oxfist/night-owl.nvim",
    lualine_key = "night-owl",
    lazy = true,
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
  {
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
  },
  {
    "rose-pine/neovim",
    lazy = true,
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        variant = "auto",      -- auto, main, moon, or dawn
        dark_variant = "main", -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
          migrations = true,        -- Handle deprecated options automatically
        },

        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },

        groups = {
          -- border = "muted",
          -- link = "iris",
          -- panel = "surface",
          --
          -- error = "love",
          -- hint = "iris",
          -- info = "foam",
          -- note = "pine",
          -- todo = "rose",
          -- warn = "gold",
          --
          -- git_add = "foam",
          -- git_change = "rose",
          -- git_delete = "love",
          -- git_dirty = "rose",
          -- git_ignore = "muted",
          -- git_merge = "iris",
          -- git_rename = "pine",
          -- git_stage = "iris",
          -- git_text = "rose",
          -- git_untracked = "subtle",
          --
          -- h1 = "iris",
          -- h2 = "foam",
          -- h3 = "rose",
          -- h4 = "gold",
          -- h5 = "pine",
          -- h6 = "foam",
        },

        palette = {
          -- Override the builtin palette per variant
          main = {
            base = '#18191a',
            overlay = '#363738',
          },
        },

        -- NOTE: Highlight groups are extended (merged) by default. Disable this
        -- per group via `inherit = false`
        highlight_groups = {
          StatusLine = { fg = "love", bg = "love", blend = 10 },
          StatusLineNC = { fg = "subtle", bg = "surface" },

          TelescopeBorder = { fg = "highlight_high", bg = "none" },
          TelescopeNormal = { bg = "none" },
          TelescopePromptNormal = { bg = "base" },
          TelescopeResultsNormal = { fg = "subtle", bg = "none" },
          TelescopeSelection = { fg = "text", bg = "base" },
          TelescopeSelectionCaret = { fg = "rose", bg = "rose" },

          SnacksPickerBorder = { fg = "highlight_high", bg = "none" },
          SnacksPickerSelection = { fg = "text", bg = "base" },
          SnacksNormal = { bg = "none" },
          SnacksPicker = { bg = "none" },
          SnacksPickerList = { bg = "none" },
          SnacksPickerInput = { bg = "none" },
          SnacksPickerBox = { bg = "none" },

          SnacksPickerMatching = { fg = "#ff33b8", bold = true },
          SnacksDashboardHeader = { fg = "#ff33b8", bold = true },
          SnacksPickerSelectionCaret = { bg = "#361e3f", fg = "#ff33b8" },
          SnacksPickerMultiSelection = { fg = "#ff33b8" },
          SnacksPickerMultiIcon = { fg = "#ff33b8" },
          -- Comment = { fg = "foam" },
          -- VertSplit = { fg = "muted", bg = "muted" },
          -- Visual = { fg = "base", bg = "text", inherit = false },
        },

        before_highlight = function(group, highlight, palette)
          -- Disable all undercurls
          -- if highlight.undercurl then
          --     highlight.undercurl = false
          -- end
          --
          -- Change palette colour
          -- if highlight.fg == palette.pine then
          --     highlight.fg = palette.foam
          -- end
        end,
      })
      vim.opt.laststatus = 2 -- Or 3 for global statusline
      vim.opt.statusline = " %f %m %= %l:%c ♥ "
      vim.cmd("colorscheme rose-pine")
    end
  }
}

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("wezterm_colorscheme", { clear = true }),
  callback = function(args)
    local colorschemes = {
      ["tokyonight-day"] = "Tokyo Night Day",
      ["tokyonight-storm"] = "Tokyo Night Storm",
      ["catppuccin-frappe"] = "Catppuccin Frappe",
      ["catppuccin-latte"] = "Catppuccin Latte",
      ["catppuccin-macchiato"] = "Catppuccin Macchiato",
      ["catppuccin-mocha"] = "Catppuccin Mocha",
      ["night-owl"] = "Night Owl (Gogh)"
      -- add more color schemes here ...
    }
    local colorscheme = colorschemes[args.match]
    if not colorscheme then
      return
    end
    -- Write the colorscheme to a file
    -- local filename = vim.fn.expand("$HOME/.dotfiles/configs/wezterm/colorscheme")
    -- assert(type(filename) == "string")
    -- local file = io.open(filename, "w")
    -- assert(file)
    -- file:write(colorscheme)
    -- file:close()
    -- vim.notify("Setting WezTerm color scheme to " .. colorscheme, vim.log.levels.INFO)
  end,
})

return M
