-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.wo.spell = false
    vim.wo.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf" },
  group = vim.api.nvim_create_augroup("QfFilter", { clear = true }),
  callback = function()
    vim.keymap.set({ "n" }, "dd", function()
      local match_str = vim.fn.getline("."):match("^(.-)|")

      -- If no match found, just use the entire line
      if match_str == "" then
        match_str = current_line
      end
      local cmd = "Cfilter! " .. vim.fn.escape(match_str, " ")
      -- vim.notify(cmd)
      -- vim.cmd(cmd)
    end, { buffer = true })
  end,
})

local luasnip = require("luasnip")

local unlinkgrp = vim.api.nvim_create_augroup("UnlinkSnippetOnModeChange", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = unlinkgrp,
  pattern = { "s:n", "i:*" },
  desc = "Forget the current snippet when leaving the insert mode",
  callback = function(evt)
    if luasnip.session and luasnip.session.current_nodes[evt.buf] and not luasnip.session.jump_active then
      luasnip.unlink_current()
    end
  end,
})
