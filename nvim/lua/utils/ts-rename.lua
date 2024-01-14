-- Renames a typescript file using LSP rename
return function()
  local source_file = vim.api.nvim_buf_get_name(0)
  local target_file

  -- vim.ui.input({
  --   prompt = "Source : ",
  --   completion = "file",
  --   default = vim.api.nvim_buf_get_name(0),
  -- }, function(input)
  -- source_file = input
  vim.ui.input({
    prompt = "Target : ",
    completion = "file",
    default = source_file,
  }, function(input)
    target_file = input
    local params = {
      command = "_typescript.applyRenameFile",
      arguments = {
        {
          sourceUri = source_file,
          targetUri = target_file,
        },
      },
      title = "",
    }

    vim.lsp.util.rename(source_file, target_file)
    vim.lsp.buf.execute_command(params)
  end)
  -- end)
end
