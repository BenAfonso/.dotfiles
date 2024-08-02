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

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local lspui = require("lspconfig.ui.windows")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    vim.diagnostic.config({
      diagnostic = {
        signs = true,
        underline = true,
        update_in_insert = true,
        severity_sort = true,
        border = "rounded",
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
      },
    })

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    })

    vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("<leader>gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("<leader>gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("<leader>gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        map("]d", vim.diagnostic.goto_next, "[D]iagnostic next")
        map("[d", vim.diagnostic.goto_prev, "[D]iagnostic prev")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client ~= nil then
          local cap = client.server_capabilities
          if
            client
            and client.server_capabilities.documentHighlightProvider
            and cap ~= nil
            ---@diagnostic disable-next-line: undefined-field
            and cap.document_highlight
          then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end
      end,
    })

    --LspInfo Borders
    lspui.default_options.border = "double"

    -- tsserver
    -- lspconfig.vtsls.setup({
    -- lspconfig.tsserver.setup({
    --   enabled = true,
    --   capabilities = capabilities,
    --   on_attach = function(client, bufnr)
    --     local map = function(keys, func, desc)
    --       vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    --     end
    --     map("<leader>co", "<cmd>:TSToolsOrganizeImports<CR>", "[O]rganize imports")
    --   end,
    --   filetypes = {
    --     "javascript",
    --     "javascriptreact",
    --     "javascript.jsx",
    --     "typescript",
    --     "typescriptreact",
    --     "typescript.tsx",
    --   },
    --   root_dir = function(filename, bufnr)
    --     if string.find(filename, "node_modules/") then
    --       return nil
    --     end
    --     if string.find(filename, ".min.js") then
    --       return nil
    --     end
    --     return lspconfig.util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")()
    --   end,
    --   settings = {
    --     complete_function_calls = true,
    --     vtsls = {
    --       enableMoveToFileCodeAction = true,
    --       autoUseWorkspaceTsdk = true,
    --       experimental = {
    --         completion = {
    --           enableServerSideFuzzyMatch = true,
    --         },
    --       },
    --     },
    --     typescript = {
    --       updateImportsOnFileMove = { enabled = "always" },
    --       suggest = {
    --         completeFunctionCalls = true,
    --       },
    --       inlayHints = {
    --         enumMemberValues = { enabled = true },
    --         functionLikeReturnTypes = { enabled = true },
    --         parameterNames = { enabled = "literals" },
    --         parameterTypes = { enabled = true },
    --         propertyDeclarationTypes = { enabled = true },
    --         variableTypes = { enabled = false },
    --       },
    --     },
    --   },
    -- })

    -- html
    lspconfig.html.setup({
      capabilities = capabilities,
    })

    lspconfig.gopls.setup({
      capabilities = capabilities,
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    })

    -- Lua LS
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          runtime = { version = "LuaJIT" },
          workspace = {
            checkThirdParty = false,
            library = {
              "${3rd}/luv/library",
              vim.env.VIMRUNTIME,
              "~/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
            },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })
    -- CSS LS
    lspconfig.cssls.setup({
      capabilities = capabilities,
    })

    lspconfig.tailwindcss.setup({
      capabilities = capabilities,
    })

    lspconfig.eslint.setup({
      capabilities = capabilities,
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
    })
  end,
}
