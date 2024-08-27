package.loaded["ben.lua-repl"] = nil

-- source % to run

local bufnr

local scratch_bufnr

local autocmd_id

local group = vim.api.nvim_create_augroup("LuaRepl", { clear = true })

local M = {}

M.started = false

M.stop = function()
  print("Stopping Lua REPL")
  if bufnr ~= nil then
    M.started = false
    if scratch_bufnr ~= nil then
      vim.api.nvim_buf_delete(scratch_bufnr, { force = true })
    end

    -- vim.api.nvim_win_close(win, true)
    vim.api.nvim_del_autocmd(autocmd_id)

    bufnr = nil
  end
end

local append_data = function(_, data)
  if data then
    vim.api.nvim_buf_set_lines(scratch_bufnr, -1, -1, false, data)
  end
end

local execute = function()
  vim.api.nvim_buf_set_lines(scratch_bufnr, 0, -1, false, { "Output" })
  vim.api.nvim_buf_set_lines(scratch_bufnr, -1, -1, false, { "" })
  vim.fn.jobstart("lua" .. " " .. vim.fn.expand("%:p"), {
    stdout_buffered = true,
    on_stdout = append_data,
    on_stderr = append_data,
  })
end

M.start = function()
  print("Starting Lua REPL")
  M.started = true

  local work_win = vim.api.nvim_get_current_win()

  bufnr = vim.api.nvim_get_current_buf()
  scratch_bufnr = vim.api.nvim_create_buf(false, true)

  -- local codeWin = vim.api.nvim_get_current_win()
  vim.cmd("vsplit")

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, scratch_bufnr)

  vim.api.nvim_set_current_win(work_win)

  execute()

  autocmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = bufnr,
    group = group,
    callback = function()
      execute()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufHidden" }, {
    buffer = scratch_bufnr,
    group = group,
    callback = function()
      scratch_bufnr = nil
      M.stop()
    end,
  })
end

vim.api.nvim_create_user_command("LuaReplToggle", function()
  if M.started then
    M.stop()
  else
    M.start()
  end
end, {})

return M
