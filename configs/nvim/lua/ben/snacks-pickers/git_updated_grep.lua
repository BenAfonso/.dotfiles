local snacks = require("snacks")
local Job = require("plenary.job")

local M = {}

-- Function to get modified and staged files from git
local function get_git_updated_files(callback)
  local files = {}
  local cmd = { "git", "status", "--porcelain" }

  Job:new({
    command = cmd[1],
    args = vim.list_slice(cmd, 2),
    on_exit = function(j, return_val)
      if return_val == 0 then
        local output = j:result()

        for _, line in ipairs(output) do
          -- Extract file path from git status output
          -- Example lines: ' M path/to/file.lua', '?? path/to/new_file.txt'
          -- We only care about the path part.
          local path = line:match("^..%s+(.*)$")
          if path then
            -- Handle renamed files (e.g., 'R  oldpath -> newpath')
            local renamed_match = path:match("^(.*)%s+->%s+(.*)$")
            if renamed_match then
              table.insert(files, renamed_match[2]) -- Use the new path
            else
              table.insert(files, path)
            end
          end
        end

        vim.schedule(function()
          callback(files)
        end)
      else
        -- Schedule UI operations and callbacks to run on the main loop
        vim.schedule(function()
          vim.notify("Error running git status: " .. table.concat(j:stderr_result(), "\n"), vim.log.levels.ERROR)
          callback({}) -- Return empty list on error
        end)
      end
    end,
  }):sync()
end

-- Define the snacks picker
M.grep_git_updated = function(opts)
  opts = opts or {}

  get_git_updated_files(function(files)
    if #files == 0 then
      vim.notify("No git updated files found to grep in.", vim.log.levels.INFO)
      return
    end


    local base_opts = {}
    local args = base_opts

    snacks.picker.grep({
      cmd = 'rg',
      prompt = opts.prompt or "Grep Git Updated> ",
      args = args,
      dirs = files,
    })
  end)
end

M.grep_git_updated()

return M
