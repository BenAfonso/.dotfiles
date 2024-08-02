local lineHL, colHL

vim.api.nvim_create_user_command("ShowCursor", function()
  if vim.opt.cursorcolumn:get() == false then
    vim.cmd("set cursorline")
    vim.cmd("set cursorcolumn")
    lineHL = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    colHL = vim.api.nvim_get_hl(0, { name = "CursorColumn" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303000" })
    vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#303000" })
    print("Ruler: ON")
  else
    vim.cmd("set cursorline")
    vim.cmd("set nocursorcolumn")
    vim.api.nvim_set_hl(0, "CursorLine", lineHL)
    vim.api.nvim_set_hl(0, "CursorColumn", colHL)
    print("Ruler: OFF")
  end
end, {})
