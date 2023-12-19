-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local discipline = require("ben.discipline")
discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<C-b>", "<C-v>", { noremap = true, silent = true, desc = "Enter Visual Block mode" })
keymap.set("n", ";q", ":bd<CR>", { noremap = true, silent = true, desc = "Close Buffer" })
keymap.set("n", "<leader><right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<leader><left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })

keymap.set("n", "<C-right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<C-left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })

keymap.set(
  "n",
  "<leader>qa",
  ":%bd|e#|bd#<cr>|'\"",
  -- ":%bd|e#<CR>",
  { noremap = true, silent = true, desc = "Close all buffers except this one" }
)

keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

-- Sidenav
keymap.set("n", "<C-e>", ":Neotree toggle<Return>", {
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
