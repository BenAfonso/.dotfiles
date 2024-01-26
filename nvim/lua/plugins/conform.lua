local M = {}

require("conform").setup({
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})

local EnableFormatting = function(global)
  if global then
    print("Enabled formatting globally")
    vim.g.autoformat = true
    vim.g.disable_autoformat = false
  else
    print("Enabled formatting in buffer")
    vim.b.autoformat = true
    vim.b.disable_autoformat = false
  end
end

local DisableFormatting = function(global)
  if global then
    print("Disabled formatting globally")
    vim.g.autoformat = false
    vim.g.disable_autoformat = true
  else
    print("Disabled formatting in buffer")
    vim.b.autoformat = false
    vim.b.disable_autoformat = true
  end
end

vim.api.nvim_create_user_command("FormatDisable", function(args)
  -- FormatDisable! will disable formatting just for this buffer
  DisableFormatting(args.bang)
end, { desc = "Disable autoformat-on-save", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  EnableFormatting()
end, {
  desc = "Re-enable autoformat-on-save",
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  pattern = ".env",
  callback = function()
    DisableFormatting(false)
  end,
})

return M
