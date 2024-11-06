local M = {
  "lewis6991/gitsigns.nvim",
  opts = {
    -- signs = {
    --   add = { text = '+' },
    --   change = { text = '~' },
    --   delete = { text = '_' },
    --   topdelete = { text = '‾' },
    --   changedelete = { text = '~' },
    -- },
    -- signs = {
    --   add = { text = '│' },
    --   change = { text = '│' },
    --   delete = { text = '_' },
    --   topdelete = { text = '‾' },
    --   changedelete = { text = '~' },
    --   untracked = { text = '┆' },
    -- },
    -- _signs_staged_enable = true,
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      follow_files = true,
    },
    auto_attach = true,
    attach_to_untracked = false,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = {
      -- Options passed to nvim_open_win
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    -- yadm = {
    --   enable = false,
    -- },
  },
  config = function(_, opts)
    require("gitsigns").setup(opts)

    local keymap = vim.keymap

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

    -- Text object
    keymap.set(
      { "o", "x" },
      "ih",
      ":<C-U>Gitsigns select_hunk<CR>",
      { noremap = true, silent = true, desc = "Select hunk" }
    )

    -- require("scrollbar.handlers.gitsigns").setup()
  end,
}

return M
