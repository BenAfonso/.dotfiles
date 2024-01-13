-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local discipline = require("ben.discipline")
require("utils.buffers")

discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local wk = require("which-key")

keymap.set("n", "<C-b>", "<C-v>", { noremap = true, silent = true, desc = "Enter Visual Block mode" })

-- Buffers management
keymap.set("n", ";q", close_current_buffer, { noremap = true, silent = true, desc = "Close Buffer" })
keymap.set("n", "<C-q>", "<cmd>:q<CR>", { noremap = true, silent = true, desc = "Close window" })

keymap.set("n", "<leader>bo", function()
  close_all_buffers_except_current()
end, { noremap = true })

keymap.set("n", "<leader><right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<leader><left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })
keymap.set("n", "<C-right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<C-left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })

keymap.set(
  "n",
  "<leader>qa",
  ":%bd|e#|bd#<cr>|'\"",
  { noremap = true, silent = true, desc = "Close all buffers except this one" }
)

-- keymap.set("n", "<C-j>", "<C-I>", { noremap = true })
-- keymap.set("n", "<C-k>", "<C-O>", { noremap = true })

-- increment decrement
keymap.set("n", "+", "<C-a>", { noremap = true })
keymap.set("n", "-", "<C-x>", { noremap = true })

-- Scroll
keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

-- LSP
keymap.set(
  "n",
  "<leader>gi",
  "<cmd>Telescope lsp_implementations<CR>",
  { noremap = true, silent = true, desc = "LSP Implementations" }
)
keymap.set(
  "n",
  "<leader>gd",
  "<cmd>Telescope lsp_definitions<CR>",
  { noremap = true, silent = true, desc = "LSP Definitions" }
)
keymap.set(
  "n",
  "<leader>gr",
  "<cmd>Telescope lsp_references<CR>",
  { noremap = true, silent = true, desc = "LSP References" }
)

-- Pasting
keymap.set("x", "<leader>p", '"_dP')

keymap.set("n", "n", "nzzzv", { noremap = true })
keymap.set("n", "N", "Nzzzv", { noremap = true })

-- Option + J ∆
keymap.set("", "∆", "<cmd>:m .+1<CR>", { noremap = true, silent = true })
-- Option + K ˚
keymap.set("", "˚", "<cmd>:m .-2<CR>", { noremap = true, silent = true })

-- Sidenav
keymap.set("n", "<C-e>", "'Neotree toggle<Return>", {
  silent = true,
})

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")
-- New tab
keymap.set("n", "te", ":tabedit<Return>", opts)
keymap.set("n", "tb", ":tabedit %<Return>", opts)
-- keymap.set("n", ";q", ":close<Return>", opts)
keymap.set("n", "tq", ":tabclose<Return>", opts)
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<S-tab>", ":tabprev<Return>", opts)

-- Splits
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "vs", ":vsplit<Return>", opts)
keymap.set("n", "<leader>|", ":vsplit<Return>", opts)
keymap.set("n", "<leader>_", ":split<Return>", opts)

-- Resize pane
keymap.set("n", "<A-left>", "<C-w><")
keymap.set("n", "<A-right>", "<C-w>>")
keymap.set("n", "<A-up>", "<C-w>+")
keymap.set("n", "<A-down>", "<C-w>-")

-- Rename
keymap.set("n", "<leader>cj", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, {
  expr = true,
  desc = "Custom Rename",
})

-- Undotree
vim.keymap.set("n", "<leader><F5>", vim.cmd.UndotreeToggle)

-- flash
wk.register({
  o = {
    name = "flash",
    s = {
      function()
        require("flash").jump()
      end,
      "Flash Jump",
    },
    t = {
      function()
        require("flash").treesitter()
      end,
      "Flash Treesitter",
    },
    r = {
      function()
        require("flash").treesitter_search()
      end,
      "Search Treesitter",
    },
  },
}, { prefix = "<leader>" })

-- Diagnostics
keymap.set("n", "<C-x>", function()
  vim.diagnostic.open_float()
end, { noremap = true })
