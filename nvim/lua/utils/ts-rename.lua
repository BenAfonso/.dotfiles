-- Renames a typescript file using LSP rename

---@class FileMovedArgs
---@field source string
---@field destination string
---@param args FileMovedArgs
local function ts_on_file_moved(args)
  local ts_clients = vim.lsp.get_active_clients({ name = "tsserver" })
  for _, ts_client in ipairs(ts_clients) do
    ts_client.request("workspace/executeCommand", {
      command = "_typescript.applyRenameFile",
      arguments = {
        {
          sourceUri = vim.uri_from_fname(args.source),
          targetUri = vim.uri_from_fname(args.destination),
        },
      },
    })
  end
end

local function prompt_ts_rename(prompt_path)
  local source_file = prompt_path or vim.api.nvim_buf_get_name(0)
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
end

return {
  prompt_ts_rename = prompt_ts_rename,
  ts_on_file_moved = ts_on_file_moved,
}
