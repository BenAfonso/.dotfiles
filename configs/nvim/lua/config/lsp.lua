-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local bufnr = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    vim.api.nvim_create_user_command("LspReload", function()
      vim.lsp.stop_client(vim.lsp.get_clients())
      vim.cmd("edit")
    end, {})

    local imap = function(keys, func, desc)
      vim.keymap.set("i", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("H", function()
      vim.diagnostic.open_float({
        border = "rounded",
      })
    end, "Open LSP diagnostic")


    map("<leader>gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
    map("<leader>gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    map("<leader>gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
    map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "[D]iagnostic next")
    map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "[D]iagnostic prev")
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("K", function()
      vim.lsp.buf.hover({
        border = "rounded",
        focusable = true,
        focus = true,
      })
    end, "Hover Documentation")
    map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    local signature_help = function()
      vim.lsp.buf.signature_help({
        border = "rounded",
        focusable = true,
        focus = true,
      })
    end

    local hover = function()
      vim.lsp.buf.hover({
        border = "rounded",
        focusable = true,
        focus = true,
      })
    end

    vim.lsp.handlers["textDocument/hover"] = hover
    vim.lsp.handlers["textDocument/signatureHelp"] = signature_help
    imap("<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    map("<C-s>", vim.lsp.buf.signature_help, "Signature Help")
    vim.keymap.set("i", "<c-s>", vim.lsp.buf.signature_help, { buffer = true })

    if client ~= nil then
      local cap = client.server_capabilities

      if vim.tbl_contains({ "null-ls" }, client.name) then -- blacklist lsp
        return
      end
    end
  end,
})


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

vim.lsp.handlers["textDocument/hover"] = vim.lsp.buf.hover({
  border = "rounded",
  focusable = true,
  focus = true,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.buf.signature_help({
  border = "rounded",
  focusable = true,
  focus = true,
  -- close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
  -- close_events = { "CursorMoved", "BufHidden", "InsertCharPre", "InsertEnter" },
})

-- This is copied straight from blink
-- https://cmp.saghen.dev/installation#merging-lsp-capabilities
local capabilities = {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
}

capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

-- Setup language servers.

vim.lsp.config("*", {
  capabilities = capabilities,
  root_markers = { ".git" },
})

-- Enable each language server by filename under the lsp/ folder
vim.lsp.enable({
  -- "gopls",
  -- "basedpyright",
  -- "luals",
  -- "typescript",
  -- "tailwind",
  -- "rustls",
})
