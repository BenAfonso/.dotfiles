local reload = function()
  for name, _ in pairs(package.loaded) do
    if vim.startswith(name, "ben-template") then
      package.loaded[name] = nil
    end
  end
  require("ben-template").setup()
end

-- Local development
-- vim.keymap.set("n", "<leader>l", reload, { desc = "Reload ben-template" })
-- vim.api.nvim_create_user_command("ReloadPlugin", reload, {})
