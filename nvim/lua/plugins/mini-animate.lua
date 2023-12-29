local M = {
  "mini.animate",
}

M.config = function()
  local animate = require("mini.animate")

  animate.setup({
    -- Cursor path
    scroll = {
      enable = true,
      timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
    },
    cursor = {
      -- Whether to enable this animation
      enable = true,
      timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),

      -- Path generator for visualized cursor movement
      -- path = --<function: implements shortest line path>,
    },
  })
end

return M
