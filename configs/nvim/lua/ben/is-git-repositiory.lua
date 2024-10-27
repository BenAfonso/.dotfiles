local M = function()
  local path = vim.loop.cwd() .. "/.git"
  local ok, err = vim.loop.fs_stat(path)
  if not ok then
    return false
  end
  return true
end

return M
