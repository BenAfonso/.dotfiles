local saved_hl = {}

vim.api.nvim_create_user_command("ShowCursor", function()
  local is_on = vim.wo.cursorcolumn

  if not is_on then
    saved_hl.line = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    saved_hl.col = vim.api.nvim_get_hl(0, { name = "CursorColumn" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303000" })
    vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#303000" })
    vim.wo.cursorline = true
    vim.wo.cursorcolumn = true
    print("Ruler: ON")
  else
    vim.api.nvim_set_hl(0, "CursorLine", saved_hl.line or {})
    vim.api.nvim_set_hl(0, "CursorColumn", saved_hl.col or {})
    vim.wo.cursorcolumn = false
    print("Ruler: OFF")
  end
end, {})
