local M = {
  enabled = false,
  "wfxr/minimap.vim",
  config = function()
    vim.keymap.set(
      "n",
      "<leader>mt",
      "<cmd>MinimapToggle<CR>",
      { silent = true, noremap = true, desc = "Toggle MiniMap" }
    )
    -- vim.cmd("MinimapToggle<CR>")
  end,
}

-- local M = {
--   {
--     "echasnovski/mini.map",
--     version = "*",
--     config = function()
--       local MiniMap = require("mini.map")
--       MiniMap.setup({
--         symbols = {
--           encode = MiniMap.gen_encode_symbols.dot("4x2"),
--         },
--       })
--
--       MiniMap.toggle()
--       vim.keymap.set("n", "<leader>mt", function()
--         MiniMap.toggle()
--       end, { noremap = true, desc = "Toggle MiniMap" })
--       -- MiniMap.gen_encode_symbols.dot("4x2")
--     end,
--   },
-- }

return M
