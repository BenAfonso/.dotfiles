local M = {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "folke/lazydev.nvim",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      return {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- performance = {
        --   max_view_entries = 7,
        -- },
        mapping = cmp.mapping.preset.insert({
          ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Scroll up
          ["<C-d>"] = cmp.mapping.scroll_docs(4), -- Scroll down
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item() -- ({ behaviour = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s", "c" }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s", "c" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item() -- ({ behaviour = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1001 },
          { name = "luasnip", priority = 1000, max_item_count = 5 },
          { name = "nvim_lua", priority = 100, max_item_count = 20 },
          { name = "lazydev", group_index = 0, max_item_count = 20 },
          { name = "path", priority = 250, max_item_count = 10 },
          { name = "calc" },
          { name = "emoji" },
          { name = "buffer", max_item_count = 5 },
        }, {
          -- { name = "buffer", max_item_count = 5 },
        }),
        formatting = {
          -- fields = { "menu", "abbr", "kind" },
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local custom_menu_icon = {
              calc = "󰃬",
            }

            if entry.source.name == "calc" then
              vim_item.kind = custom_menu_icon.calc
              vim_item.menu = ""
            else
              local cmp_kind = require("utils.lsp_icons")[vim_item.kind]
              -- vim_item.menu = cmp_kind or ""
              vim_item.menu = vim_item.kind
              -- vim_item.kind = (cmp_kind or "") .. " " .. vim_item.kind
              vim_item.kind = (cmp_kind or "")
            end
            return vim_item
          end,
        },
      }
    end,
  },
}

return M
