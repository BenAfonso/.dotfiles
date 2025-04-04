require("ben.discipline")
require("utils.buffers")

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
keymap.set("n", "<leader>|", ":vsplit<Return>", { noremap = true, silent = true, desc = "Split window right" })
keymap.set("n", "<leader>_", ":split<Return>", { noremap = true, silent = true, desc = "Split window bottom" })
-- Resize pane
keymap.set("n", "<A-left>", "<C-w><", { noremap = true, desc = "Resize pane left" })
keymap.set("n", "<A-right>", "<C-w>>", { noremap = true, desc = "Resize pane right" })
keymap.set("n", "<A-up>", "<C-w>+", { noremap = true, desc = "Resize pane up" })
keymap.set("n", "<A-down>", "<C-w>-", { noremap = true, desc = "Resize pane down" })

----------------
-- Buffers
----------------

keymap.set("n", ";q", close_current_buffer, { noremap = true, silent = true, desc = "Close Buffer" })
keymap.set("n", "<leader>bo", function()
  close_all_buffers_except_current()
end, { noremap = true, silent = true, desc = "Close all buffers except this one" })
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
