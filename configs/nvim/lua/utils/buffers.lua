-- Function to close all Neovim buffers except the current one
function close_all_buffers_except_current()
  local current_bufnr = vim.fn.bufnr("%") -- Get the buffer number of the current buffer
  local buffers = vim.api.nvim_list_bufs() -- Get a list of all buffers
  local bd = require("mini.bufremove").delete

  for _, bufnr in ipairs(buffers) do
    if bufnr ~= current_bufnr then
      bd(bufnr)
    end
  end
end

function close_current_buffer()
  local bd = require("mini.bufremove").delete
  if vim.bo.modified then
    local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
    if choice == 1 then -- Yes
      vim.cmd.write()
      bd(0)
    elseif choice == 2 then -- No
      bd(0, true)
    end
  else
    bd(0)
  end
end
