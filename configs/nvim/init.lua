vim.cmd("packadd cfilter")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.wrap = false

vim.opt.cmdheight = 0

-- Make line numbers default
vim.opt.number = true

--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split" -- Incsearch while sub

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

  {                   -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    version = "3.17.0",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require("which-key").setup()

      -- Document existing key chains
      require("which-key").add({
        { "<leader>c",  group = "[C]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>h",  group = "[H]unks" },
        { "<leader>h_", hidden = true },
        { "<leader>d",  group = "[D]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>r",  group = "[R]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s",  group = "[S]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>w",  group = "[W]orkspace" },
        { "<leader>w_", hidden = true },
        { "<leader>x",  group = "Trouble" },
        { "<leader>x_", hidden = true },
        { "<leader>g",  group = "[G]o" },
        { "<leader>g_", hidden = true },
        { "<leader>b",  group = "[B]uffers" },
        { "<leader>b_", hidden = true },
        { "<leader>t",  group = "[T]erminal" },
        { "<leader>t_", hidden = true },
      })
    end,
  },
  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  { import = "plugins" },
  { import = "plugins.lsp" },
  { import = "plugins.telescope" },
}, {
  ui = {
    size = {
      width = 0.9,
      height = 0.9,
    },

    border = "rounded",
    title = "💤 Lazy.nvim",

    wrap = false,

    icons = {
      cmd = "  ", ---+ ${ui, Lazy.nvim UI icons}

      config = "  ",
      event = "  ",
      ft = "  ",

      init = "  ",
      imports = "  ",

      keys = "  ",

      lazy = " ",
      loaded = " ",
      not_loaded = " ",

      plugin = "  ",
      runtime = "  ",
      require = "  ",

      source = " ",
      start = "",

      task = "  ", ---_
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

require("config")
require("ben")
