-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

require("ben.discipline")
-- local input = require("ben.input")
require("utils.buffers")

-- discipline.cowboy()

local keymap = vim.keymap
-- local opts = { noremap = true, silent = true }
-- local wk = require("which-key")

keymap.set({ "n" }, "<CR>", ":noh<CR><CR>", { noremap = true, silent = true, desc = "Disable search highlight" })

keymap.set({ "n", "x" }, "<leader>L", "<Cmd>:Lazy<CR>", { noremap = true, silent = true, desc = "Lazy" })

keymap.set({ "n", "x" }, "<leader>d", '"_d', { noremap = true, silent = true, desc = "Deletes in blackhole register" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })

keymap.set({ "i", "n" }, "<A-j>", "<Cmd>m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
keymap.set({ "v" }, "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })

keymap.set({ "i", "n" }, "<A-k>", "<Cmd>m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })
keymap.set({ "v" }, "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })

keymap.set("n", "<C-b>", "<C-v>", { noremap = true, silent = true, desc = "Enter Visual Block mode" })

-- Buffers management
keymap.set("n", ";q", close_current_buffer, { noremap = true, silent = true, desc = "Close Buffer" })
keymap.set("n", "<C-q>", "<cmd>:q<CR>", { noremap = true, silent = true, desc = "Close window" })

keymap.set("n", "<leader>bo", function()
  close_all_buffers_except_current()
end, { noremap = true, silent = true, desc = "Close all buffers except this one" })

keymap.set("n", "<leader><right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<leader><left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })
keymap.set("n", "<C-right>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
keymap.set("n", "<C-left>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })

-- Navigation
-- Jumplist
keymap.set("n", "<C-up>", "<C-o>", { noremap = true, silent = true, desc = "Jump back" })
keymap.set("n", "<C-down>", "<C-i>", { noremap = true, silent = true, desc = "Jump forward" })

-- Neogen
keymap.set(
  "n",
  "<leader>cg",
  ":lua require('neogen').generate()<CR>",
  { noremap = true, silent = true, desc = "Generate comment" }
)

-- Clipboard
-- Visual select replace with override register
keymap.set("x", "p", '"_dP', { noremap = true, desc = "Paste and keep yank register" })

-- keymap.set('n', '<leader>qa', ':%bd|e#|bd#<cr>|\'"', { noremap = true, silent = true, desc = 'Close all buffers except this one' })

-- keymap.set("n", "<C-j>", "<C-I>", { noremap = true })
-- keymap.set("n", "<C-k>", "<C-O>", { noremap = true })

-- increment decrement
keymap.set({ "n", "v" }, "+", "<C-a>", { noremap = true, silent = true, desc = "Increment" })
-- keymap.set({ "n", "v" }, "-", "<C-x>", { noremap = true, silent = true, desc = "Decrement" })

-- Scroll
keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down" })
keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up" })

-- Pasting
keymap.set("x", "<leader>p", '"_dP')

keymap.set("n", "n", "nzzzv", { noremap = true })
keymap.set("n", "N", "Nzzzv", { noremap = true })

-- Option + J ∆
keymap.set("", "∆", "<cmd>:m .+1<CR>", { noremap = true, silent = true })
-- Option + K ˚
keymap.set("", "˚", "<cmd>:m .-2<CR>", { noremap = true, silent = true })

-- Select all
keymap.set("n", "<C-A>", "gg<S-v>G")
-- New tab
keymap.set("n", "te", ":tabedit<Return>", { noremap = true, silent = true, desc = "Create new tab" })
keymap.set("n", "tb", ":tabedit %<Return>", { noremap = true, silent = true, desc = "Open current buffer in new tab" })
-- keymap.set("n", ";q", ":close<Return>", opts)
keymap.set("n", "tq", ":tabclose<Return>", { noremap = true, silent = true, desc = "Close tab" })
keymap.set("n", "<tab>", ":tabnext<Return>", { noremap = true, silent = true, desc = "Next tab" })
keymap.set("n", "<S-tab>", ":tabprev<Return>", { noremap = true, silent = true, desc = "Previous tab" })

-- Splits
keymap.set("n", "sh", ":split<Return>", { noremap = true, silent = true, desc = "Split window bottom" })
keymap.set("n", "sv", ":vsplit<Return>", { noremap = true, silent = true, desc = "Split window right" })
keymap.set("n", "<leader>|", ":vsplit<Return>", { noremap = true, silent = true, desc = "Split window right" })
keymap.set("n", "<leader>_", ":split<Return>", { noremap = true, silent = true, desc = "Split window bottom" })

-- Resize pane
keymap.set("n", "<A-left>", "<C-w><", { noremap = true, desc = "Resize pane left" })
keymap.set("n", "<A-right>", "<C-w>>", { noremap = true, desc = "Resize pane right" })
keymap.set("n", "<A-up>", "<C-w>+", { noremap = true, desc = "Resize pane up" })
keymap.set("n", "<A-down>", "<C-w>-", { noremap = true, desc = "Resize pane down" })

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

-- Diagnostics
keymap.set("n", "H", function()
  vim.diagnostic.open_float({
    border = "rounded",
  })
end, { noremap = true })

--
-- Git signs
--

local gs = require("gitsigns")

keymap.set({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { noremap = true, desc = "[H]unk [S]tage Hunk" })
keymap.set({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { noremap = true, desc = "[H]unk [R]eset Hunk" })
keymap.set("n", "<leader>hS", gs.stage_buffer, { noremap = true, desc = "[H]unk [S]tage Buffer" })
keymap.set("n", "<leader>ha", gs.stage_hunk, { noremap = true, desc = "[H]unk [S]tage Hunk" })
keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { noremap = true, desc = "[H]unk [U]ndo Stage Hunk" })
keymap.set("n", "<leader>hR", gs.reset_buffer, { noremap = true, desc = "[H]unk [R]eset Buffer" })
keymap.set("n", "<leader>hp", gs.preview_hunk, { noremap = true, desc = "[H]unk [P]review Hunk" })
keymap.set("n", "]h", gs.next_hunk, { noremap = true, desc = "Next [H]unk" })
keymap.set("n", "[h", gs.prev_hunk, { noremap = true, desc = "Prev [H]unk" })

keymap.set("n", "<leader>hb", function()
  gs.blame_line({ full = true })
end, { noremap = true, desc = "[H]unk [B]lame line" })
keymap.set("n", "<leader>htb", gs.toggle_current_line_blame, { noremap = true, desc = "[H]unk [T]oggle [B]lame" })
keymap.set("n", "<leader>hd", gs.diffthis, { noremap = true, desc = "[H]unk [D]iff this" })
keymap.set("n", "<leader>hD", function()
  gs.diffthis("~")
end, { noremap = true, desc = "Diff this (~)" })
keymap.set("n", "<leader>htd", gs.toggle_deleted, { noremap = true, desc = "[H]unk [T]oggle [D]eleted" })

keymap.set({ "n" }, "<leader>Go", ":DiffviewOpen<CR>", { noremap = true, desc = "[Git] Diff [Open]" })

-- Text object
keymap.set(
  { "o", "x" },
  "ih",
  ":<C-U>Gitsigns select_hunk<CR>",
  { noremap = true, silent = true, desc = "Select hunk" }
)
