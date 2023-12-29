-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local discipline = require("ben.discipline")
discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<C-b>", "<C-v>", { noremap = true, silent = true, desc = "Enter Visual Block mode" })

-- Buffers management
keymap.set("n", ";q", ":bd<CR>", { noremap = true, silent = true, desc = "Close Buffer" })
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

keymap.set("n", "<C-o>", "<C-O>")
-- keymap.set("n", "<C-S-o>", "<C-I>")

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

-- Vertical movement
keymap.set("n", "<C-d>", "<C-d><cmd>:lua MiniAnimate.execute_after('scroll', 'normal! zz')<CR>", { noremap = true })
keymap.set("n", "<C-u>", "<C-u><cmd>:lua MiniAnimate.execute_after('scroll', 'normal! zz')<CR>", { noremap = true })

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
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Rename
keymap.set("n", "<leader>cj", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, {
  expr = true,
  desc = "Custom Rename",
})

-- Undotree
vim.keymap.set("n", "<leader><F5>", vim.cmd.UndotreeToggle)
