-- source % to run

local bufnr = vim.api.nvim_get_current_buf()
local scratch_bufnr = vim.api.nvim_create_buf(false, true)
-- local rand_bufnr = vim.api.nvim_create_buf(false, true)

local runCommand = function()
  local append_data = function(_, data)
    vim.api.nvim_buf_set_lines(scratch_bufnr, -2, -1, false, { data[1] })
  end

  vim.fn.jobstart("date", {
    stdout_buffered = true,
    on_stdout = append_data,
    -- on_stderr = append_data,
  })
end

local codeWin = vim.api.nvim_get_current_win()
vim.cmd("vsplit")
-- local pad_win = vim.api.nvim_get_current_win()
-- vim.api.nvim_win_set_buf(pad_win, rand_bufnr)
-- vim.cmd("split")

local win = vim.api.nvim_get_current_win()
vim.api.nvim_win_set_buf(win, scratch_bufnr)

vim.api.nvim_buf_set_lines(scratch_bufnr, 1, -1, false, { "", "", "", "", "", "", "", "" })
vim.api.nvim_buf_set_lines(scratch_bufnr, -2, -2, false, { "Started" })

runCommand()
vim.api.nvim_set_current_win(codeWin)

-- vim.api.nvim_create_autocmd("InsertLeave", {
vim.api.nvim_create_autocmd("BufWritePost", {
  buffer = bufnr,
  group = vim.api.nvim_create_augroup("testing-buffers2", { clear = true }),
  callback = function()
    local status, err = pcall(function()
      vim.api.nvim_win_hide(win)
      -- vim.api.nvim_win_hide(pad_win)
    end)

    vim.cmd("source %")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  buffer = scratch_bufnr,
  group = vim.api.nvim_create_augroup("testing-buffers", { clear = true }),
  callback = runCommand,
})
