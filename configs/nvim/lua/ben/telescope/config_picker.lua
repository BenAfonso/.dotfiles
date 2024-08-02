local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "Configs",
      finder = finders.new_table({
        results = {
          { "Neovim", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/nvim/") },
          { "Zsh", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/zsh/") },
          { "Custom scripts", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/bin/") },
          { "Wezterm", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/wezterm/") },
          { "Tmux", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/tmux/") },
          { "Git", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/git") },
          { "Gnupg", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/gnupg") },
          { "Hammerspoon", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/hammerspoon") },
          { "Litellm", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/litellm") },
          { "Starship", path = string.format("%s/%s", vim.fn.getenv("DOTFILES"), "/configs/starship") },
        },
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry[1],
            ordinal = entry[1],
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection.value.path ~= nil then
            require("telescope.builtin").find_files({
              cwd = selection.value.path,
            })
            -- vim.cmd(string.format(":e %s", selection.value.path))
          end
          -- print(vim.inspect(selection))
          -- vim.api.nvim_put({ selection[1] }, "", false, true)
        end)
        return true
      end,
    })
    :find()
end

return M
