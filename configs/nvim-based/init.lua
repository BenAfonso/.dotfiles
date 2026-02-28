vim.cmd("packadd cfilter")

vim.g.mapleader = " "
vim.o.wrap = false
vim.opt.cmdheight = 0
vim.opt.number = true
vim.opt.relativenumber = true
-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split" -- Incsearch while sub
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10


vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.o.expandtab = true
vim.bo.softtabstop = 0

vim.opt.scrolloff = 10

vim.opt.sidescrolloff = 5

vim.o.exrc = true
vim.o.colorcolumn = "80"

-- [[ Basic Keymaps ]]

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

local keymap = vim.keymap

----------------
-- Windows
----------------

keymap.set("n", "<leader>ww", ":w<Return>", { noremap = true, silent = true, desc = "[W]indow :[w]" })
keymap.set("n", "<leader>wq", ":q<Return>", { noremap = true, silent = true, desc = "[W]indow :[q]" })
keymap.set("n", "<C-q>", "<cmd>:q<CR>", { noremap = true, silent = true, desc = "Close window" })

-- Splits
keymap.set("n", "sh", ":split<Return>", { noremap = true, silent = true, desc = "Split window bottom" })
keymap.set("n", "sv", ":vsplit<Return>", { noremap = true, silent = true, desc = "Split window right" })
keymap.set("n", "<c-l>", "<C-w>l", { noremap = true, desc = "Focus pane right" })
keymap.set("n", "<c-j>", "<C-w>j", { noremap = true, desc = "Focus pane down" })
keymap.set("n", "<c-k>", "<C-w>k", { noremap = true, desc = "Focus pane up" })
keymap.set("n", "<c-h>", "<C-w>h", { noremap = true, desc = "Focus pane left" })


----------------
-- Buffers
----------------

keymap.set("n", ";q", ':bdelete<CR>', { noremap = true, silent = true, desc = "Close Buffer" })
keymap.set("n", "<leader><right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<leader><left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })
keymap.set("n", "<C-right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<C-left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })

----------------
-- Tabs
----------------

keymap.set("n", "te", ":tabedit<Return>", { noremap = true, silent = true, desc = "Create new tab" })
keymap.set("n", "tb", ":tabedit %<Return>", { noremap = true, silent = true, desc = "Open current buffer in new tab" })
keymap.set("n", "tq", ":tabclose<Return>", { noremap = true, silent = true, desc = "Close tab" })
keymap.set("n", "th", ":tabprev<Return>", { noremap = true, silent = true, desc = "Previous tab" })
keymap.set("n", "tl", ":tabnext<Return>", { noremap = true, silent = true, desc = "Next tab" })
keymap.set("n", "<S-tab>", ":tabprev<Return>", { noremap = true, silent = true, desc = "Previous tab" })
keymap.set("n", "<tab>", ":tabnext<Return>", { noremap = true, silent = true, desc = "Next tab" })

----------------
-- Utils
----------------

-- Jumplist
keymap.set("n", "<C-up>", "<C-o>", { noremap = true, silent = true, desc = "Jump back" })
keymap.set("n", "<C-down>", "<C-i>", { noremap = true, silent = true, desc = "Jump forward" })

-- Clipboard
keymap.set("n", "Yp", '<cmd>:let @+=expand("%:.")<CR>', { noremap = true, desc = "Copy relative path to current buffer" })
keymap.set("n", "Yap", '<cmd>:let @+=expand("%:p")<CR>',
  { noremap = true, desc = "Copy absolute path to current buffer" })

keymap.set("x", "p", '"_dP', { noremap = true, desc = "Paste and keep yank register" })

keymap.set({ "n", "x" }, "<leader>d", '"_d', { noremap = true, silent = true, desc = "Deletes in blackhole register" })
keymap.set({ "n", "x" }, "<leader>c", '"_c', { noremap = true, silent = true, desc = "Replace in blackhole register" })

-- Centered on cursor move
keymap.set("n", "<c-d>", "<c-d>zz", { noremap = true, silent = true, desc = "scroll down" })
keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up" })
keymap.set("n", "n", "nzz", { noremap = true })
keymap.set("n", "N", "Nzz", { noremap = true })
keymap.set("n", "*", "*zz", { noremap = true })
keymap.set("n", "#", "#zz", { noremap = true })
keymap.set("n", "g*", "g*zz", { noremap = true })
keymap.set("n", "g#", "g#zz", { noremap = true })

-- Center cursor horizontally
keymap.set("n", "zZ", "zszH", { noremap = true })

-- Select all
keymap.set("n", "<C-A>", "gg<S-v>G")

-- Move line down
-- Option + J ∆
keymap.set("", "∆", "<cmd>:m .+1<CR>", { noremap = true, silent = true })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })
keymap.set({ "i", "n" }, "<A-j>", "<Cmd>m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
keymap.set({ "v" }, "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })

-- Move line up
-- Option + K
keymap.set("", "˚", "<cmd>:m .-2<CR>", { noremap = true, silent = true })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })
keymap.set({ "i", "n" }, "<A-k>", "<Cmd>m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })
keymap.set({ "v" }, "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })

keymap.set({ "n" }, "<CR>", ":noh<CR><CR>", { noremap = true, silent = true, desc = "Disable search highlight" })
keymap.set({ "n", "x" }, "<leader>L", "<Cmd>:Lazy<CR>", { noremap = true, silent = true, desc = "Lazy" })
keymap.set("n", "<C-b>", "<C-v>", { noremap = true, silent = true, desc = "Enter Visual Block mode" })

-- increment decrement
keymap.set({ "n", "v" }, "+", "<C-a>", { noremap = true, silent = true, desc = "Increment" })
-- keymap.set({ "n", "v" }, "-", "<C-x>", { noremap = true, silent = true, desc = "Decrement" })

-- Say in indent mode
keymap.set("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent and stay in indent mode" })
keymap.set("v", ">", ">gv", { noremap = true, silent = true, desc = "Indent and stay in indent mode" })

-- Terminal
keymap.set("t", "<Esc><Esc>", "<C-\\><C-N>")

-- Execute
keymap.set("n", "<leader>X", "<cmd>source %<CR>")
keymap.set("n", "<leader>x", "<cmd>.lua<CR>")
keymap.set("n", "<leader>\\", "<cmd>%.lua<CR>")

vim.keymap.set("n", "-", ":Oil<CR>")

vim.pack.add({
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/catppuccin/nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/folke/snacks.nvim' },
})

vim.lsp.enable({
  'lua_ls',
})

vim.cmd("colorscheme catppuccin")

require('oil').setup({
  keymaps = {
    ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["sv"] = "actions.select_vsplit",
      ["sh"] = "actions.select_split",
      ["CD"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
      ["CC"] = {
        function()
          vim.cmd("tcd -")
        end,
        desc = ":tcd -",
      },
      ["<leader><CR>"] = {
        callback = function()
          -- WSL environment open current directory
          if vim.fn.executable("dolphin") then
            os.execute(
              "dolphin " .. require("oil").get_current_dir() .. " > /dev/null 2>&1 & disown"
            )
          elseif vim.fn.executable("wslpath") then
            os.execute(
              "/mnt/c/Windows/explorer.exe `wslpath -w " .. require("oil").get_current_dir() .. "` > /dev/null"
            )
          end
        end,
      },
      ["te"] = {
        callback = function()
          -- actions["select_tab"].callback()
        end,
        desc = "Open in new tab",
        mode = "n",
      },
      ["<C-s>"] = false,
      ["<C-h>"] = false,
      ["<C-t>"] = false,
      ["<C-l>"] = false,
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["yp"] = "actions.copy_entry_path",
      ["q"] = "actions.close",
      ["<C-r>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash", 
    }
})
