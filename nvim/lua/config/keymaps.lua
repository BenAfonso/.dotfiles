-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local discipline = require("ben.discipline")
-- local input = require("ben.input")
require("utils.buffers")

-- discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local wk = require("which-key")

keymap.set({ "n", "x" }, "<leader>d", '"_d', { noremap = true, silent = true, desc = "Deletes in blackhole register" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

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

-- Clipboard
-- Visual select replace with override register
keymap.set("x", "p", '"_dP', { noremap = true, desc = "Paste and keep yank register" })

keymap.set(
  "n",
  "<leader>qa",
  ":%bd|e#|bd#<cr>|'\"",
  { noremap = true, silent = true, desc = "Close all buffers except this one" }
)

-- keymap.set("n", "<C-j>", "<C-I>", { noremap = true })
-- keymap.set("n", "<C-k>", "<C-O>", { noremap = true })

-- increment decrement
keymap.set({ "n", "v" }, "+", "<C-a>", { noremap = true, silent = true, desc = "Increment" })
keymap.set({ "n", "v" }, "-", "<C-x>", { noremap = true, silent = true, desc = "Decrement" })

-- Scroll
keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down" })
keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up" })

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
  desc = "Toggle Neotree",
})

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
keymap.set("n", "ss", ":split<Return>", { noremap = true, silent = true, desc = "Split window bottom" })
keymap.set("n", "vs", ":vsplit<Return>", { noremap = true, silent = true, desc = "Split window right" })
keymap.set("n", "<leader>|", ":vsplit<Return>", { noremap = true, silent = true, desc = "Split window right" })
keymap.set("n", "<leader>_", ":split<Return>", { noremap = true, silent = true, desc = "Split window bottom" })

-- Resize pane
-- keymap.set("n", "<A-S-h>", "<C-w><", { noremap = true, desc = "Resize pane left" })
-- keymap.set("n", "<A-S-l>", "<C-w>>", { noremap = true, desc = "Resize pane right" })
-- keymap.set("n", "<A-S-k>", "<C-w>+", { noremap = true, desc = "Resize pane up" })
-- keymap.set("n", "<A-S-j>", "<C-w>-", { noremap = true, desc = "Resize pane down" })

-- Undotree
vim.keymap.set("n", "<leader><F5>", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

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
keymap.set("n", "H", function()
  vim.diagnostic.open_float()
end, { noremap = true })

--
-- Git signs
--

local gs = require("gitsigns")

-- Navigation
keymap.set("n", "]c", function()
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(function()
    gs.next_hunk()
  end)
  return "<Ignore>"
end, { noremap = true, expr = true })

keymap.set("n", "[c", function()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    gs.prev_hunk()
  end)
  return "<Ignore>"
end, { noremap = true, expr = true })

require("which-key").register({
  ["<leader>ht"] = { name = "[G]it [T]oggle", _ = "which_key_ignore" },
})

keymap.set({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { noremap = true, desc = "[G]it [S]tage Hunk" })
keymap.set({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { noremap = true, desc = "[G]it [R]eset Hunk" })
keymap.set("n", "<leader>hS", gs.stage_buffer, { noremap = true, desc = "[G]it [S]tage Buffer" })
keymap.set("n", "<leader>ha", gs.stage_hunk, { noremap = true, desc = "[G]it [S]tage Hunk" })
keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { noremap = true, desc = "[G]it [U]ndo Stage Hunk" })
keymap.set("n", "<leader>hR", gs.reset_buffer, { noremap = true, desc = "[G]it [R]eset Buffer" })
keymap.set("n", "<leader>hp", gs.preview_hunk, { noremap = true, desc = "[G]it [P]review Hunk" })
keymap.set("n", "<leader>hb", function()
  gs.blame_line({ full = true })
end, { noremap = true, desc = "[G]it [B]lame line" })
keymap.set("n", "<leader>htb", gs.toggle_current_line_blame, { noremap = true, desc = "[G]it [T]oggle [B]lame" })
keymap.set("n", "<leader>hd", gs.diffthis, { noremap = true, desc = "[G]it [D]iff this" })
keymap.set("n", "<leader>hD", function()
  gs.diffthis("~")
end, { noremap = true, desc = "Diff this (~)" })
keymap.set("n", "<leader>htd", gs.toggle_deleted, { noremap = true, desc = "[G]it [T]oggle [D]eleted" })

-- Text object
keymap.set(
  { "o", "x" },
  "ih",
  ":<C-U>Gitsigns select_hunk<CR>",
  { noremap = true, silent = true, desc = "Select hunk" }
)
