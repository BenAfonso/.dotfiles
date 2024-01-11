local M = {
  "mini.animate",
}

M.config = function()
  local animate = require("mini.animate")

  animate.setup({
    -- Cursor path
    scroll = {
      enable = true,
      timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
    },
    open = {
      enable = false,
    },
    close = {
      enable = false,
    },
    cursor = {
      -- Whether to enable this animation
      enable = false,
      timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),

      -- Path generator for visualized cursor movement
      -- path = --<function: implements shortest line path>,
    },
  })

  -- Vertical movement

  -- vim.keymap.set(
  --   "n",
  --   "<C-d>",
  --   "<C-d><cmd>:lua MiniAnimate.execute_after('scroll', 'normal! zz')<CR>",
  --   { noremap = true }
  -- )
  -- vim.keymap.set(
  --   "n",
  --   "<C-u>",
  --   "<C-u><cmd>:lua MiniAnimate.execute_after('scroll', 'normal! zz')<CR>",
  --   { noremap = true }
  -- )
end

return M
