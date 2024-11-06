return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    { "j-hui/fidget.nvim", opts = {} },

    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local lspui = require("lspconfig.ui.windows")

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
      focus = false,
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "rounded",
      focusable = true,
      focus = false,
      -- close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
      -- close_events = { "CursorMoved", "BufHidden", "InsertCharPre", "InsertEnter" },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local bufnr = event.buf
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

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
        map("]d", vim.diagnostic.goto_next, "[D]iagnostic next")
        map("[d", vim.diagnostic.goto_prev, "[D]iagnostic prev")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        imap("<C-k>", vim.lsp.buf.signature_help, "Signature Help")
        map("<C-s>", vim.lsp.buf.signature_help, "Signature Help")

        vim.keymap.set("i", "<c-s>", function()
          vim.lsp.buf.signature_help()
        end, { buffer = true })

        if client ~= nil then
          local cap = client.server_capabilities

          if vim.tbl_contains({ "null-ls" }, client.name) then -- blacklist lsp
            return
          end
          -- require("lsp_signature").on_attach({
          --   -- ... setup options here ...
          -- }, bufnr)

          if client and client.server_capabilities.documentHighlightProvider and cap ~= nil then
            -- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            --   buffer = event.buf,
            --   callback = vim.lsp.buf.document_highlight,
            -- })

            -- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            --   buffer = event.buf,
            --   callback = vim.lsp.buf.signature_help,
            -- })

            -- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            --   buffer = event.buf,
            --   callback = vim.lsp.buf.clear_references,
            -- })
          end
        end
      end,
    })

    --LspInfo Borders
    lspui.default_options.border = "double"

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    local servers = {
      html = {},
      clangd = {},
      rust_analyzer = {
        filetypes = { "rust" },
        root_dir = lspconfig.util.root_pattern("Cargo.toml"),
        settings = {
          ["rust_analyzer"] = {
            cargo = {
              allFeatures = true,
            },
          },
        },
      },
      go_pls = {
        settings = {

          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
      lua_ls = {},
      -- Web development
      ts_ls = {
        root_dir = lspconfig.util.root_pattern("package.json"),
        single_file_support = true,
      },
      denols = {
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
      },
      cssls = {},
      tailwindcss = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "astro",
        },
      },
      astro = {},
      eslint = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
      },
    }

    require("mason").setup()

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      "stylua",
      "prettier",
      "eslint_d",
      "shfmt",
      "spellcheck",
    })

    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
      automatic_installation = false,
      auto_update = true,
      run_on_start = true,
      start_delay = 3000, -- 3 second delay
      debounce_hours = 5, -- at least 5 hours between attempts to install/update
    })

    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend("force", {}, server.capabilities or {})
          require("lspconfig")[server_name].setup(server)
        end,
      },
      automatic_installation = false,
    })
  end,
}
