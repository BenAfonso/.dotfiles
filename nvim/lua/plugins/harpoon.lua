local harpoon = require("harpoon")
local M = {}

-- REQUIRED
harpoon:setup({
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
    key = function()
      return vim.loop.cwd()
    end,
  },
})
-- REQUIRED

local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table({
        results = file_paths,
      }),
      attach_mappings = function(_, map)
        -- Map "<cr>" in insert mode to the function, actions.set_command_line
        map("n", "dd", function(prompt_bufnr)
          local action_state = require("telescope.actions.state")
          local b = action_state.get_current_line()
          local action_state = require("telescope.actions.state")
          local current_picker = action_state.get_current_picker(prompt_bufnr) -- picker state
          print(current_picker._selection_row)
          harpoon:list():removeAt(current_picker._selection_row)
          -- harpoon.list().removeAt(harpoon, current_picker._selection_row)

          -- harpoon.list().remove(self, )
        end)

        -- If the return value of `attach_mappings` is true, then the other
        -- default mappings are still applies.
        --
        -- Return false if you don't want any other mappings applied.
        --
        -- A return value _must_ be returned. It is an error to not return anything.
        return true
      end,
      mappings = {},
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
    })
    :find()
end

harpoon:extend({
  UI_CREATE = function(cx)
    vim.keymap.set("n", "vs", function()
      harpoon.ui:select_menu_item({ vsplit = true })
    end, { buffer = cx.bufnr })

    vim.keymap.set("n", "s", function()
      harpoon.ui:select_menu_item({ split = true })
    end, { buffer = cx.bufnr })

    vim.keymap.set("n", "te", function()
      harpoon.ui:select_menu_item({ tabedit = true })
    end, { buffer = cx.bufnr })
  end,
})

vim.keymap.set("n", "<C-e>", function()
  toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })

vim.keymap.set("n", "<leader>a", function()
  harpoon:list():append()
end)
vim.keymap.set("n", "<C-t>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)
vim.keymap.set("n", ";t", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)
vim.keymap.set("n", "<leader>h1", function()
  harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>h2", function()
  harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>h3", function()
  harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>h4", function()
  harpoon:list():select(4)
end)
vim.keymap.set("n", ";1", function()
  harpoon:list():select(1)
end)
vim.keymap.set("n", ";2", function()
  harpoon:list():select(2)
end)
vim.keymap.set("n", ";3", function()
  harpoon:list():select(3)
end)
vim.keymap.set("n", ";4", function()
  harpoon:list():select(4)
end)

-- vim.keymap.set("n", "<C-1>", function()
--   harpoon:list():select(1)
-- end)
-- vim.keymap.set("n", "<C-2>", function()
--   harpoon:list():select(2)
-- end)
-- vim.keymap.set("n", "<C-3>", function()
--   harpoon:list():select(3)
-- end)
-- vim.keymap.set("n", "<C-4>", function()
--   harpoon:list():select(4)
-- end)

-- Toggle previous & next buffers stored within Harpoon list
-- vim.keymap.set("n", "<C-S-P>", function()
--   harpoon:list():prev()
-- end)
--
-- vim.keymap.set("n", "<C-S-N>", function()
--   harpoon:list():next()
-- end)

return M
