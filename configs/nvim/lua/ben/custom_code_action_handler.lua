local function custom_code_action_handler(params, callback)
  -- Get the list of available code actions from the server
  vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(results)
    local actions = {}

    -- Add server provided code actions
    for _, res in pairs(results) do
      for _, action in pairs(res.result or {}) do
        table.insert(actions, action)
      end
    end

    -- Add custom "Organize Imports" action
    table.insert(actions, {
      title = "Organize Imports",
      kind = "source.organizeImports",
      command = {
        title = "Organize Imports",
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      },
    })

    -- Add custom "Format Code" action
    table.insert(actions, {
      title = "Format Code",
      kind = "source.format",
      command = {
        title = "Format Code",
        command = "editor.action.formatDocument",
        arguments = { vim.api.nvim_buf_get_name(0) },
      },
    })

    -- Return all code actions including custom ones
    callback(actions)
  end)
end

return custom_code_action_handler
