local M = {}

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

M.delete_file = function(options, prompt_bufnr)
  return function()
    local picker = action_state.get_current_picker(prompt_bufnr)
    picker:delete_selection(function(selection)
      local name = selection[1]
      local cwd = getmetatable(selection).cwd
      vim.cmd(string.format(":!rm %s/%s", cwd, name))
    end)
  end
end

return M
